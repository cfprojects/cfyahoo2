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
			hint="Image search API.">
	<cfargument name="query" type="string" required="true" hint="Query to use with context.">

	<!--- Note will minus 1 from start --->
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position. End postion (start+results) may not exceed 1000.">

	<!--- maps to count argument --->
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">

	<cfargument name="language" type="string" required="false" default="en" hint="Language for results. See supported languages here: http://developer.yahoo.com/search/boss/boss_guide/supp_regions_lang.html">

	<cfargument name="region" type="string" required="false" default="us" hint="Region. Supported regions may be found here: http://developer.yahoo.com/search/boss/boss_guide/supp_regions_lang.html">
	<cfargument name="strictlanguage" type="boolean" required="false" default="false" hint="Setting to true activates the strict language filtering based on the lang parameter defined in the query.">

	<cfargument name="sites" type="string" required="false" default="" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">
	<cfargument name="highlight" type="boolean" required="false" default="true" hint="Will highlight matches in results.">

	<cfargument name="adultfilter" type="boolean" required="false" default="true" hint="If true, adult results are filtered.">

	<cfargument name="dimensions" type="string" required="false" default="all" hint="Valid values are: all,small,medium,large,wallpaper,widewallpaper">

	<cfargument name="refererurl" type="string" required="false" default="" hint="Search for a particular referer url.">
	<cfargument name="url" type="string" required="false" default="" hint="Search for a particular  url.">
	
	<cfset var q = queryNew("abstract,clickurl,date,filename,format,height,mimetype,refererclickurl,refererurl,size,thumbnail_height,thumbnail_url,thumbnail_width,title,url,width,totalavailable")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://boss.yahooapis.com/ysearch/images/v1/">
	<cfset var totalResults = 0>
	<cfset var firstresultposition = 0>
	<cfset var json = "">
	<cfset var x = "">
	<cfset var node = "">
	<cfset var key = "">
	
	<cfif arguments.results lt 1 or arguments.results gt 100>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 100, min is 1.">
	</cfif>

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	

	<cfset theURL = theURL & "#urlEncodedFormat(arguments.query)#/?appid=#getAppId()#">

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

	<cfset theURL = theURL & "&filter=#arguments.adultfilter#">
	<cfset theURL = theURL & "&dimensions=#arguments.dimensions#">
	<cfif len(arguments.refererurl)>
		<cfset theURL = theURL & "&refererurl=#urlEncodedFormat(arguments.refererurl)#">
	</cfif>
	<cfif len(arguments.url)>
		<cfset theURL = theURL & "&url=#urlEncodedFormat(arguments.url)#">
	</cfif>
			
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isJSON(result.fileContent.toString())>
		<cfset json = deserializeJSON(result.fileContent.toString())>
		<cfset totalResults = json.ysearchresponse.totalhits>
		
		<cfloop index="x" from="1" to="#json.ysearchresponse.count#">
			
			<cfset node = json.ysearchresponse.resultset_images[x]>

			<cfset node.totalavailable = totalResults>

			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#node#">
				<cfset querySetCell(q, key, node[key])>
			</cfloop>

		</cfloop>
	</cfif>

	<cfreturn q>
</cffunction>

</cfcomponent>