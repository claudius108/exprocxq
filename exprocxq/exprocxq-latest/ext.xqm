xquery version "1.0" encoding "UTF-8";
module namespace ext = "http://xproc.net/xproc/ext";
(: ------------------------------------------------------------------------------------- 

	ext.xqm - implements all xprocxq specific extension steps.
	
---------------------------------------------------------------------------------------- :)


(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";

declare namespace t = "http://xproc.org/ns/testsuite";


(: Module Imports :)
import module namespace u = "http://xproc.net/xproc/util";

(: -------------------------------------------------------------------------- :)

(: Module Vars :)
declare variable $ext:xslt-client := util:function(xs:QName("ext:xslt-client"), 4);
declare variable $ext:get-post-data := util:function(xs:QName("ext:get-post-data"), 4);
declare variable $ext:get-request-parameter := util:function(xs:QName("ext:get-request-parameter"), 4);
declare variable $ext:xslt-optional := util:function(xs:QName("ext:xslt-optional"), 4);
declare variable $ext:authenticate := util:function(xs:QName("ext:authenticate"), 4);
declare variable $ext:create-collection := util:function(xs:QName("ext:create-collection"), 4);
declare variable $ext:create-resource := util:function(xs:QName("ext:create-resource"), 4);
declare variable $ext:copy-collection := util:function(xs:QName("ext:copy-collection"), 4);
declare variable $ext:copy-resource := util:function(xs:QName("ext:copy-resource"), 4);
declare variable $ext:move-collection := util:function(xs:QName("ext:move-collection"), 4);
declare variable $ext:move-resource := util:function(xs:QName("ext:move-resource"), 4);
declare variable $ext:remove-collection := util:function(xs:QName("ext:remove-collection"), 4);
declare variable $ext:remove-resource := util:function(xs:QName("ext:remove-resource"), 4);
declare variable $ext:create-user := util:function(xs:QName("ext:create-user"), 4);
declare variable $ext:modify-user := util:function(xs:QName("ext:modify-user"), 4);
declare variable $ext:delete-user := util:function(xs:QName("ext:delete-user"), 4);
declare variable $ext:list-child-collections := util:function(xs:QName("ext:list-child-collections"), 4);
declare variable $ext:pre := util:function(xs:QName("ext:pre"), 4);
declare variable $ext:post := util:function(xs:QName("ext:post"), 4);
declare variable $ext:xproc := util:function(xs:QName("ext:xproc"), 4);

(: -------------------------------------------------------------------------- :)
declare function ext:pre($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function ext:post($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function ext:xproc($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
(: NOTE - this function needs to be defined here, but use-function in xproc.xqm :)
    ()
};

(: -------------------------------------------------------------------------- :)
declare function ext:xslt-client($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
(
(:util:declare-option('exist:serialize','method=xhtml media-type=text/xml process-xsl-pi=no indent=no'),:)
processing-instruction {'xml-stylesheet'} {concat('href="',  xs:string(data($options/p:with-option[@name = 'xsl-uri']/@select)), '" type="text/xsl"')},
document{u:get-primary($primary)}
)
};

(: -------------------------------------------------------------------------- :)
declare function ext:get-post-data($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
util:declare-namespace('request',xs:anyURI('http://exist-db.org/xquery/request')),
if (request:get-header('Content-Type') = 'application/x-www-form-urlencoded')
		then
			(
			util:parse(request:get-parameter('postdata', ''))
			)
		else (request:get-data())
};

(: -------------------------------------------------------------------------- :)
declare function ext:get-request-parameter($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
util:declare-namespace('request',xs:anyURI('http://exist-db.org/xquery/request')),
let $request-parameter-name := xs:string(data($options/p:with-option[@name = 'request-parameter-name']/@select))
let $request-parameter-element-name := xs:string(data($options/p:with-option[@name = 'request-parameter-element-name']/@select))
return 
	if ($request-parameter-element-name)
		then (element {$request-parameter-element-name} {request:get-parameter($request-parameter-name, '')})
		else (<c:result>{request:get-parameter($request-parameter-name, '')}</c:result>)
};

(: -------------------------------------------------------------------------- :)
declare function ext:xslt-optional($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $v := u:get-primary($primary)
let $xslURI := xs:string(data($options/p:with-option[@name = 'xslURI']/@select))
return
	if (doc-available($xslURI))
		then (u:xslt(doc($xslURI),$v))
		else ($v)
};

(: -------------------------------------------------------------------------- :)
declare function ext:authenticate($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $collection-uri := xs:string(data($options/p:with-option[@name = 'collection-uri']/@select))
let $user-id := xs:string(data($options/p:with-option[@name = 'user-id']/@select))
let $password := xs:string(data($options/p:with-option[@name = 'password']/@select))
let $login := xmldb:login($collection-uri, $user-id, $password)
return (element {'c:result'} {$login})
};

(: -------------------------------------------------------------------------- :)
declare function ext:create-collection($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $target-collection-uri := xs:string(data($options/p:with-option[@name = 'target-collection-uri']/@select))
let $new-collection := xs:string(data($options/p:with-option[@name = 'new-collection']/@select))
let $create-collection := xmldb:create-collection($target-collection-uri, $new-collection)
return element {'c:result'} {$create-collection}
};

(: -------------------------------------------------------------------------- :)
declare function ext:create-resource($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $collection-uri := xs:string(data($options/p:with-option[@name = 'collection-uri']/@select))
let $resource-name := xs:string(data($options/p:with-option[@name = 'resource-name']/@select))
let $v := u:get-primary($primary)
let $contents := if ($v) then ($v) else (element {'template'} {})
let $mime-type := xs:string(data($options/p:with-option[@name = 'mime-type']/@select))
let $create-resource :=
	if ($mime-type)
		then (xmldb:store($collection-uri, $resource-name, $contents, $mime-type))
		else (xmldb:store($collection-uri, $resource-name, $contents))
return element {'c:result'} {$create-resource}
};

(: -------------------------------------------------------------------------- :)
declare function ext:copy-collection($primary,$secondary,$options,$variables) {
(: -------------------------------------------------------------------------- :)
let $source-collection-uri := xs:string(data($options/p:with-option[@name = 'source-collection-uri']/@select))
let $target-collection-uri := xs:string(data($options/p:with-option[@name = 'target-collection-uri']/@select))
return xmldb:copy($source-collection-uri, $target-collection-uri)
};

(: -------------------------------------------------------------------------- :)
declare function ext:copy-resource($primary,$secondary,$options,$variables) {
(: -------------------------------------------------------------------------- :)
let $resource-uri := xs:string(data($options/p:with-option[@name = 'resource-uri']/@select))
let $source-collection-uri := util:collection-name($resource-uri)
let $resource := substring-after($resource-uri,concat($source-collection-uri,'/'))
let $target-collection-uri := xs:string(data($options/p:with-option[@name = 'target-collection-uri']/@select))
return xmldb:copy($source-collection-uri, $target-collection-uri, $resource)
};

(: -------------------------------------------------------------------------- :)
declare function ext:move-collection($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $source-collection-uri := xs:string(data($options/p:with-option[@name = 'source-collection-uri']/@select))
let $target-collection-uri := xs:string(data($options/p:with-option[@name = 'target-collection-uri']/@select))
return xmldb:move($source-collection-uri, $target-collection-uri)
};

(: -------------------------------------------------------------------------- :)
declare function ext:move-resource($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $resource-uri := xs:string(data($options/p:with-option[@name = 'resource-uri']/@select))
let $source-collection-uri := util:collection-name($resource-uri)
let $resource := substring-after($resource-uri,concat($source-collection-uri,'/'))
let $target-collection-uri := xs:string(data($options/p:with-option[@name = 'target-collection-uri']/@select))
return xmldb:move($source-collection-uri, $target-collection-uri, $resource)
};

(: -------------------------------------------------------------------------- :)
declare function ext:remove-collection($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $collection-uri := xs:string(data($options/p:with-option[@name = 'collection-uri']/@select))
return xmldb:remove($collection-uri)
};

(: -------------------------------------------------------------------------- :)
declare function ext:remove-resource($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $resource-uri := xs:string(data($options/p:with-option[@name = 'resource-uri']/@select))
let $collection-uri := util:collection-name($resource-uri)
let $resource := substring-after($resource-uri,concat($collection-uri,'/'))
return xmldb:remove($collection-uri, $resource)
};

(: -------------------------------------------------------------------------- :)
declare function ext:create-user($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $user-id := xs:string(data($options/p:with-option[@name = 'user-id']/@select))
let $password := xs:string(data($options/p:with-option[@name = 'password']/@select))
let $groups := xs:string(data($options/p:with-option[@name = 'groups']/@select))
let $home-collection-uri := xs:string(data($options/p:with-option[@name = 'home-collection-uri']/@select))
return xmldb:create-user($user-id, $password, $groups, $home-collection-uri)
};

(: -------------------------------------------------------------------------- :)
declare function ext:modify-user($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $user-id := xs:string(data($options/p:with-option[@name = 'user-id']/@select))
let $password := xs:string(data($options/p:with-option[@name = 'password']/@select))
let $groups := xs:string(data($options/p:with-option[@name = 'groups']/@select))
let $home-collection-uri := xs:string(data($options/p:with-option[@name = 'home-collection-uri']/@select))
return xmldb:change-user($user-id, $password, $groups, $home-collection-uri)
};

(: -------------------------------------------------------------------------- :)
declare function ext:delete-user($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $user-id := xs:string(data($options/p:with-option[@name = 'user-id']/@select))
return xmldb:delete-user($user-id)
};

(: -------------------------------------------------------------------------- :)
declare function ext:list-child-collections($primary,$secondary,$options,$variables){
(: -------------------------------------------------------------------------- :)
let $collection-uri := xs:string(data($options/p:with-option[@name = 'collection-uri']/@select))
let $child-collections := xmldb:get-child-collections($collection-uri)
return
		<child-collections>
		{
		for $child-collection in $child-collections
		return element {'collection-name'} {$child-collection}
		}
		</child-collections>
};


(: -------------------------------------------------------------------------- :)





