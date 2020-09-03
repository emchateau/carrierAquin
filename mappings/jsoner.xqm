xquery version '3.0' ;
module namespace test.mappings.jsoner = 'test.mappings.jsoner' ;

(:~
 : This module is an JSON mapping for templating
 :
 : @version 3.0
 : @author emchateau (Université de Montréal)
 : @date 2019-05
 : @since 2017-07-07
 : @author synopsx’s team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :
 :)

import module namespace G = "synopsx.globals" at '../../../globals.xqm' ;
import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;
import module namespace synopsx.mappings.tei2html = 'synopsx.mappings.tei2html' at '../../../mappings/tei2html.xqm' ;

declare namespace html = 'http://www.w3.org/1999/xhtml' ;

declare default function namespace 'test.mappings.jsoner' ;

(:~
 : this function wrap the content in an HTML layout
 :
 : @param $queryParams the query params defined in restxq
 : @param $data the result of the query
 : @param $outputParams the serialization params
 : @return an updated HTML document and instantiate pattern
 : @todo treat in the same loop @* and text() ?
 @todo add handling of outputParams (for example {class} attribute or call to an xslt)
 :)
declare function jsoner($queryParams as map(*), $data as map(*), $outputParams as map(*)) {
  let $contents := map:get($data, 'content')
  let $meta := map:get($data, 'meta')
  return map{
    'meta' : sequence2ArrayInMap($queryParams, $meta, $outputParams),
    'content' : if (fn:count($contents) > 1) then array{
        for $content in $contents
        return sequence2ArrayInMap($queryParams, $content, $outputParams)
        }
        (:
        else sequence2ArrayInMap($queryParams, $contents, $outputParams)
        :)
        (: for debug :)
        else if (fn:count($contents) = 0)
          then 'vide'
          else sequence2ArrayInMap($queryParams, $contents, $outputParams)
    }
};

(:~
 : this function transforms a map into a map with arrays
 :
 : @param $map the map to convert
 : @return a map with array instead of sequences
 : @rmq deals only with right keys
 :)
declare function sequence2ArrayInMap($queryParams, $map as map(*), $outputParams) as map(*) {
  map:merge((
    map:for-each(
      $map,
      function($a, $b) {
        map:entry(
          $a ,
          if (fn:count($b) > 1)
          then array{ dispatch($b, $queryParams, $outputParams) }
          else dispatch($b, $queryParams, $outputParams)
        )
      }
    )
  ))
};

declare function dispatch($b as item()*, $queryParams, $outputParams) {
  typeswitch($b)
    case empty-sequence() return ()
    case map(*)+ return $b ! sequence2ArrayInMap($queryParams, ., $outputParams)
    case xs:string return $b
    case xs:string+ return $b
    (: case xs:anyAtomicType return fn:data($b)
    case xs:anyAtomicType+ return $b ! fn:data(.) :)
    case xs:integer return fn:data($b)
    case xs:double return fn:format-number($b, "0.00")
    case array(*) return array:for-each($b, function($i){
      dispatch($i, $queryParams, $outputParams)
    })
    case attribute() return fn:string($b)
    case text() return fn:string($b)
    default return render($queryParams, $outputParams, $b)/node()
      => fn:serialize(map {'method' : 'html'})
};

declare function recurse($queryParams, $map as map(*), $outputParams) {
  sequence2ArrayInMap($queryParams, $map, $outputParams)
};

(:~
 : this function dispatch the rendering based on $outpoutParams
 :
 : @param $value the content to render
 : @param $outputParams the serialization params
 : @return an html serialization
 :
 : @todo check the xslt with an xslt 1.0
 : @todo select the xquery transformation from xqm
 :)
declare function render($queryParams as map(*), $outputParams as map(*), $value as item()* ) as item()* {
  let $xquery := map:get($outputParams, 'xquery')
  let $xsl :=  map:get($outputParams, 'xsl')
  let $options := map{
    'lb' : map:get($outputParams, 'lb')
    }
  let $params := map:get($outputParams, 'params')
  return
    if ($xquery)
      then synopsx.mappings.tei2html:entry($value, $options)
    else if ($xsl)
      then for $node in $value
           return
               if (fn:empty($params) )
                 then xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $xsl))
                 else xslt:transform($node, synopsx.models.synopsx:getXsltPath($queryParams, $xsl), $params)
      else $value
};