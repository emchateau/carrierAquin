Synopsx starter exemple
=========

SynopsX exemple project for an XML-TEI corpus

## Install

Required software

- [BaseX](http://basex.org/) > 8 (Java version 8, required)
- [SaxonHE](http://sourceforge.net/projects/saxon/files/) (put .jar files in `basex/lib/`)

Download [SynopsX sources](http://synopsx.github.io/)

````bash
git clone https://github.com/synopsx/synopsx.git # clone SynopsX
````

Dans le répertoire `webapp`, renommer le fichier `restxq.xqm` en `restxq.old` afin d’éviter les conflits avec le fichier de démonstration de RESTXQ distribué par BaseX. Le répertoire `synopsx` doit être disponible à l’intérieur du répertoire `webapp` de BaseX.

```bash
cd basex/webapp/
mv restxq.xqm restxq.old # restxq.xqm définit par défaut une fonction resource for `/`
```

Télécharger les sources de [gdpWebapp](https://github.com/guidesDeParis/gdpWebapp)

```bash
git clone https://github.com/guidesDeParis/gdpWebapp # clone gdpWebapp
```

Le répertoire `gdpWebapp` doit être disponible à l’intérieur de `synospx/workspace/` et être renommé en `gdp`. Pour éviter d’avoir des chemins trop complexes, il est peut être commode d’utiliser des liens symboliques :

```bash
ln -s chemin/sources/synopsx chemin/basex/webapp # rendre disponible synopsx dans webapp
ln -s chemin/sources/gdpWebapp chemin/sources/synopsx/workspace/gdp # rendre disponible gdpWebapp dans workspace sous le nom gdp
```

Lancer BaseX en mode HTTP :

```bash
cd basex/bin/ # aller dans le répertoire BaseX
sh ./basexhttp # exécuter le script de démarrage de BaseX en mode HTTP
```

Dans un navigateur, se rendre sur http://localhost:8984 que sert BaseX par défaut en mode HTTP.

Aller dans l’administration de la base `admin DB` et créer une base de données nommée `gdp` avec les sources XML-TEI du projet des Guides de Paris.

Dans le panneau de configuration de SynopsX, accéder au menu `Config`, créer un projet nommé `gdp` puis changer le projet par défaut pour `gdp`.