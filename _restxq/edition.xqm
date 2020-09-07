xquery version "3.0" ;
module namespace carrierAquin.edition = 'carrierAquin.edition' ;

(:~
 : This module is a rest file for a synopsx starter project
 :
 : @version 1.0
 : @date 2020-09
 : @since 2020-09
 : @author OlivierDufault (Université de Montréal)
 : @author emchateau (Université de Montréal)
 :
 : This module uses SynopsX publication framework
 : see https://github.com/ahn-ens-lyon/synopsx
 : It is distributed under the GNU General Public Licence,
 : see http://www.gnu.org/licenses/
 :
 :)

import module namespace rest = 'http://exquery.org/ns/restxq';

import module namespace G = 'synopsx.globals' at '../../../globals.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;

import module namespace carrierAquin.models.tei = "carrierAquin.models.tei" at '../models/tei.xqm' ;

import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../../../mappings/htmlWrapping.xqm' ;
import module namespace carrierAquin.mappings.jsoner = 'carrierAquin.mappings.jsoner' at '../mappings/jsoner.xqm' ;

declare default function namespace 'carrierAquin.edition' ;

(:~
 : this resource function redirect to /home
 :)
declare 
  %rest:path('/carrierAquin')
function index() {
  <rest:response>
    <http:response status="303" message="See Other">
      <http:header name="location" value="/carrierAquin/home"/>
    </http:response>
  </rest:response>
};

(:~
 : resource function for the home
 :
 : @return an html home page for the edition
 :)
declare
  %rest:path('/carrierAquin/home')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function editionHome() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getCorpusList'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'home.xhtml',
    'pattern' : 'incCorpus.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};


(:~
 : resource function for corpus list
 :
 : @return an html representation of the corpus resource
 :)
declare
  %rest:path('/carrierAquin/corpus')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function corpus() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getCorpusList'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incCorpus.xhtml',
    'xquery' : 'tei2html'
    }
  return synopsx.mappings.htmlWrapping:wrapperNew($queryParams, $result, $outputParams)
};

(:~
 : resource function for corpus list
 :
 : @return a json representation of the corpus resource
 :)(:
declare
  %rest:path('/corpus')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
  %output:json("indent=no, escape=yes")
function corpusJson() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getCorpusList'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'xquery' : 'tei2html'
    }
  return carrierAquin.mappings.jsoner:jsoner($queryParams, $result, $outputParams)
};:)

(:~
 : resource function for a corpus ID
 :
 : @param $corpusId the corpus ID
 : @return an html representation of the corpus resource
 :)
declare
  %rest:path('/carrierAquin/corpus/{$corpusId}')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function corpusItem($corpusId as xs:string) {
  let $queryParams := map {
    'corpusId' : $corpusId,
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getCorpusById'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incText.xhtml',
    'xquery' : 'tei2html'
    }
  return synopsx.mappings.htmlWrapping:wrapperNew($queryParams, $result, $outputParams)
};

(:~
 : resource function for a text by ID
 :
 : @param $textId the text ID
 : @return an html representation of the text resource
 :)
declare
  %rest:path('/carrierAquin/texts/{$textId}')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function textItems($textId as xs:string) {
  let $queryParams := map {
    'textId' : $textId,
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getTextById'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incTextItem.xhtml',
    'xquery' : 'tei2html'
    }
  return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};


(:~
 : resource function for text toc by ID
 :
 : @param $textId the text ID
 : @return a json toc of the text
 :)
declare
  %rest:path('/carrierAquin/texts/{$textId}/toc')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function textItemsTocJson($textId as xs:string) {
  let $queryParams := map {
    'textId' : $textId,
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getTocByTextId'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'xquery' : 'tei2html'
    }
  return carrierAquin.mappings.jsoner:jsoner($queryParams, $result, $outputParams)
};

(:~
 : resource function for text pagination
 :
 : @param $textId the text ID
 : @return a json toc of the text
 :)
declare
  %rest:path('/carrierAquin/texts/{$textId}/pagination')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
function textItemsPaginationJson($textId as xs:string) {
  let $queryParams := map {
    'textId' : $textId,
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getPaginationByTextId'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'xquery' : 'tei2html'
    }
  return carrierAquin.mappings.jsoner:jsoner($queryParams, $result, $outputParams)
};

(:~
 : this resource function is a documentation
 : @return an html representation of the bibliographical list
 : @param $pattern a GET param giving the name of the calling HTML tag
 : @todo use this tag !
 :)
declare
  %rest:path('/carrierAquin/model')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function model() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'path' : '/schema/gdpSchemaTEI.odd.xml',
    'model' : 'tei',
    'function' : 'getModel'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'about.xhtml',
    'xquery' : 'tei2html'
    }
  return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};

(:~
 : this resource function is a about page
 : @return an html representation of the bibliographical list
 : @param $pattern a GET param giving the name of the calling HTML tag
 : @todo use this tag !
 :)
declare
  %rest:path('/carrierAquin/about')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function about() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'blog',
    'model' : 'tei',
    'function' : 'getBlogItem',
    'entryId' : 'gdpPresentation2014'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incBlogArticle.xhtml',
    'xquery' : 'tei2html'
    }
  return synopsx.mappings.htmlWrapping:wrapperNew($queryParams, $result, $outputParams)
};

(:~
 : resource function for the index list
 :
 : @return an html list of indexes
 :)
declare
  %rest:path('/carrierAquin/index')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function indexes() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getIndexList'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incIndex.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};

(:~
 : resource function for the indexLocorum
 :
 : @return an html list of indexLocorum entries
 :)
declare
  %rest:path('/carrierAquin/indexLocorum')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function indexLocorum() {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getIndexLocorum'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incIndex.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};

(:~
 : resource function for the indexLocorum item
 :
 : @param $itemId the item ID
 : @return an html representation of an indexLocorum item
 :)
declare
  %rest:path('/carrierAquin/indexLocorum/{$itemId}')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function indexLocorumItem($itemId) {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getIndexLocorumItem',
    'itemId' : $itemId
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incIndexLocorum.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};

(:~
 : resource function for the indexNominum
 :
 : @return a html list of indexNominum entries
 :)
declare
  %rest:path('/carrierAquin/indexNominum')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
  %rest:query-param("start", "{$start}", 1)
  %rest:query-param("count", "{$count}", 100)
  %rest:query-param("text", "{$text}", 'all')
  %rest:query-param("letter", "{$letter}", 'all')
function indexNominum(
  $start as xs:integer,
  $count as xs:integer,
  $text as xs:string*,
  $letter as xs:string
  ) {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei',
    'function' : 'getIndexNominum',
    'start' : $start,
    'count' : $count,
    'text' : $text,
    'letter' : $letter
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incIndex.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};

(:~
 : resource function for the indexNominum item
 :
 : @param $itemId the item ID
 : @return an html representation of an indexNominum item
 :)
declare
  %rest:path('/carrierAquin/indexNominum/{$itemId}')
  %rest:produces('text/html')
  %output:method('html')
  %output:html-version('5.0')
function indexNominumItem($itemId) {
  let $queryParams := map {
    'project' : 'carrierAquin',
    'dbName' : 'carrierAquin',
    'model' : 'tei', 
    'function' : 'getIndexNominumItem',
    'itemId' : $itemId
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout' : 'page.xhtml',
    'pattern' : 'incIndexNominum.xhtml',
    'xquery' : 'tei2html'
    }
    return synopsx.mappings.htmlWrapping:wrapper($queryParams, $result, $outputParams)
};