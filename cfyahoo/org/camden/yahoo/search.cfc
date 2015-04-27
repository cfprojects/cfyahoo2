<!---
LICENSE 
Copyright 2010 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->

<cfcomponent output="false" extends="base">

<cffunction name="search" returnType="query" output="false" access="public"
			hint="Main search API.">
	<cfargument name="query" type="string" required="true" hint="Search terms.">
	
	<!--- Note will minus 1 from start --->
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position. End postion (start+results) may not exceed 1000.">

	<!--- maps to count argument --->
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">

	<cfargument name="language" type="string" required="false" default="en" hint="Language for results. See supported languages here: http://developer.yahoo.com/search/boss/boss_guide/supp_regions_lang.html">

	<cfargument name="region" type="string" required="false" default="us" hint="Region. Supported regions may be found here: http://developer.yahoo.com/search/boss/boss_guide/supp_regions_lang.html">
	<cfargument name="strictlanguage" type="boolean" required="false" default="false" hint="Setting to true activates the strict language filtering based on the lang parameter defined in the query.">

	<cfargument name="sites" type="string" required="false" default="" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">
	<cfargument name="highlight" type="boolean" required="false" default="true" hint="Will highlight matches in results.">

	<cfargument name="longabstract" type="boolean" required="false" default="false" hint="If passed as true, a longer abstract is returned.">
	<cfargument name="adult" type="string" required="false" default="" hint="Can be -porn or -hate or both. Filters out porn/hate results.">
	<cfargument name="format" type="string" required="false" default="" hint="File formats to search. Valid values are: html,text,pdf,xl,msword,ppt,msoffice,nonhtml You can also use a group minus one format, like msoffice,-ppt.">
	
	<cfset var q = queryNew("abstract,clickurl,date,displayurl,size,title,url,totalavailable")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://boss.yahooapis.com/ysearch/web/v1">
	<cfset var totalResults = 0>
	<cfset var x = "">
	<cfset var node = "">
	<cfset var json = "">
	
	<cfset theURL = theURL & "/#urlEncodedFormat(arguments.query)#">
	<cfset theURL = theURL & "?appid=" & getAppID()>
	<cfif arguments.start lt 1>
		<cfthrow message="Invalid start (#arguments.start#) passed. Minimum value is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start-1#">
	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&count=#arguments.results#">

	
	<cfset theURL = theURL & "&region=#urlEncodedFormat(arguments.region)#">
	<cfset theURL = theURL & "&lang=#urlEncodedFormat(arguments.language)#">
	
	<cfif arguments.strictLanguage>
		<cfset theURL = theURL & "&strictlang=1">
	</cfif>

		
	<cfif len(arguments.sites)>
		<cfset theURL = theURL & "&sites=#urlEncodedFormat(arguments.site)#">
	</cfif>

	<cfif not arguments.highlight>
		<cfset theURL = theURL & "&style=raw">
	</cfif>

	<cfif len(arguments.adult)>
		<cfset theURL = theURL & "&filter=#urlEncodedFormat(arguments.adult)#">
	</cfif>

	<cfif len(arguments.format)>
		<cfset theURL = theURL & "&type=#arguments.format#">
	</cfif>
	
	<cfif arguments.longabstract>
		<cfset theURL = theURL & "&abstract=long">
	</cfif>

	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif result.responseheader.status_code is 403>
		<cfthrow message="Forbidden response. Please check the API code.">
	</cfif>
	
	<cfset json = deserializeJSON(result.fileContent.toString())>
	<!---<cfdump var="#json#" label="#theURL#"><cfabort>--->

	<cfset totalResults = json.ysearchresponse.totalhits>
		
	<cfloop index="x" from="1" to="#json.ysearchresponse.count#">
		<cfset node = json.ysearchresponse.resultset_web[x]>

		<cfset queryAddRow(q)>
		<cfset querySetCell(q, "title", node.title)>
		<cfset querySetCell(q, "abstract", node.abstract)>
		<cfset querySetCell(q, "clickurl", node.clickurl)>
		<cfset querySetCell(q, "date", node.date)>
		<cfset querySetCell(q, "displayurl", node.dispurl)>
		<cfset querySetCell(q, "size", node.size)>
		<cfset querySetCell(q, "url", node.url)>
		<cfset querySetCell(q, "totalavailable", totalResults)>
	</cfloop>

	<cfreturn q>
</cffunction>

<cffunction name="spellingSuggestion" returnType="array" output="false" access="public"
			hint="Retrieves spelling suggestions.">
	<cfargument name="query" type="string" required="true" hint="Word to use.">
	<cfset var result = "">
	<cfset var json = "">
	<cfset var theURL = "http://boss.yahooapis.com/ysearch/spelling/v1/">	
	<cfset var suggestions = arrayNew(1)>
	<cfset var x = "">

	<cfset theURL = theURL & "#urlEncodedFormat(arguments.query)#/">
	
	<cfset theURL = theURL & "?appid=" & getAppID()>

	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif result.responseheader.status_code is 403>
		<cfthrow message="Forbidden response. Please check the API code.">
	</cfif>
	
	<cfset json = deserializeJSON(result.fileContent.toString())>

	<cfif json.ysearchresponse.totalhits gt 0>
		<cfloop index="x" from="1" to="#arraylen(json.ysearchresponse.resultset_spell)#">
			<cfset arrayAppend(suggestions, json.ysearchresponse.resultset_spell[x].suggestion)>
		</cfloop>
	</cfif>
		
	<cfreturn suggestions>
</cffunction>

</cfcomponent>