xquery version '3.0' ;
module namespace test.static = 'test.static' ;

(:~
 : This module is a rest for Paris' guidebooks blog
 :
 : @version 1.0
 : @date 2019-05
 : @since 2015-03-02 
 : @author emchateau (Cluster Pasts in the Present)
 : @see http://guidesdeparis.net
 :
 : This module uses SynopsX publication framework 
 : see https://github.com/ahn-ens-lyon/synopsx
 : It is distributed under the GNU General Public Licence, 
 : see http://www.gnu.org/licenses/
 :
 :)

import module namespace rest = 'http://exquery.org/ns/restxq';
import module namespace G = 'synopsx.globals' at '../../../globals.xqm' ;

declare default function namespace 'test.static' ;

(:~
: resource function for the static files
:
: @param $file file or unknown path
: @return rest response and binary file
:)
declare
%rest:path('/gdp/static/{$file=.+}')
function file($file as xs:string) as item()+ {
  let $path := $G:WORKSPACE || 'gdp/static/' ||  $file
  return (
    web:response-header(map {'media-type' : web:content-type($path) }),
    file:read-binary($path))
};

(:~
 : this function return a mime-type for a specified file
 :
 : @param  $name  file name
 : @return a mime type for the specified file
 :)
declare function mime-type(
  $name  as xs:string
) as xs:string {
  fetch:content-type($name)
};