# SimpleSugar

Mes recettes de pâtisserie et de cuisine, à suivre pas à pas.

Le site tient dans un seul fichier, `index.html`. Les recettes sont enregistrées dans Supabase, le code vit sur GitHub et Vercel publie le site à chaque modification.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `index.html` | Le site entier. Les deux réglages Supabase sont en haut, lignes 17 et 18. |
| `sw.js`, `manifest.webmanifest`, `icon-*.png`, `favicon.svg` | L'installation sur l'iPhone comme une app, et l'ouverture hors ligne. |
| `og-image.jpg` | L'aperçu affiché quand vous envoyez le lien dans Messages ou WhatsApp. |
| `vercel.json` | Les réglages d'hébergement. |
| `supabase-schema.sql` | La base de données, à exécuter une seule fois dans Supabase. |
| `keep-alive.yml` | Facultatif : empêche Supabase de mettre le projet en pause. |
| `LICENCE-ECRITURE.txt` | La licence de la police dont dérive l'écriture manuscrite. |

## Mise en ligne

Comptez un quart d'heure. Tout se fait depuis Safari sur l'iPhone.

### 1. Supabase, la base de données

1. Sur [supabase.com](https://supabase.com), créez un projet : nom `simplesugar`, région **Paris (eu-west-3)**. Notez le mot de passe de la base quelque part.
2. Ouvrez **SQL Editor**, puis **New query**. Collez tout le contenu de `supabase-schema.sql` et touchez **Run**. Le résultat affiche une colonne `recettes` avec la valeur 0.
3. Récupérez deux informations. Le bouton **Connect** en haut du tableau de bord les affiche toutes les deux ; sinon, elles sont dans **Project Settings** :
   - l'adresse du projet, du type `https://abcdefgh.supabase.co` (rubrique **Data API**) ;
   - la clé **publishable**, qui commence par `sb_publishable_` (rubrique **API Keys**). Sur un projet plus ancien, prenez la clé **anon public**.

N'utilisez jamais la clé **secret** dans le site : elle donne tous les droits sur la base.

### 2. GitHub, le code

1. Sur [github.com](https://github.com), créez un dépôt nommé `simplesugar` (privé ou public, au choix).
2. Touchez **uploading an existing file**, sélectionnez tous les fichiers du dossier dézippé, puis **Commit changes**.
3. Ouvrez `index.html` dans le dépôt, touchez le crayon et remplissez les deux lignes du haut, entre les apostrophes :

   ```js
   SUPABASE_URL: 'https://abcdefgh.supabase.co',
   SUPABASE_KEY: 'sb_publishable_…'
   ```

   Touchez **Commit changes**.

### 3. Vercel, l'adresse du site

1. Sur [vercel.com](https://vercel.com), touchez **Add New…** puis **Project**, et importez le dépôt `simplesugar`.
2. Laissez **Framework Preset** sur **Other** et touchez **Deploy**.
3. Le site est en ligne à une adresse du type `simplesugar.vercel.app`. Vous pouvez la changer dans **Settings → Domains**.

Chaque modification enregistrée sur GitHub met le site à jour toute seule, en moins d'une minute.

### 4. Sur l'iPhone

Ouvrez l'adresse dans Safari, touchez **Partager** puis **Sur l'écran d'accueil**. SimpleSugar s'ouvre alors en plein écran, comme une app, même sans réseau.

### 5. Conseillé : garder Supabase éveillé

Le plan gratuit de Supabase met un projet en pause après une semaine sans visite. Pour l'éviter, une petite tâche GitHub consulte la base tous les deux jours :

1. Dans le dépôt, touchez **Add file → Create new file**.
2. Tapez exactement ce nom : `.github/workflows/keep-alive.yml` (les `/` créent les dossiers).
3. Collez le contenu du fichier `keep-alive.yml` et touchez **Commit changes**.
4. Pour vérifier : onglet **Actions**, **Garder Supabase éveillé**, **Run workflow**. Une coche verte doit apparaître.

La tâche lit l'adresse et la clé directement dans `index.html` : rien d'autre à régler. Si le dépôt est public et reste deux mois sans modification, GitHub suspend la tâche et vous prévient par e-mail ; un clic la relance.

## Utilisation

- **Ajouter une recette** : tuile « Nouvelle recette ». Vous pouvez tout écrire, ou coller une recette entière depuis Notes, un message ou un site : le titre, les portions, les temps, les ingrédients et les étapes se rangent tout seuls. Vérifiez puis enregistrez.
- **Les étapes** : chacune a un texte détaillé, et si besoin un minuteur, la température du four, une astuce, un **dessin** (au doigt ou à l'Apple Pencil) et une photo. Les durées écrites dans le texte, comme « 25 min », deviennent des minuteurs qu'on lance d'un toucher.
- **Le pas à pas** : « Commencer la recette » affiche d'abord les ingrédients à préparer, puis une étape par écran. Touchez la carte (ou glissez) pour passer à la suivante. Les ingrédients utilisés dans l'étape s'affichent avec leurs quantités. L'écran reste allumé, et la progression est gardée si vous quittez.
- **Les quantités** : les boutons − et + recalculent tous les ingrédients, avec des arrondis de cuisine (pas de « 1,1 œuf »).
- **Les minuteurs** : ils s'affichent en haut de l'écran, façon Dynamic Island, et sonnent à la fin. On peut en lancer plusieurs.
- **Rechercher** : par titre, ingrédient ou mot d'une étape. Sur ordinateur, ⌘K ouvre la recherche.

## Bon à savoir

- **Pas de mot de passe** : toute personne qui a l'adresse peut lire les recettes, mais aussi en ajouter ou les modifier. Rien ne peut être effacé définitivement depuis le site : une recette supprimée part dans la corbeille, et chaque enregistrement garde la version précédente dans l'historique (menu « … » d'une recette). Pour une sauvegarde complète : **Réglages → Sauvegarder toutes les recettes**.
- **Favoris et progression** sont propres à chaque appareil.
- **Photos** : elles sont réduites automatiquement (environ 200 Ko) avant l'envoi. Le plan gratuit de Supabase offre 1 Go pour les photos et 500 Mo pour les recettes, de quoi en ranger des milliers.
- **Sans réglages Supabase**, le site fonctionne quand même : les recettes restent alors enregistrées sur l'appareil.
- **Le « hello »** : le nom s'écrit à l'ouverture de l'app, une fois par session. Touchez l'écran pour passer, ou désactivez-le dans les Réglages.

## Crédits

L'écriture manuscrite est tracée à partir de la police **Playwrite** de TypeTogether, publiée sous licence SIL Open Font License 1.1 (voir `LICENCE-ECRITURE.txt`).
