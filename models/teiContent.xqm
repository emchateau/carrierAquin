xquery version "3.0" ;
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
import module namespace synopsx.models.tei = 'synopsx.models.tei' at '../../../models/tei.xqm' ;

import module 'test.models.tei' at 'teiBuilder.xqm' ;

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace 'test.models.tei' ;

(:~
 : this function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function getText($item as element()) as map(*) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  return map {
    'title' : getTitles($item, $lang),
    'date' : getDate($item, $dateFormat),
    'author' : getAuthors($item, $lang),
    'abstract' : getAbstract($item, $lang),
    'url' : getUrl($item//tei:sourceDesc/@xml:id, 'texts/', $lang),
    'tei' : $item
  }
};

(:~
 : this function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function getResp($item as element()) {
  let $lang := 'fr'
  return map {
    'name' : getName($item, $lang),
    'resp' : $item//tei:resp/text()
  }
};