-- =====================================================================
--  SimpleSugar · base de données Supabase
--  À coller en entier dans Supabase → SQL Editor → New query → Run.
--  Le script peut être relancé sans risque : il ne supprime aucune donnée.
-- =====================================================================

-- ---------- 1. Les recettes -------------------------------------------
create table if not exists public.recipes (
  id              uuid primary key default gen_random_uuid(),
  title           text        not null default '',
  description     text        not null default '',
  category        text        not null default 'patisserie' check (category in ('patisserie', 'cuisine')),
  servings        integer     not null default 4 check (servings between 1 and 200),
  servings_label  text        not null default 'parts',
  prep_min        integer     not null default 0 check (prep_min >= 0),
  cook_min        integer     not null default 0 check (cook_min >= 0),
  rest_min        integer     not null default 0 check (rest_min >= 0),
  difficulty      integer     not null default 1 check (difficulty between 1 and 3),
  cover_url       text,
  equipment       jsonb       not null default '[]'::jsonb,
  ingredients     jsonb       not null default '[]'::jsonb,
  steps           jsonb       not null default '[]'::jsonb,
  notes           text        not null default '',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz,
  -- garde-fou : une recette (dessins compris) reste sous 4 Mo
  constraint recipes_taille check (octet_length(steps::text) + octet_length(ingredients::text) < 4000000)
);
create index if not exists recipes_updated_idx on public.recipes (updated_at desc);

-- ---------- 2. L'historique : chaque version remplacée est conservée --
create table if not exists public.recipe_versions (
  id          uuid primary key default gen_random_uuid(),
  recipe_id   uuid        not null,
  action      text        not null,
  snapshot    jsonb       not null,
  created_at  timestamptz not null default now()
);
create index if not exists recipe_versions_recipe_idx on public.recipe_versions (recipe_id, created_at desc);

-- ---------- 3. Dates automatiques + copie de l'ancienne version -------
create or replace function public.simplesugar_avant_ajout()
returns trigger language plpgsql as $$
begin
  new.created_at := now();
  new.updated_at := now();
  return new;
end $$;

create or replace function public.simplesugar_avant_modif()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.created_at := old.created_at;
  new.updated_at := clock_timestamp();
  insert into public.recipe_versions (recipe_id, action, snapshot)
  values (
    old.id,
    case
      when new.deleted_at is not null and old.deleted_at is null then 'suppression'
      when new.deleted_at is null and old.deleted_at is not null then 'restauration'
      else 'modification'
    end,
    to_jsonb(old)
  );
  return new;
end $$;

drop trigger if exists simplesugar_ajout on public.recipes;
create trigger simplesugar_ajout before insert on public.recipes
  for each row execute function public.simplesugar_avant_ajout();

drop trigger if exists simplesugar_modif on public.recipes;
create trigger simplesugar_modif before update on public.recipes
  for each row execute function public.simplesugar_avant_modif();

-- ---------- 4. Droits : lire, ajouter, modifier. Jamais effacer. ------
alter table public.recipes enable row level security;
alter table public.recipe_versions enable row level security;

grant usage on schema public to anon, authenticated;
grant select, insert, update on public.recipes to anon, authenticated;
revoke delete, truncate on public.recipes from anon, authenticated;
grant select on public.recipe_versions to anon, authenticated;
revoke insert, update, delete, truncate on public.recipe_versions from anon, authenticated;

drop policy if exists "SimpleSugar lecture" on public.recipes;
create policy "SimpleSugar lecture" on public.recipes for select to anon, authenticated using (true);
drop policy if exists "SimpleSugar ajout" on public.recipes;
create policy "SimpleSugar ajout" on public.recipes for insert to anon, authenticated with check (true);
drop policy if exists "SimpleSugar modification" on public.recipes;
create policy "SimpleSugar modification" on public.recipes for update to anon, authenticated using (true) with check (true);
-- Pas de règle DELETE : depuis le site, une recette « supprimée » part
-- seulement dans la corbeille (deleted_at), elle reste récupérable.

drop policy if exists "SimpleSugar historique" on public.recipe_versions;
create policy "SimpleSugar historique" on public.recipe_versions for select to anon, authenticated using (true);

-- ---------- 5. Photos : un dossier public « images » ------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('images', 'images', true, 6291456, array['image/webp', 'image/jpeg', 'image/png', 'image/gif', 'image/heic'])
on conflict (id) do update
  set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "SimpleSugar photos lecture" on storage.objects;
create policy "SimpleSugar photos lecture" on storage.objects for select to anon, authenticated using (bucket_id = 'images');
drop policy if exists "SimpleSugar photos ajout" on storage.objects;
create policy "SimpleSugar photos ajout" on storage.objects for insert to anon, authenticated with check (bucket_id = 'images');
-- Pas de remplacement ni de suppression de photo depuis le site.

-- Terminé. Vérification rapide : la requête ci-dessous doit renvoyer 0.
select count(*) as recettes from public.recipes;
