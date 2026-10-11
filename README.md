# SimpleSugar

Mes recettes de pâtisserie et de cuisine, à suivre pas à pas.

Le site tient dans un seul fichier, `index.html`. Les recettes sont enregistrées dans Supabase, le code vit sur GitHub et Vercel publie le site à chaque modification. Tout le monde peut lire les recettes ; seul le cuisinier, connecté avec son compte, peut en ajouter, les modifier ou les supprimer.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `index.html` | Le site entier. Les deux réglages Supabase sont en haut, lignes 17 et 18. |
| `recettes.json` | Le carnet des 200 recettes SimpleSugar (100 pâtisseries, 100 plats salés), que le cuisinier installe depuis le site. |
| `sw.js`, `manifest.webmanifest`, `icon-*.png`, `favicon.svg` | L'installation sur l'iPhone comme une app, et l'ouverture hors ligne. |
| `og-image.jpg` | L'aperçu affiché quand vous envoyez le lien dans Messages ou WhatsApp. |
| `vercel.json` | Les réglages d'hébergement. |
| `supabase-schema.sql` | La base de données et ses droits, à exécuter dans Supabase. |
| `keep-alive.yml` | Facultatif : empêche Supabase de mettre le projet en pause. |
| `LICENCE-ECRITURE.txt` | La licence de la police dont dérive l'écriture manuscrite. |

## Vous avez déjà la première version en ligne ?

Quatre étapes, un quart d'heure :

1. **La base** : dans Supabase, **SQL Editor → New query**, collez tout le nouveau `supabase-schema.sql` et touchez **Run**. Le script garde vos recettes ; il retire seulement les 6 recettes d'exemple de la première version.
2. **Le compte du cuisinier** : voir l'étape 2 ci-dessous.
3. **Les fichiers** : sur GitHub, dans le dépôt, touchez **Add file → Upload files**, déposez **tous** les fichiers du dossier (ils remplacent les anciens) et touchez **Commit changes**. Vercel republie le site tout seul.
4. **Les recettes** : ouvrez le site, **Réglages → Espace cuisinier**, connectez-vous, puis touchez **Installer les 200 recettes**.

## Mise en ligne complète

Tout se fait depuis Safari sur l'iPhone.

### 1. Supabase, la base de données

1. Sur [supabase.com](https://supabase.com), créez un projet : nom `simplesugar`, région **Paris (eu-west-3)**. Notez le mot de passe de la base quelque part.
2. Ouvrez **SQL Editor**, puis **New query**. Collez tout le contenu de `supabase-schema.sql` et touchez **Run**. Le résultat affiche une colonne `cuisiniers` : 0 tant que le compte du cuisinier n'existe pas, 1 ensuite.
3. Récupérez deux informations. Le bouton **Connect** en haut du tableau de bord les affiche toutes les deux ; sinon, elles sont dans **Project Settings** :
   - l'adresse du projet, du type `https://abcdefgh.supabase.co` (rubrique **Data API**) ;
   - la clé **publishable**, qui commence par `sb_publishable_` (rubrique **API Keys**). Sur un projet plus ancien, prenez la clé **anon public**.

N'utilisez jamais la clé **secret** dans le site : elle donne tous les droits sur la base. Si elle a été copiée ou envoyée quelque part, régénérez-la dans **Project Settings → API Keys**.

### 2. Le compte du cuisinier

C'est le seul compte qui peut modifier les recettes.

1. Dans Supabase, ouvrez **Authentication → Users**, touchez **Add user → Create new user**.
2. Indiquez votre e-mail et un mot de passe solide, cochez **Auto Confirm User**, puis **Create user**.

Le premier compte créé devient automatiquement le cuisinier, que vous l'ayez créé avant ou après le script SQL. Un autre compte créé plus tard n'aura aucun droit.

Conseillé : dans **Authentication → Sign In / Providers**, désactivez **Allow new users to sign up**, pour que personne ne puisse créer de compte depuis l'extérieur.

### 3. GitHub, le code

1. Sur [github.com](https://github.com), créez un dépôt nommé `simplesugar` (privé ou public, au choix).
2. Touchez **uploading an existing file**, sélectionnez tous les fichiers du dossier dézippé (dont `recettes.json`), puis **Commit changes**.
3. Vérifiez les deux lignes du haut de `index.html` (déjà remplies dans ce dossier) ; pour les changer, ouvrez le fichier, touchez le crayon, modifiez entre les apostrophes et **Commit changes** :

   ```js
   SUPABASE_URL: 'https://abcdefgh.supabase.co',
   SUPABASE_KEY: 'sb_publishable_…'
   ```

### 4. Vercel, l'adresse du site

1. Sur [vercel.com](https://vercel.com), touchez **Add New…** puis **Project**, et importez le dépôt `simplesugar`.
2. Laissez **Framework Preset** sur **Other** et touchez **Deploy**.
3. Le site est en ligne à une adresse du type `simplesugar.vercel.app`. Vous pouvez la changer dans **Settings → Domains**.

Chaque modification enregistrée sur GitHub met le site à jour toute seule, en moins d'une minute.

### 5. Installer les 200 recettes

Ouvrez le site, touchez **Réglages** (en haut à droite de l'accueil), puis **Espace cuisinier**, et connectez-vous avec le compte de l'étape 2. Sur l'accueil, touchez **Installer les 200 recettes** : elles arrivent en quelques secondes et deviennent visibles pour tout le monde. Le bouton se retrouve dans **Réglages → Cuisinier** ; le relancer n'ajoute jamais de doublon, ni une recette que vous avez supprimée ou modifiée.

### 6. Sur l'iPhone

Ouvrez l'adresse dans Safari, touchez **Partager** puis **Sur l'écran d'accueil**. SimpleSugar s'ouvre alors en plein écran, comme une app, même sans réseau.

### 7. Conseillé : garder Supabase éveillé

Le plan gratuit de Supabase met un projet en pause après une semaine sans visite. Pour l'éviter, une petite tâche GitHub consulte la base tous les deux jours :

1. Dans le dépôt, touchez **Add file → Create new file**.
2. Tapez exactement ce nom : `.github/workflows/keep-alive.yml` (les `/` créent les dossiers).
3. Collez le contenu du fichier `keep-alive.yml` et touchez **Commit changes**.
4. Pour vérifier : onglet **Actions**, **Garder Supabase éveillé**, **Run workflow**. Une coche verte doit apparaître.

La tâche lit l'adresse et la clé directement dans `index.html` : rien d'autre à régler.

## Utilisation

- **Les recettes** : 200 classiques, rangés en Pâtisserie et Salé, puis par famille (gâteaux, entremets, tartes, choux, viennoiseries, petits gâteaux, desserts, confiseries ; soupes, entrées, tartes et quiches, viandes, volailles, poissons, légumes et gratins, pâtes, riz et céréales).
- **Adapter la recette** : chaque fiche propose quatre onglets : **Sans porc** (et sans alcool quand il y en a), **Sans gluten**, **Diabète** et **Substituts** pour les ingrédients difficiles à trouver (gousse de vanille, eau de fleur d'oranger, levure fraîche, sucre perlé…). On les retrouve aussi au début du pas à pas.
- **Le pas à pas** : « Commencer la recette » affiche d'abord les ingrédients à préparer, puis une étape par écran. Touchez la carte (ou glissez) pour passer à la suivante. Les ingrédients utilisés dans l'étape s'affichent avec leurs quantités. L'écran reste allumé, et la progression est gardée si vous quittez.
- **Les quantités** : les boutons − et + recalculent tous les ingrédients, avec des arrondis de cuisine (pas de « 1,1 œuf »).
- **Les minuteurs** : les durées écrites dans les étapes se lancent d'un toucher ; ils s'affichent en haut de l'écran, façon Dynamic Island, et sonnent à la fin.
- **Rechercher** : par titre, ingrédient ou mot d'une étape. Sur ordinateur, ⌘K ouvre la recherche.
- **Pour le cuisinier** (une fois connecté) : tuile « Nouvelle recette » (écrire, ou coller une recette entière qui se range toute seule), bouton crayon sur chaque fiche, dessins au doigt pour les étapes, photos, corbeille, historique des versions, sauvegarde complète dans les Réglages.

## Bon à savoir

- **Qui peut modifier** : les visiteurs ne voient aucun bouton de modification, et même en bidouillant, la base refuse tout changement qui ne vient pas du compte du cuisinier. Rien ne peut être effacé définitivement : une recette supprimée part dans la corbeille, et chaque modification garde la version précédente.
- **Synchronisation** : automatique, à l'ouverture et au retour sur le site. Chaque appareil garde une copie pour fonctionner sans réseau.
- **Les adaptations** sont des conseils de cuisine. Pour le diabète ou une maladie cœliaque, elles ne remplacent pas l'avis d'un médecin ou d'une diététicienne ; vérifiez toujours les étiquettes (gluten caché, gélatine).
- **Favoris et progression** sont propres à chaque appareil.
- **Photos** : elles sont réduites automatiquement (environ 200 Ko) avant l'envoi. Le plan gratuit de Supabase offre 1 Go pour les photos et 500 Mo pour les recettes.
- **Le « hello »** : le nom s'écrit à l'ouverture de l'app, une fois par session. Touchez l'écran pour passer, ou désactivez-le dans les Réglages.

## Crédits

L'écriture manuscrite est tracée à partir de la police **Playwrite** de TypeTogether, publiée sous licence SIL Open Font License 1.1 (voir `LICENCE-ECRITURE.txt`).
