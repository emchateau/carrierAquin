xquery version "3.1" ;
module namespace test.models.tei = 'test.models.tei' ;

(:~
 : This module is a TEI models library for a synopsx starter project
 :
 : @version 1.0
 : @date 2020-09
 : @since 2020-09
 : @author emchateau (Université de Montréal)
 :
 : This module uses SynopsX publication framework
 : see https://github.com/ahn-ens-lyon/synopsx
 : It is distributed under the GNU General Public Licence,
 : see http://www.gnu.org/licenses/
 :
 :)

import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;

import module 'test.models.tei' at 'teiContent.xqm' , 'teiBuilder.xqm' ;

import module namespace test.globals = 'test.globals' at '../globals.xqm' ;

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace 'test.models.tei' ;

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei blog
 : ~:~:~:~:~:~:~:~:~
 :)
 
(:~
 : this function get the blog home
 :
 : @param $queryParams the request params sent by restxq
 : @return a map with meta and content
 :)
declare function getBlogPosts($queryParams as map(*)) as map(*) {
  let $posts := synopsx.models.synopsx:getDb($queryParams)//tei:TEI
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $meta := map{
    'title' : 'Page d’accueil du blog', 
    'quantity' : getQuantity($posts, 'billet', 'billets'),
    'author' : getAuthors($posts, $lang),
    'copyright' : getCopyright($posts, $lang),
    'description' : getDescription($posts, $lang),
    'keywords' : array{getKeywords($posts, $lang)}
    }
  let $content := for $post in $posts 
    let $uuid := $post//tei:sourceDesc/@xml:id
    return map {
    'title' : getMainTitle($post, $lang),
    'subtitle' : getSubtitle($post, $lang),
    'date' : getBlogDate($post, $dateFormat),
    'author' : getAuthors($post, $lang),
    'abstract' : getAbstract($post, $lang),
    'uuid' : $uuid,
    'path' : '/blog/posts/',
    'url' : $test.globals:root || '/blog/posts/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get a blog post by ID
 :
 : @param $queryParams the request params sent by restxq
 : @param $entryId the blog post ID
 : @return a map with meta and content
 : @todo give uuid for blog item after/before
 :)
declare function getBlogItem($queryParams as map(*)) {
  let $entryId := map:get($queryParams, 'entryId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $article := synopsx.models.synopsx:getDb($queryParams)/tei:teiCorpus/tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id=$entryId]]
  let $meta := map{
    'title' : getTitles($article, $lang),
    'author' : getAuthors($article, $lang),
    'copyright' : getCopyright($article, $lang),
    'description' : getDescription($article, $lang),
    'keywords' : array{getKeywords($article, $lang)}
    }
  let $uuid := $article//tei:sourceDesc/@xml:id
  let $getBlogItemBefore := getBlogItemBefore($queryParams, $article, $lang)
  let $getBlogItemAfter := getBlogItemAfter($queryParams, $article, $lang)
  let $content := map {
    'rubrique' : 'Article de blog',
    'title' : getMainTitle($article, $lang),
    'subtitle' : getSubtitle($article, $lang),
    'date' : getBlogDate($article, $dateFormat),
    'author' : getAuthors($article, $lang),
    'abstract' : getAbstract($article, $lang),
    'tei' : $article//tei:text/*,
    'uuid' : $uuid,
    'path' : '/blog/posts/',
    'url' : $test.globals:root || '/blog/posts/' || $uuid,
    'itemBeforeTitle' : getTitles($getBlogItemBefore, $lang),
    'itemBeforeUrl' : getUrl($getBlogItemBefore//tei:sourceDesc/@xml:id, '/blog/posts/', $lang),
    'itemBeforeUuid' : $getBlogItemBefore//tei:sourceDesc/@xml:id,
    'itemAfterTitle' : getTitles($getBlogItemAfter, $lang),
    'itemAfterUrl' : getUrl($getBlogItemAfter//tei:sourceDesc/@xml:id, '/blog/posts/', $lang),
    'itemAfterUuid' : $getBlogItemAfter//tei:sourceDesc/@xml:id
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei edition
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function get the about page
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 :)
declare function getAbout($queryParams as map(*)) as map(*) {
  let $entryId := map:get($queryParams, 'entryId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $article := synopsx.models.synopsx:getDb($queryParams)/tei:TEI[//tei:sourceDesc[@xml:id=$entryId]]
  let $meta := map{
    'title' : getTitles($article, $lang),
    'author' : getAuthors($article, $lang),
    'copyright' : getCopyright($article, $lang),
    'description' : getDescription($article, $lang),
    'keywords' : array{getKeywords($article, $lang)}
    }
  let $content := 
    for $item in $article
    let $uuid := $article//tei:sourceDesc/@xml:id
    return map {
    'title' : getMainTitle($item, $lang),
    'subtitle' : getSubtitle($item, $lang),
    'date' : getDate($item, $dateFormat),
    'author' : getAuthors($item, $lang),
    'abstract' : getAbstract($item, $lang),
    'uuid' : $uuid,
    'path' : '/about/',
    'url' : $test.globals:root || '/' || $uuid,
    'tei' : $item
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the corpus list
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 : @todo pour éviter le calcul de weight, fournir une valeur avec extent dans le teiHeader
 :)
declare function getCorpusList($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $corpora := synopsx.models.synopsx:getDb($queryParams)/tei:teiCorpus
  let $meta := map{
    'title' : 'Liste des corpus', 
    'quantity' : getQuantity($corpora/tei:teiCorpus, 'corpus disponible', 'corpora disponibles'),
    'author' : getAuthors($corpora, $lang),
    'copyright'  : getCopyright($corpora, $lang),
    'description' : getDescription($corpora, $lang),
    'keywords' : array{getKeywords($corpora, $lang)}
    }
  let $content := 
    for $corpus at $count in $corpora/tei:teiCorpus 
    let $uuid := $corpus/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id
    let $otherEditions := getOtherEditions(getRef($corpus))
    return map {
    'title' : getTitles($corpus, $lang), (: @todo sequence or main and sub :)
    'date' : getEditionDates($otherEditions/tei:biblStruct, $dateFormat),
    'author' : getAuthors($corpus, $lang),
    'abstract' : getAbstract($corpus, $lang),
    'editionsQuantity' : getQuantity($otherEditions/tei:biblStruct, 'édition', ' éditions'), (: @todo with or without unit :)
    'textsQuantity' : getQuantity($corpus/tei:TEI, 'texte disponible', 'textes disponibles'),
    'uuid' : $uuid,
    'path' : '/corpus/',
    'url' : $test.globals:root || '/corpus/' || $uuid,
    (:'editions' : getOtherEditions(getRef($corpus)),:)
    'weight' : getStringLength($corpus)
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the corpus list
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 : @todo appliquer la fonction biblio
 :)
declare function getCorpusById($queryParams as map(*)) as map(*) {
  let $corpusId := map:get($queryParams, 'corpusId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $corpus := synopsx.models.synopsx:getDb($queryParams)/tei:teiCorpus/tei:teiCorpus[tei:teiHeader//tei:sourceDesc[@xml:id = $corpusId]]
  let $meta := map{
    'title' : 'Liste des textes disponibles', 
    'quantity' : getQuantity($corpus/tei:TEI, 'texte disponible', 'textes disponibles'),
    'author' : getAuthors($corpus, $lang),
    'copyright'  : getCopyright($corpus, $lang),
    'description' : getDescription($corpus, $lang),
    'keywords' : array{getKeywords($corpus, $lang)}
    }
  let $content := 
    for $text in $corpus/tei:TEI 
    let $uuid := $text/tei:teiHeader//tei:sourceDesc/@xml:id
    return map {
    'title' : getTitles($text, $lang), (: @todo sequence or main and sub :)
    'date' : getEditionDates(getOtherEditions(getRef($text))/tei:biblStruct, $dateFormat),
    'author' : getAuthors($text, $lang),
    'biblio' : getRef($text),
    'abstract' : getAbstract($text, $lang),
    'format' : getRef($text)//tei:dim[@type = 'format'],
    'itemsNb' : fn:count($text//tei:*[@type = 'item' or @type = 'section']), (: todo value and unit :)
    'weight' : getStringLength($text),
    'uuid' : $uuid,
    'path' : '/texts/',
    'url' : $test.globals:root || '/texts/' || $uuid,
    'otherEditions' : fn:count(getOtherEditions(getRef($text))/tei:biblStruct) (: todo value and unit :)
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get text by ID
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 : @todo suppress the @xml:id filter on div
 : @todo check the text hierarchy
 : @rmq depreciated, replaced by getTocByTextId()
 :)
declare function getTextItemsById($queryParams as map(*)) as map(*) {
  let $textId := map:get($queryParams, 'textId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $ref := getRef($text)
  let $meta := map{
    'title' : 'Item du corpus',
    'ref' : $ref, 
    'quantity' : getQuantity($text, 'texte disponible', 'textes disponibles'),
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $content := 
    (: for $item in $text//tei:div[(@type = 'item' and @xml:id) or (@type = 'section' and @xml:id ) or (@type = 'chapter' and @xml:id )] :)
    for $item in $text//tei:div[(@type = 'item' and @xml:id) or (@type = 'section' and @xml:id )]
    let $uuid := (if ($item/@xml:id) then $item/@xml:id else 'toto')
    return map {
    'title' : getSectionTitle($item),
    'date' : getDate($ref, $dateFormat),
    'author' : getAuthors($text, $lang),
    'abstract' : getAbstract($text, $lang),
    'tei' : $item,
    'path' : '/items/',
    'uuid' : $uuid,
    'url' : $test.globals:root || '/items/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get text by ID
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 : @todo suppress the @xml:id filter on div
 : @todo check the text hierarchy
 :)
declare function getTextById($queryParams as map(*)) as map(*) {
  let $textId := map:get($queryParams, 'textId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $meta := map{
    'title' : 'Sommaire de ' || getTitles($text, $lang), 
    'quantity' : getRef($text),
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $content := 
    for $item in $text//tei:div[(@type = 'item' and @xml:id) or (@type = 'section' and @xml:id )]
    let $uuid := (if ($item/@xml:id) then $item/@xml:id else 'toto')
    return map {
    'title' : getSectionTitle($item),
    'date' : getDate($text, $dateFormat),
    'author' : getAuthors($text, $lang),
    'abstract' : getAbstract($text, $lang),
    'tei' : $item,
    'path' : '/items/',
    'uuid' : $uuid,
    'url' : $test.globals:root || '/items/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get text toc by ID
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 :)
declare function getTocByTextId($queryParams as map(*)) as map(*) {
  let $textId := map:get($queryParams, 'textId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $meta := map{
    'title' : 'Sommaire de ' || getTitles($text, $lang), 
    'quantity' : getQuantity($text//(tei:front|tei:back|tei:body|tei:div), 'entrée', 'entrées'),
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $content := getToc($text, map{})
  return map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get text pagination by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map with meta and content
 :)
declare function getPaginationByTextId($queryParams as map(*)) as map(*) {
  let $textId := map:get($queryParams, 'textId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $meta := map{
    'title' : 'Sommaire de ' || getTitles($text, $lang),
    'quantity' : getQuantity($text//tei:fw[@type='pageNum'], 'page', 'pages'),
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $content := getPagination($text, map{})
  return map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get text by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map with meta and content
 :)(:
declare function getPagination($queryParams as map(*)) as map(*) {
  let $textId := map:get($queryParams, 'textId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $meta := map{
    'title' : 'Pages de ' || getTitles($text, $lang),
    'page' : $queryParams?page,
    'quantity' : getQuantity($text//tei:fw, 'page', 'pages'),
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $content := getItemFromPage($text, map{
    'page' : $queryParams?page
    })
  return map{
    'meta'    : $meta,
    'content' : $content
    }
};:)

(:~
 : this function get item by ID
 :
 : @param $queryParams the request params sent by restxq 
 : @return a map with meta and content
 : @todo get next / before from toc
 :)
declare function getItemById($queryParams as map(*)) as map(*) {
  let $itemId := map:get($queryParams, 'itemId')
  let $textId := fn:tokenize($itemId, '(Front|Body|Back|T)')[1] (: map:get($queryParams, 'textId') :)
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $text := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $textId]]
  let $item := $text//tei:div[@xml:id = $itemId] union $text//tei:titlePage[@xml:id = $itemId]
  let $meta := map{
    'title' : fn:string-join(getSectionTitle($item), ', '),
    'quantity' : getQuantity($item, 'item disponible', 'items disponibles'), (: @todo internationalize :)
    'author' : getAuthors($text, $lang),
    'copyright'  : getCopyright($text, $lang),
    'description' : getDescription($text, $lang),
    'keywords' : array{getKeywords($text, $lang)}
    }
  let $uuid := $item/@xml:id
  let $itemBefore := getItemBefore($item, $lang)
  let $itemAfter := getItemAfter($item, $lang)
  let $tei :=
    if ($queryParams?depth)
    then $item
    else remove-elements-deep($item, 'div')
  let $content := 
  map {
    'title' : getSectionTitle($item),
    'rubrique' : 'Item',
    'date' : getDate($item, $dateFormat),
    'author' : getAuthors($item, $lang),
    'abstract' : getAbstract($item, $lang),
    'pages' : getPages($item, map{}),
    'tei' : $tei,
    'path' : '/items/',
    'uuid' : $uuid,
    'url' : $test.globals:root || '/items/' || $uuid,
    'itemBeforeTitle' : getSectionTitle($itemBefore), (: is a sequence :)
    'itemBeforeUrl' : getUrl($itemBefore/@xml:id, '/items/', $lang),
    'itemBeforeUuid' : $itemBefore/@xml:id,
    'itemAfterTitle' : getSectionTitle($itemAfter), (: is a sequence :)
    'itemAfterUrl' : getUrl($itemAfter/@xml:id, '/items/', $lang),
    'itemAfterUuid' : $itemAfter/@xml:id,
    'indexes' : getIndexEntries($item)
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the model
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getModel($queryParams) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $model := synopsx.models.synopsx:getDb($queryParams)//tei:TEI
  let $meta := map{
    'title' : 'Schéma ODD', 
    'author' : getAuthors($model, $lang),
    'copyright' : getCopyright($model, $lang),
    'description' : getDescription($model, $lang),
    'keywords' : array{getKeywords($model, $lang)}
    }
  let $content := map {
    'title' : getTitles($model, $lang),
    'date' : getDate($model, $dateFormat),
    'author' : getAuthors($model, $lang),
    'abstract' : getAbstract($model, $lang),
    'tei' : $model
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei biblio
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function get the bibliographical works list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getBibliographicalWorksList($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalWorks := $bibliography//tei:bibl[@type='work']
  let $meta := map{
    'title' : 'Liste des œuvres', 
    'quantity' : getQuantity($bibliographicalWorks, 'œuvre', 'œuvres'),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : 'Liste des œuvres de la bibliographie des Guides de Paris, au sens des FRBR',
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : $test.globals:root || '/bibliography/works'
    }
  let $content := 
    for $bibliographicalWork in $bibliographicalWorks 
    let $uuid := $bibliographicalWork/@xml:id
    return map {
    'type' : 'Œuvre',
    'authors' : getBiblAuthors($bibliographicalWork, $lang),
    'titles' : getBiblTitles($bibliographicalWork, $lang),
    'tei' : $bibliographicalWork,
    'expressions' : getBiblExpressions($bibliographicalWork, $lang),
    'manifestations' : getBiblManifestations($bibliographicalWork, $lang),
    'uuid' : $uuid,
    'path' : '/bibliography/works/',
    'url' : $test.globals:root || '/bibliography/works/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};
 
(:~
 : this function get the bibliographical work by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo clean the meta
 :)
declare function getBibliographicalWork($queryParams as map(*)) as map(*) {
  let $workId := map:get($queryParams, 'workId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalWork := $bibliography//tei:bibl[@xml:id = $workId ]
  let $meta := map{
    'title' : 'Œuvre', 
    'author' : getAuthors($bibliography, $lang),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : $bibliographicalWork,
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : getUrl($bibliographicalWork/@xml:id, '/bibliography/works/', $lang) 
    }
  let $uuid := $bibliographicalWork/@xml:id
  let $content := map {
    'type' : 'Œuvre',
    'authors' : getBiblAuthors($bibliographicalWork, $lang),
    'titles' : getBiblTitles($bibliographicalWork, $lang),
    'expressions' : getBiblExpressions($bibliographicalWork, $lang),
    'manifestations' : getBiblManifestations($bibliographicalWork, $lang),
    'tei' : $bibliographicalWork,
    'uuid' : $uuid,
    'path' : '/bibliography/works/',
    'url' : $test.globals:root || '/bibliography/works/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the bibliographical expressions list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo check why double title elements
 :)
declare function getBibliographicalExpressionsList($queryParams) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalExpressions := $bibliography//tei:biblStruct[@type='expression']
  let $meta := map{
    'title' : 'Liste des expressions',
    'quantity' : getQuantity($bibliographicalExpressions, 'expression', 'expressions'),
    'author' : getAuthors($bibliography, $lang),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : 'Liste des expressions de la bibliographie des Guides de Paris, au sens des FRBR',
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : $test.globals:root || '/bibliography/expressions'
    }
  let $content := 
    for $bibliographicalExpression in $bibliographicalExpressions 
    let $uuid := $bibliographicalExpression/@xml:id
    return map {
    'type' : 'Expression',
    'authors' : getBiblAuthors($bibliographicalExpression, $lang),
    'titles' : getBiblTitles($bibliographicalExpression, $lang),
    'dates' : getBiblDates($bibliographicalExpression, $dateFormat),
    'notes' : array{},
    'tei' : $bibliographicalExpression,
    'uuid' : $uuid,
    'path' : '/bibliography/expressions/',
    'url' : $test.globals:root || '/bibliography/expressions/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the bibliographical expression by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getBibliographicalExpression($queryParams) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalExpression := $bibliography//tei:biblStruct[@type='expression'][@xml:id = $queryParams?expressionId]
  let $meta := map{
    'title' : 'Expression',
    'author' : getAuthors($bibliography, $lang),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : $bibliographicalExpression,
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : getUrl($bibliographicalExpression/@xml:id, '/bibliography/expressions/', $lang) 
    }
  let $uuid := $bibliographicalExpression/@xml:id
  let $content := map {
    'type' : 'Expression',
    'authors' : getBiblAuthors($bibliographicalExpression, $lang),
    'titles' : getBiblTitles($bibliographicalExpression, $lang),
    'dates' : getDate($bibliographicalExpression, $dateFormat),
    'manifestations' : array{
      getBiblManifestations($bibliographicalExpression, $lang)
      },
    'tei' : $bibliographicalExpression,
    'uuid' : $uuid,
    'path' : '/bibliography/expressions/',
    'url' : $test.globals:root || '/bibliography/expressions/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the bibliographical manifestation list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getBibliographicalManifestationsList($queryParams) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalManifestations := $bibliography//tei:biblStruct[@type='manifestation']
  let $meta := map{
    'title' : 'Liste des manifestations',
    'quantity' : getQuantity($bibliographicalManifestations, 'manifestation', 'manifestations'),
    'author' : getAuthors($bibliography, $lang),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : 'Liste des manifestations de la bibliographie des Guides de Paris, au sens des FRBR',
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : $test.globals:root || '/bibliography/manifestations'
    }
  let $content := 
    for $bibliographicalManifestation in $bibliographicalManifestations 
    let $uuid := $bibliographicalManifestation/@xml:id
    return map {
    'type' : 'Manifestation',
    'authors' : getBiblAuthors($bibliographicalManifestation, $lang),
    'titles' : getBiblTitles($bibliographicalManifestation, $lang),
    'dates' : getBiblDates($bibliographicalManifestation, $dateFormat),
    'tei' : $bibliographicalManifestation,
    'uuid' : $uuid,
    'path' : '/bibliography/manifestations/',
    'url' : $test.globals:root || '/bibliography/manifestations/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the bibliographical manifestation by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @bug doesnt always bring authors, url properly
 :)
declare function getBibliographicalManifestation($queryParams) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalManifestation := $bibliography//tei:biblStruct[@type='manifestation'][@xml:id = $queryParams?manifestationId]
  let $meta := map{
    'title' : 'Manifestation',
    'author' : getAuthors($bibliography, $lang),
    (: 'copyright' : getCopyright($bibliography, $lang), :)
    'description' : $bibliographicalManifestation,
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : getUrl($bibliographicalManifestation/@xml:id, '/bibliography/manifestations/', $lang)
    }
  let $uuid := $bibliographicalManifestation/@xml:id
  let $content := map {
    'authors' : getBiblAuthors($bibliographicalManifestation, $lang),
    'titles' : getBiblTitles($bibliographicalManifestation, $lang),
    'dates' : getBiblDates($bibliographicalManifestation, $dateFormat),
    (:'items' : array{
          getBiblItems($bibliographicalManifestation, $lang)
          },:)
    'tei' : $bibliographicalManifestation,
    'editeur' : $bibliographicalManifestation/tei:monogr/tei:imprint/tei:publisher,
    'lieu' : $bibliographicalManifestation/tei:monogr/tei:imprint/tei:pubPlace,
    'extent' : fn:normalize-space($bibliographicalManifestation/tei:monogr/tei:extent),
    'idno' : array{
      for $idno in $bibliographicalManifestation/tei:idno[@type='catBnf']
      return map { 'type' : 'catBnf', 'url' : $idno}
      },
    'notes' : array{$bibliographicalManifestation/tei:note},
    'uuid' : $uuid,
    'path' : '/bibliography/manifestations/',
    'url' : $test.globals:root || '/bibliography/manifestations/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the bibliographical item list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getBibliographicalItemsList($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalItems := $bibliography//tei:biblStruct[@type='item']
  let $meta := map{
    'title' : 'Liste des items bibliographiques', 
    'quantity' : getQuantity($bibliographicalItems, 'item', 'items'),
    'author' : getAuthors($bibliography, $lang),
    'copyright' : getCopyright($bibliography, $lang),
    'description' : getDescription($bibliography, $lang),
    'keywords' : array{getKeywords($bibliography, $lang)},
    'url' : $test.globals:root || '/bibliography/items'
    }
  let $content := 
    for $bibliographicalItem in $bibliographicalItems 
    let $uuid := $bibliographicalItem/@xml:id
    return map {
    'type' : 'Item bibliographique',
    'authors' : getBiblAuthors($bibliographicalItem, $lang),
    'titles' : getBiblTitles($bibliographicalItem, $lang),
    'dates' : getBiblDates($bibliographicalItem, $dateFormat),
    'tei' : $bibliographicalItem,
    'uuid' : $uuid,
    'path' : '/bibliography/items/',
    'url' : $test.globals:root || '/bibliography/items/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};
 
(:~
 : this function get the bibliographical item by ID
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo everywhere in biblio arrays for titles and authors ?
 :)
declare function getBibliographicalItem($queryParams as map(*)) as map(*) {
  let $bibliographicalItemId := map:get($queryParams, 'itemId')
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $bibliography := synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id='gdpBibliography']]
  let $bibliographicalItem := $bibliography//tei:biblStruct[@type='item'][@xml:id=$bibliographicalItemId]
  let $meta := map{
    'title' : 'Item bibliographique',
    'author' : getAuthors($bibliographicalItem, $lang),
    'copyright' : getCopyright($bibliographicalItem, $lang),
    'description' : getDescription($bibliographicalItem, $lang),
    'keywords' : array{getKeywords($bibliographicalItem, $lang)}
    }
  let $uuid := $bibliographicalItem/@xml:id
  let $content := map {
    'authors' : getBiblAuthors($bibliographicalItem, $lang),
    'titles' : getBiblTitles($bibliographicalItem, $lang),
    'dates' : getDate($bibliographicalItem, $dateFormat),   
    'tei' : $bibliographicalItem,
    'uuid' : $uuid,
    'path' : '/bibliography/items/',
    'url' : $test.globals:root || '/bibliography/items/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the advanced search results
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo deal with sections levels
 : @todo add a synopsx getIndexDb function
 : @todo search on head
 :)
declare function getSearch($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $combining := $queryParams?combining
  let $primaryResults := if ($queryParams?search = '') then ''
    else if ($queryParams?exact) then getSearchExact($queryParams)
    else if ($combining = "any") then getSearchAny($queryParams)
    else if ($combining = "all words") then getSearchAllWord($queryParams)
    else if ($combining = "phrase") then getSearchPhrase($queryParams)
    else getSearchAll($queryParams)
  let $results :=
    if (fn:count($queryParams?filterPersons) or fn:count($queryParams?filterPlaces) or fn:count($queryParams?filterObjects))
    then getFilteredResults($primaryResults, $queryParams)
    else $primaryResults
  let $meta := map{
    'title' : 'Résultats de la recherche',
    'author' : 'Guides de Paris',
    'referer' : $queryParams?referer,
    'search' : $queryParams?search,
    'start' : $queryParams?start,
    'count' : $queryParams?count,
    'combining' : $queryParams?combining,
    'type' : $queryParams?type,
    'text' : $queryParams?text,
    'quantity' : getQuantity($results, 'résultat', 'résultats'),
    'filters' : map{
      'persons' : array{ getDistinctFilters($results?indexes?persons?uuid, map{ 'filter' : 'persons' }) },
      'places' : array{ getDistinctFilters($results?indexes?places?uuid, map{ 'filter' : 'places' }) },
      'objects' : array{ getDistinctFilters($results?indexes?objects?uuid, map{ 'filter' : 'objets' }) },
      'texts' : array{ getDistinctFilters($results?textId, map{'filter' : 'texts'}) }
      (:'places' : array{ getDistinctMaps($results?indexes?places, map{}) },
      'objects' : array{ getDistinctMaps($results?indexes?objects, map{}) }:)
      }
    }
  let $content := fn:subsequence($results, $queryParams?start, $queryParams?count)
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:
 : todo suppress @xml:id on search content
 :)
declare function getSearchExact($queryParams) {
  let $gdpFtIndex := db:open('gdpFtIndex')
  let $gdp := db:open('test')
  (: for $result score $s in $gdpFtIndex//tei:div[@type="section" or @type="item"]/tei:p :)
  let $db :=
    if ($queryParams?type = 'none')
    then db:open('gdpFtIndex')
    else db:open('test')
  let $content := if ($queryParams?text = 'all' and $queryParams?type = 'none') then $db//*:p[@xml:id]
    else if ($queryParams?text != 'all' and $queryParams?type = 'none') then $db//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]//*:p[@xml:id]
    else if ($queryParams?text = 'all' and $queryParams?type = 'persons') then $db//*:p[@xml:id]//*:persName
    else if ($queryParams?text = 'all' and $queryParams?type = 'places') then $db//*:p[@xml:id]//*:placeName
    else if ($queryParams?text = 'all' and $queryParams?type = 'objects') then $db//*:p[@xml:id]//*:objectName
    else if ($queryParams?text != 'all' and $queryParams?type = 'persons') then $db//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]//*:p[@xml:id]//*:persName
    else if ($queryParams?text != 'all' and $queryParams?type = 'places') then $db//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]//*:p[@xml:id]//*:placeName
    else if ($queryParams?text != 'all' and $queryParams?type = 'objects') then $db//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]//*:p[@xml:id]//*:objectName
  (:let $content :=
    let $texts :=
      if ($queryParams?text = 'none') then db:open('test')
      else db:open('test')//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]
    return if ($queryParams?type = 'all') then $texts//*:p[@xml:id]
    else if ($queryParams?type = 'persons') then $texts//*:p[@xml:id]//*:persName
    else if ($queryParams?type = 'places') then $texts//*:p[@xml:id]//*:placeName
    else if ($queryParams?type = 'objects') then $texts//*:p[@xml:id]//*:objectName:)
  for $result score $s in $content[
    text() contains text {$queryParams?search}
    all
    using case insensitive
    using diacritics insensitive
    using stemming
    using fuzzy
    ]
  (:let $textId := getTextId($result):)
  (: todo check the use of ancestor::tei:div/@xml:id instead of parent::*/@xml:id :)
  group by $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $segment := $gdp//*[@xml:id=$uuid]
  let $textId := getTextIdWithRegex($segment)
  let $date := fn:substring($textId, fn:string-length($textId) - 3)
  let $title := getSectionTitle($segment)
  let $size := getWordsCount($segment, map{})
  let $score := fn:sum($s)
  order by
    if ($queryParams?sort = 'size') then $size?quantity else () descending,
    if ($queryParams?sort = 'title') then fn:string-join($title, ' ') else () ascending,
    if ($queryParams?sort = 'date') then $date else () ascending,
    if ($queryParams?sort = 'score') then $score else () descending
  return map {
    'title' : $title,
    'extract' : ft:extract($result[text() contains text {$queryParams?search}]),
    'textId' : $textId,
    'date' : $date,
    'score' : $score,
    'indexes' : getIndexEntries($segment),
    'pages' : getPages($segment, map{}),
    'size' : getWordsCount($segment, map{}),
    'uuid' : $uuid => xs:string(),
    'path' : '/items/',
    'url' : $test.globals:root || '/items/' || $uuid,
    'combining' : 'exact'
  }
};

declare function getSearchAny($queryParams) {
  let $gdpFtIndex := db:open('gdpFtIndex')
  let $gdp := db:open('test')
  let $texts := if ($queryParams?text = 'all')
    then db:open('gdpFtIndex')
    else db:open('gdpFtIndex')//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]
  for $result score $s in $texts//*:p[@xml:id][
    text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}
    any
    using case insensitive
    using diacritics insensitive
    using stemming
    using fuzzy
    ]
  (:let $textId := getTextId($result):)
  (: todo check the use of ancestor::tei:div/@xml:id instead of parent::*/@xml:id :)
  group by $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $segment := $gdp//*[@xml:id=$uuid]
  let $textId := getTextIdWithRegex($segment)
  let $date := fn:substring($textId, fn:string-length($textId) - 3)
  let $title := getSectionTitle($segment)
  let $size := getWordsCount($segment, map{})
  let $score := fn:sum($s)
  order by
    if ($queryParams?sort = 'size') then $size?quantity else () descending,
    if ($queryParams?sort = 'title') then fn:string-join($title, ' ') else () ascending,
    if ($queryParams?sort = 'date') then $date else () ascending,
    if ($queryParams?sort = 'score') then $score else () descending
  return map {
    'title' : $title,
    'extract' : ft:extract($result[text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}]),
    'textId' : $textId,
    'date' : $date,
    'score' : $score,
    'indexes' : getIndexEntries($segment),
    'pages' : getPages($segment, map{}),
    'size' : $size,
    'uuid' : $uuid => xs:string(),
    'path' : '/items/',
    'url' : $test.globals:root || '/items/' || $uuid,
    'combining' : 'any'
  }
};

declare function getSearchAllWord($queryParams) {
  let $gdpFtIndex := db:open('gdpFtIndex')
  let $gdp := db:open('test')
  let $texts := if ($queryParams?text = 'all')
    then db:open('gdpFtIndex')
    else db:open('gdpFtIndex')//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]
  for $result score $s in $texts//*:p[@xml:id][
    text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}
    all words
    using case insensitive
    using diacritics insensitive
    using stemming
    using fuzzy
    ]
  (:let $textId := getTextId($result):)
  (: todo check the use of ancestor::tei:div/@xml:id instead of parent::*/@xml:id :)
  group by $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $segment := $gdp//*[@xml:id=$uuid]
  let $textId := getTextIdWithRegex($segment)
  let $date := fn:substring($textId, fn:string-length($textId) - 3)
  let $title := getSectionTitle($segment)
  let $size := getWordsCount($segment, map{})
  let $score := fn:sum($s)
  order by
    if ($queryParams?sort = 'size') then $size?quantity else () descending,
    if ($queryParams?sort = 'title') then fn:string-join($title, ' ') else () ascending,
    if ($queryParams?sort = 'date') then $date else () ascending,
    if ($queryParams?sort = 'score') then $score else () descending
  return map {
    'title' : $title,
    'extract' : ft:extract($result[text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}]),
    'textId' : $textId,
    'date' : $date,
    'score' : $score,
    'indexes' : getIndexEntries($segment),
    'pages' : getPages($segment, map{}),
    'size' : $size,
    'uuid' : $uuid => xs:string(),
    'path' : '/items/',
    'url' : $test.globals:root || '/items/' || $uuid
  }
};

declare function getSearchPhrase($queryParams) {
  let $gdpFtIndex := db:open('gdpFtIndex')
  let $gdp := db:open('test')
  let $texts := if ($queryParams?text = 'all')
    then db:open('gdpFtIndex')
    else db:open('gdpFtIndex')//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]
  for $result score $s in $texts//*:p[@xml:id][
    text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}
    phrase
    using case insensitive
    using diacritics insensitive
    using stemming
    using fuzzy
    ]
  (:let $textId := getTextId($result):)
  (: todo check the use of ancestor::tei:div/@xml:id instead of parent::*/@xml:id :)
  group by $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $segment := $gdp//*[@xml:id=$uuid]
  let $textId := getTextIdWithRegex($segment)
  let $date := fn:substring($textId, fn:string-length($textId) - 3)
  let $title := getSectionTitle($segment)
  let $size := getWordsCount($segment, map{})
  let $score := fn:sum($s)
  order by
    if ($queryParams?sort = 'size') then $size?quantity else () descending,
    if ($queryParams?sort = 'title') then fn:string-join($title, ' ') else () ascending,
    if ($queryParams?sort = 'date') then $date else () ascending,
    if ($queryParams?sort = 'score') then $score else () descending
  return map {
    'title' : $title,
    'extract' : ft:extract($result[text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}]),
    'textId' : $textId,
    'date' : $date,
    'score' : $score,
    'indexes' : getIndexEntries($segment),
    'pages' : getPages($segment, map{}),
    'size' : $size,
    'uuid' : $uuid => xs:string(),
    'path' : '/items/',
    'url' : $test.globals:root || '/items/' || $uuid,
    'combining' : 'phrase'
  }
};

declare function getSearchAll($queryParams) {
  let $gdpFtIndex := db:open('gdpFtIndex')
  let $gdp := db:open('test')
  let $texts := if ($queryParams?text = 'all')
    then db:open('gdpFtIndex')
    else db:open('gdpFtIndex')//*[tei:teiHeader/tei:fileDesc/tei:sourceDesc[@xml:id = $queryParams?text]]
  for $result score $s in $texts//*:p[@xml:id][
    text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}
    all
    using case insensitive
    using diacritics insensitive
    using stemming
    using fuzzy
    ]
  (:let $textId := getTextId($result):)
  (: todo check the use of ancestor::tei:div/@xml:id instead of parent::*/@xml:id :)
  group by $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $uuid := $result/ancestor::tei:div[1]/@xml:id
  let $segment := $gdp//*[@xml:id=$uuid]
  let $textId := getTextIdWithRegex($segment)
  let $date := fn:substring($textId, fn:string-length($textId) - 3)
  let $title := getSectionTitle($segment)
  let $size := getWordsCount($segment, map{})
  let $score := fn:sum($s)
  order by
    if ($queryParams?sort = 'size') then $size?quantity else () descending,
    if ($queryParams?sort = 'title') then fn:string-join($title, ' ') else () ascending,
    if ($queryParams?sort = 'date') then $date else () ascending,
    if ($queryParams?sort = 'score') then $score else () descending
  return map {
    'title' : $title,
    'extract' : ft:extract($result[text() contains text {for $w in fn:tokenize($queryParams?search, ' ') return $w}]),
    'textId' : $textId,
    'date' : $date,
    'score' : $score,
    'indexes' : getIndexEntries($segment),
    'pages' : getPages($segment, map{}),
    'size' : $size,
    'uuid' : $uuid => xs:string(),
    'path' : '/items/',
    'url' : $test.globals:root || '/items/' || $uuid,
    'combining' : 'all'
  }
};

(:
for $result score $s in $data[text() contains text {$search}
        all words
        using case insensitive
        using diacritics insensitive
        using stemming
        using fuzzy
        ordered distance at most 5 words]
      order by $s descending
:)

(:~
 : this function get the index list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getIndexList($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $data := (synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'gdpIndexNominum'], synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'gdpIndexLocorum'], synopsx.models.synopsx:getDb($queryParams)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'gdpIndexOperum'])
  let $meta := map{
    'title' : 'Liste des index',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($data, 'index', 'index')
    }
  let $content := 
    for $entry in $data
    let $uuid := fn:replace($entry//tei:fileDesc/tei:sourceDesc/@xml:id, 'gdpI', 'i')
    return map {
      'title' : $entry//tei:fileDesc/tei:titleStmt/tei:title,
      'uuid' : fn:string($uuid),
      'path' : '/',
      'url' : $test.globals:root || '/' || $uuid
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the index locorum
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getIndexLocorum($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $data := if ($queryParams?text = 'all')
      then synopsx.models.synopsx:getDb($queryParams)//tei:listPlace/tei:place[@xml:id]
      else synopsx.models.synopsx:getDb($queryParams)//tei:listPlace/tei:place[@xml:id][tei:listRelation/tei:relation/@type = $queryParams?text]
  (: let $data := synopsx.models.synopsx:getDb($queryParams)//tei:listPlace/tei:place[@xml:id] :)
  let $results := if ($queryParams?letter != 'all') then
    for $entry in $data where $entry/tei:placeName[1][fn:starts-with(fn:lower-case(.), fn:lower-case($queryParams?letter))] return $entry
    else $data
  let $meta := map{
    'title' : 'Index des lieux',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($results, 'entrée', 'entrées'),
    'text' : $queryParams?text,
    'start' : $queryParams?start,
    'count' : $queryParams?count,
    'letter' : $queryParams?letter
    }
  let $content :=
    for $entry in $results
    let $uuid := $entry/@xml:id
    return map {
      'title' : $entry/tei:placeName[1],
      'type' : $entry/tei:trait,
      'country' : $entry/tei:country,
      'ville' : $entry/tei:district,
      'geo' : $entry/tei:location/tei:geo,
      'letter' : fn:substring($entry/tei:placeName[1], 1, 1) => fn:lower-case(),
      'texts' : array{ $entry/tei:listRelation/tei:relation/@type ! fn:string(.) },
      'uuid' : fn:string($uuid),
      'path' : '/indexLocorum/',
      'url' : $test.globals:root || '/indexLocorum/' || $uuid
      }
  return  map{
    'meta'    : $meta,
    'content' : fn:subsequence($content, $queryParams?start, $queryParams?count)
    }
};

(:~
 : this function get the index locorum item
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getIndexLocorumItem($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $itemId := map:get($queryParams, 'itemId')
  let $db := synopsx.models.synopsx:getDb($queryParams)
  let $entry := $db//tei:place[@xml:id = $itemId]
  let $meta := map{
    'rubrique' : 'Entrée de l’index de lieux',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($entry, 'occurence', 'occurences')
    }
  let $uuid := $entry/@xml:id
  let $content :=
    map {
      'rubrique' : 'Entrée d’index de lieux',
      'title' : $entry/tei:placeName[1],
      'type' : $entry/tei:trait/tei:label,
      'country' : $entry/tei:country,
      'ville' : $entry/tei:district,
      'geo' : $entry/tei:location/tei:geo,
      'note' : array{$entry/tei:note},
      'autorities' : array{
        for $idno in $entry/tei:idno
        return map{
          'autority' : $idno/@type,
          'identifier' : $idno/node()}
        },
      'uuid' : fn:string($uuid),
      'path' : '/indexLocorum/',
      'url' : $test.globals:root || '/indexLocorum/' || $uuid,
      'occurences' : array{ getOccurences($entry, map{'db' : $db}) }
      }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the index nominum
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 :)
declare function getIndexNominum($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $search := map:get($queryParams, 'search')
  let $data := if ($queryParams?text = 'all')
    then synopsx.models.synopsx:getDb($queryParams)//tei:listPerson/tei:person[@xml:id]
    else synopsx.models.synopsx:getDb($queryParams)//tei:listPerson/tei:person[@xml:id][tei:listRelation/tei:relation/@type = $queryParams?text]
  (:let $data := synopsx.models.synopsx:getDb($queryParams)//tei:listPerson/tei:person[@xml:id]:)
  let $results := if ($queryParams?letter != 'all') then
    for $entry in $data where $entry/tei:persName[1][fn:starts-with(fn:lower-case(.), fn:lower-case($queryParams?letter))] return $entry
    else $data
  let $meta := map{
    'title' : 'Index des personnes',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($results, 'entrée', 'entrées'),
    'text' : $queryParams?text,
    'start' : $queryParams?start,
    'count' : $queryParams?count,
    'letter' : $queryParams?letter
    }
  let $content := 
    for $entry in $results
    let $uuid := $entry/@xml:id
    return map {
      'title' : $entry/tei:persName[1],
      'forename' : $entry/tei:persName/tei:forename,
      'surname' : $entry/tei:persName/tei:surname,
      'birth' : $entry/tei:birth/tei:date,
      'death' : $entry/tei:death/tei:placeName,
      'occupation' : $entry/tei:occupation,
      'letter' : fn:substring($entry/tei:persName[1], 1, 1) => fn:lower-case(),
      'texts' : array{ $entry/tei:listRelation/tei:relation/@type ! fn:string(.) },
      'uuid' : fn:string($uuid),
      'path' : '/indexNominum/',
      'url' : $test.globals:root || '/indexNominum/' || $uuid
      }
  return  map{
    'meta'    : $meta,
    'content' : fn:subsequence($content, $queryParams?start, $queryParams?count)
    }
};

(:~
 : this function get the index nominum item
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo deal with dates according to the serialization
 : @todo deal with orgs
 :)
declare function getIndexNominumItem($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $itemId := map:get($queryParams, 'itemId')
  let $db := synopsx.models.synopsx:getDb($queryParams)
  let $entry := $db//tei:listPerson/tei:person[@xml:id = $itemId]
  let $meta := map{
    'rubrique' : 'Entrée d’index des personnes',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($entry, 'occurence', 'occurences')
    }
  let $uuid := $entry/@xml:id
  let $content :=
    map {
      'rubrique' : 'Entrée de l’index des personnes',
      'title' : $entry/tei:persName[1],
      'forename' : ($entry/tei:persName/tei:forename)[1]/node(),
      'surname' : ($entry/tei:persName/tei:surname)[1]/node(),
      'birthDate' : $entry/tei:birth/tei:date/node(),
      'birthPlace' : $entry/tei:birth/tei:placeName,
      'deathDate' : $entry/tei:death/tei:date/node(),
      'deathPlace' : $entry/tei:death/tei:placeName,
      'sex' : $entry/tei:sex/@value => xs:integer(),
      'occupation' : $entry/tei:occupation/node(),
      'note' : array{$entry/tei:note},
      'autorities' : array{
        for $idno in $entry/tei:idno
        return map{
        'autority' : $idno/@type,
        'identifier' : $idno/node()}
        },
      'uuid' : fn:string($uuid),
      'path' : '/indexNominum/',
      'url' : $test.globals:root || '/indexNominum/' || $uuid,
      'attestedForms' : array{ getAttestedForms($entry, map{'element' : 'person'}) },
      'occurences' : array{ getOccurences($entry, map{'db' : $db}) }
      }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function get the index operum
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content
 : @todo deal with dates according to the serialization
 :)
declare function getIndexOperum($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $data := if ($queryParams?text = 'all')
    then synopsx.models.synopsx:getDb($queryParams)//tei:listObject/tei:object[@xml:id]
    else synopsx.models.synopsx:getDb($queryParams)//tei:listObject/tei:object[@xml:id][tei:listRelation/tei:relation/@type = $queryParams?text]
  (:let $data := synopsx.models.synopsx:getDb($queryParams)//tei:listObject/tei:object[@xml:id]:)
  let $results := if ($queryParams?letter != 'all') then
    for $entry in $data where $entry/tei:objectName[1][fn:starts-with(fn:lower-case(.), fn:lower-case($queryParams?letter))] return $entry
    else $data
  let $meta := map{
    'title' : 'Index des œuvres',
    'author' : 'Guides de Paris',
    'quantity' : getQuantity($results, 'entrée', 'entrées'),
    'text' : $queryParams?text,
    'start' : $queryParams?start,
    'count' : $queryParams?count,
    'letter' : $queryParams?letter
    }
  let $content := 
    for $entry in $results
    let $uuid := $entry/@xml:id
    return map {
      'title' : $entry/tei:objectName[1],
      'type' : $entry//tei:type/tei:label,
      'date' : $entry/tei:date,
      'letter' : fn:substring($entry/tei:objectName[1], 1, 1) => fn:lower-case(),
      'texts' : array{ $entry/tei:listRelation/tei:relation/@type ! fn:string(.) },
      'uuid' : fn:string($uuid),
      'path' : '/indexOperum/',
      'url' : $test.globals:root || '/indexOperum/' || $uuid
      }
  return  map{
    'meta'    : $meta,
    'content' : fn:subsequence($content, $queryParams?start, $queryParams?count)
    }
};

(:~
 : this function get the index operum item
 :
 : @param $queryParams the request params sent by restxq
 : @return a map of two map for meta and content for meta and content
 : @todo deal with dates according to the serialization
 :)
declare function getIndexOperumItem($queryParams as map(*)) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  let $itemId := map:get($queryParams, 'itemId')
  let $db := synopsx.models.synopsx:getDb($queryParams)
  let $entry := $db//tei:object[@xml:id = $itemId]
  let $occurences := $entry/tei:relation[@type="locus"]
  let $meta := map{
    'rubrique' : 'Entrée de l’index des œuvres',
    'author' : 'Guides de Paris',
    'title' : $entry/tei:objectName[1],
    'type' : $entry//tei:type/tei:label,
    'date' : $entry/tei:creation/tei:date,
    'desc' : $entry/tei:desc,
    'quantity' : getQuantity($occurences, 'occurence', 'occurences')
    }
  let $uuid := $entry/@xml:id
  let $content := 
    map {
      'rubrique' : 'Entrée d’index des œuvres',
      'title' : $entry/tei:objectName[1],
      'type' : $entry//tei:type/tei:label,
      'author' : array{
        for $author in $entry/tei:creation/tei:author
        let $refUuid := fn:substring-after($author/@ref, '#')
        return map{
          'name' : <tei:persName>{getName($author, $lang)}</tei:persName>,
          'uuid' : $refUuid,
          'path' : '/indexNominum/',
          'url' : $test.globals:root || '/indexNominum/' || $refUuid
          }
        },
      'dates' : $entry/tei:creation/tei:date,
      'location' : $entry/tei:location/tei:address/tei:addrLine,
      'desc' : $entry/tei:desc,
      'note' : array{$entry/tei:note},
      'autorities' : array{
        for $idno in $entry/tei:idno
        return map{
          'autority' : $idno/@type,
          'identifier' : $idno/node()}
        },
      'uuid' : fn:string($uuid),
      'path' : '/items/',
      'url' : $test.globals:root || '/items/' || $uuid,
      'occurences' : array{ getOccurences($entry, map{'db' : $db}) }
      }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : this function create a ref for each named-entity in the corpus
 :)
declare
  %updating
function addId2IndexedEntities($indexId) {
  let $db := db:open('test')
  let $index := $db//tei:TEI[tei:teiHeader//tei:sourceDesc[@xml:id = $indexId]]
  for $occurence in fn:distinct-values($index//tei:listRelation/tei:relation/@passive ! fn:tokenize(., '\s+'))
  let $entries := $index//*[tei:listRelation/tei:relation[fn:contains(@passive, $occurence)]]
  let $element := $db//*[@xml:id = fn:substring-after($occurence, '#')]
  let $values := for $entry in $entries/@xml:id return fn:concat('#', $entry)
  return
    if ($element[fn:not(@ref)])
    then insert node attribute ref { $values } into $element
    else replace value of node $element/@ref with $values
};

(:~
 : this function filtered results
 :
 : @param $primaryResults the results to sort
 : @param $queryParams
 :)
declare function getFilteredResults($primaryResults as map(*)*, $queryParams as map(*)) {
  for $result in $primaryResults
  where
    if ($queryParams?filterPersons != 'all')
    then every $item in $queryParams?filterPersons satisfies $item = $result?indexes?persons?uuid
    else fn:true()
  where
    if ($queryParams?filterPlaces != 'all')
    then every $item in $queryParams?filterPlaces satisfies $item = $result?indexes?places?uuid
    else fn:true()
  where
    if ($queryParams?filterObjects != 'all')
    then every $item in $queryParams?filterObjects satisfies $item = $result?indexes?objects?uuid
    (: then $result?indexes?objects?uuid = $queryParams?filterobjects :)
    else fn:true()
  return $result
};