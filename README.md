# SimpleSugar

Mes recettes de pâtisserie et de cuisine, à suivre pas à pas.

Le site est un carnet en lecture seule : 200 recettes (100 pâtisseries, 100 plats salés) intégrées directement dans `index.html`. Il n'y a ni compte ni connexion, et personne ne peut rien modifier ou supprimer depuis le site. Tout se fait par les mises à jour du dépôt GitHub, que Vercel publie automatiquement.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `index.html` | Le site entier, avec les 200 recettes. |
| `sw.js`, `manifest.webmanifest`, `icon-*.png`, `favicon.svg` | L'installation sur l'iPhone comme une app, et l'ouverture hors ligne. |
| `og-image.jpg` | L'aperçu affiché quand vous envoyez le lien dans Messages ou WhatsApp. |
| `vercel.json` | Les réglages d'hébergement. |
| `LICENCE-ECRITURE.txt` | La licence de la police dont dérive l'écriture manuscrite. |

## Mettre à jour le site

1. Sur GitHub, ouvrez le dépôt `simplesugar`, touchez **Add file → Upload files**.
2. Déposez les fichiers reçus (au minimum `index.html` et `sw.js`) : ils remplacent les anciens.
3. Touchez **Commit changes**. Vercel republie le site tout seul, en moins d'une minute.

Pour ajouter ou corriger des recettes, il suffit de recevoir un nouveau `index.html` et de le déposer de la même façon.

## Première mise en ligne

1. Sur [github.com](https://github.com), créez un dépôt nommé `simplesugar`, puis déposez tous les fichiers de ce dossier (**uploading an existing file**, puis **Commit changes**).
2. Sur [vercel.com](https://vercel.com), touchez **Add New… → Project**, importez le dépôt `simplesugar`, laissez **Framework Preset** sur **Other** et touchez **Deploy**.
3. Le site est en ligne à une adresse du type `simplesugar.vercel.app`.

## Sur l'iPhone

Ouvrez l'adresse dans Safari, touchez **Partager** puis **Sur l'écran d'accueil**. SimpleSugar s'ouvre alors en plein écran, comme une app, même sans réseau.

## Supabase n'est plus utilisé

Le site n'a plus besoin de base de données. Vous pouvez laisser le projet Supabase tel quel ou le supprimer. Si vous aviez créé le fichier `.github/workflows/keep-alive.yml` dans le dépôt, supprimez-le : il n'a plus d'utilité.

## Utilisation

- **Les recettes** : rangées en Pâtisserie et Salé, puis par famille (gâteaux, entremets, tartes, choux, viennoiseries, petits gâteaux, desserts, confiseries ; soupes, entrées, tartes et quiches, viandes, volailles, poissons, légumes et gratins, pâtes, riz et céréales).
- **Adapter la recette** : quatre onglets sur chaque fiche : **Sans porc** (et sans alcool quand il y en a), **Sans gluten**, **Diabète** et **Substituts** pour les ingrédients difficiles à trouver (gousse de vanille, eau de fleur d'oranger, levure fraîche, sucre perlé…). On les retrouve aussi au début du pas à pas.
- **Le pas à pas** : « Commencer la recette » affiche d'abord les ingrédients à préparer, puis une étape par écran. Touchez la carte (ou glissez) pour passer à la suivante. L'écran reste allumé, et la progression est gardée si vous quittez.
- **Les quantités** : les boutons − et + recalculent tous les ingrédients, avec des arrondis de cuisine.
- **Les minuteurs** : les durées écrites dans les étapes se lancent d'un toucher, s'affichent en haut de l'écran et sonnent à la fin.
- **Rechercher** : par titre, ingrédient ou mot d'une étape. Sur ordinateur, ⌘K ouvre la recherche.
- **Favoris** : le cœur garde une recette sous la main, sur l'appareil utilisé.

Les adaptations sont des conseils de cuisine : pour le diabète ou une maladie cœliaque, elles ne remplacent pas l'avis d'un médecin ; vérifiez toujours les étiquettes (gluten caché, gélatine).

## Crédits

L'écriture manuscrite est tracée à partir de la police **Playwrite** de TypeTogether, publiée sous licence SIL Open Font License 1.1 (voir `LICENCE-ECRITURE.txt`).
