xquery version "3.0" ;
module namespace test.search = 'test.search' ;

(:~
 : This module is a rest for Paris' guidebooks electronic edition
 :
 : @version 1.0
 : @date 2019-05
 : @since 2019-05 
 : @author emchateau (Cluster Pasts in the Present)
 : @see http://guidesdeparis.net
 :
 : This module uses SynopsX publication framework 
 : see https://github.com/ahn-ens-lyon/synopsx
 : It is distributed under the GNU General Public Licence, 
 : see http://www.gnu.org/licenses/
 :
 : @qst give webpath by dates and pages ?
 :)

import module namespace rest = 'http://exquery.org/ns/restxq';

import module namespace G = 'synopsx.globals' at '../../../globals.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;

import module namespace test.models.tei = "test.models.tei" at '../models/tei.xqm' ;

import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../../../mappings/htmlWrapping.xqm' ;
import module namespace test.mappings.jsoner = 'test.mappings.jsoner' at '../mappings/jsoner.xqm' ;

declare default function namespace 'test.search' ;



(:~
 : This function is a simple search
 : @param $referer a referer
 : @param $search the search string
 : @param $combining the combining method ('all', 'all words', 'any', 'phrase')
 : @param $exact exact search as boolean
 : @param $start start for pagination
 : @param $count count for pagination
 : @param $type searched entities
 : @param $text id of the searched text (corpus or item)
 : @param $sort sort to apply ('date', 'score', 'size'), default = score
 : @param $filterPersons filter with persons id
 : @param $filterPlaces filter with places id
 : @param $filterObjects filter with objects id
 :)
declare
  %rest:path('/search')
  %rest:produces('application/json')
  %output:media-type('application/json')
  %output:method('json')
  %rest:header-param('referer', '{$referer}', 'none')
  %rest:query-param("search", "{$search}", 'none')
  %rest:query-param("combining", "{$combining}", 'all')
  %rest:query-param("exact", "{$exact}", 0)
  %rest:query-param("start", "{$start}", 1)
  %rest:query-param("count", "{$count}", 10)
  %rest:query-param("type", "{$type}", 'none')
  %rest:query-param("text", "{$text}", 'all')
  %rest:query-param("sort", "{$sort}", 'score')
  %rest:query-param("filterPersons", "{$filterPersons}", 'all')
  %rest:query-param("filterPlaces", "{$filterPlaces}", 'all')
  %rest:query-param("filterObjects", "{$filterObjects}", 'all')
function getSearchJson(
    $referer,
    $search as xs:string,
    $combining as xs:string,
    $exact,
    $start as xs:int,
    $count as xs:int,
    $type as xs:string*,
    $text as xs:string*,
    $sort as xs:string,
    $filterPersons as xs:string*,
    $filterPlaces as xs:string*,
    $filterObjects as xs:string*
    ) {
  let $function := 'getSearch'
  let $queryParams := map {
    'project' : 'test',
    'dbName' : 'test',
    'model' : 'tei', 
    'function' : $function,
    'search' : $search,
    'combining' : $combining,
    'exact' : $exact,
    'start' : $start,
    'count' : $count,
    'type' : $type,
    'text' : $text,
    'sort' : $sort,
    'filterPersons' : $filterPersons,
    'filterPlaces' : $filterPlaces,
    'filterObjects' : $filterObjects
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $result := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'xquery' : 'tei2html'
    }
    return test.mappings.jsoner:jsoner($queryParams, $result, $outputParams)
};

(:~
 : resource function for indexing
 :
 : @return add @ref from indexes in the db
 :)
declare
  %rest:path('/indexing')
  %updating
function indexing() {
  let $indexId := ('gdpIndexNominum', 'gdpIndexLocorum')
  for $index in $indexId return test.models.tei:addId2IndexedEntities($index)
};