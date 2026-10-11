-- =====================================================================
--  SimpleSugar · base de données Supabase (version 2)
--  À coller en entier dans Supabase → SQL Editor → New query → Run.
--  Le script peut être relancé sans risque : il ne supprime aucune de vos
--  recettes. Il retire seulement les 6 recettes d'exemple de la version 1.
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
-- nouveautés de la version 2 : famille de recette et adaptations
alter table public.recipes add column if not exists subcategory text not null default '';
alter table public.recipes add column if not exists adaptations jsonb not null default '{}'::jsonb;
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

-- ---------- 3. Le cuisinier : le seul compte qui peut modifier --------
create table if not exists public.editors (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  created_at  timestamptz not null default now()
);
alter table public.editors enable row level security;
revoke all on public.editors from anon, authenticated;

create or replace function public.simplesugar_is_editor()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.editors where user_id = auth.uid());
$$;
grant execute on function public.simplesugar_is_editor() to anon, authenticated;

-- le premier compte créé dans Authentication devient le cuisinier
create or replace function public.simplesugar_premier_cuisinier()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.editors) then
    insert into public.editors (user_id) values (new.id) on conflict do nothing;
  end if;
  return new;
end $$;
drop trigger if exists simplesugar_premier_cuisinier on auth.users;
create trigger simplesugar_premier_cuisinier after insert on auth.users
  for each row execute function public.simplesugar_premier_cuisinier();
-- si votre compte existe déjà, il devient le cuisinier tout de suite
insert into public.editors (user_id)
select id from auth.users
where not exists (select 1 from public.editors)
order by created_at
limit 1
on conflict do nothing;

-- ---------- 4. Dates automatiques + copie de l'ancienne version -------
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

-- ---------- 5. Droits : tout le monde lit, seul le cuisinier écrit ----
alter table public.recipes enable row level security;
alter table public.recipe_versions enable row level security;

grant usage on schema public to anon, authenticated;
revoke insert, update, delete, truncate on public.recipes from anon;
grant select on public.recipes to anon;
grant select, insert, update on public.recipes to authenticated;
revoke delete, truncate on public.recipes from authenticated;
revoke all on public.recipe_versions from anon;
grant select on public.recipe_versions to authenticated;
revoke insert, update, delete, truncate on public.recipe_versions from authenticated;

drop policy if exists "SimpleSugar lecture" on public.recipes;
create policy "SimpleSugar lecture" on public.recipes for select to anon, authenticated
  using (deleted_at is null or (select public.simplesugar_is_editor()));
drop policy if exists "SimpleSugar ajout" on public.recipes;
create policy "SimpleSugar ajout" on public.recipes for insert to authenticated
  with check ((select public.simplesugar_is_editor()));
drop policy if exists "SimpleSugar modification" on public.recipes;
create policy "SimpleSugar modification" on public.recipes for update to authenticated
  using ((select public.simplesugar_is_editor())) with check ((select public.simplesugar_is_editor()));
-- Pas de règle DELETE : une recette « supprimée » part dans la corbeille
-- (deleted_at) et reste récupérable.

drop policy if exists "SimpleSugar historique" on public.recipe_versions;
create policy "SimpleSugar historique" on public.recipe_versions for select to authenticated
  using ((select public.simplesugar_is_editor()));

-- ---------- 6. Photos : un dossier public « images » ------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('images', 'images', true, 6291456, array['image/webp', 'image/jpeg', 'image/png', 'image/gif', 'image/heic'])
on conflict (id) do update
  set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "SimpleSugar photos lecture" on storage.objects;
create policy "SimpleSugar photos lecture" on storage.objects for select to anon, authenticated
  using (bucket_id = 'images');
drop policy if exists "SimpleSugar photos ajout" on storage.objects;
create policy "SimpleSugar photos ajout" on storage.objects for insert to authenticated
  with check (bucket_id = 'images' and (select public.simplesugar_is_editor()));

-- ---------- 7. Retirer les 6 recettes d'exemple de la version 1 -------
-- Seules ces recettes précises sont visées (même titre ET même description,
-- sans famille) : vos propres recettes ne sont jamais touchées.
with exemples (titre, description) as (values
  ('Tarte au citron meringuée', 'Une pâte sucrée bien croustillante, une crème au citron acidulée et une meringue légère, dorée au chalumeau.'),
  ('Cookies moelleux au chocolat', 'Bords dorés, cœur fondant et de grosses pépites de chocolat noir.'),
  ('Risotto aux champignons', 'Crémeux sans crème : tout le secret est dans le bouillon ajouté louche par louche.'),
  ('Îles flottantes', 'Des nuages de blancs pochés sur une crème anglaise vanillée, avec un filet de caramel.'),
  ('Velouté de potimarron', 'Doux, presque sucré et très velouté. Pas besoin d’éplucher le potimarron.'),
  ('Crêpes de la Chandeleur', 'La pâte de base, fine et souple, sans un grumeau.')
), cibles as (
  select r.id from public.recipes r join exemples e on r.title = e.titre and r.description = e.description
  where r.subcategory = ''
)
delete from public.recipes where id in (select id from cibles);
delete from public.recipe_versions v where not exists (select 1 from public.recipes r where r.id = v.recipe_id);

-- Terminé. La requête ci-dessous indique combien de cuisiniers sont
-- enregistrés : 0 tant que vous n'avez pas créé votre compte, 1 ensuite.
select count(*) as cuisiniers from public.editors;
