xquery version '3.0' ;
module namespace test.globals = 'test.globals' ;

(:~
 : This module is a Config file for a synopsx starter project
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


 (: declare variable $gdp.globals:root := 'http://guidesdeparis.net' ; :)
 declare variable $test.globals:root := 'http://localhost:8984' ;