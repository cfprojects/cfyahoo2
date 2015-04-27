<!---
	Name         : search.cfc
	Author       : Raymond Camden 
	Created      : October 12, 2006
	Last Updated : December 6, 2007
	History      : Added header.
				 : Add error handling to search (rkc 3/1/07)
				 : Handle cases where cache info isn't returned (rkc 12/6/07)
	Purpose		 : Search API

LICENSE 
Copyright 2006 Raymond Camden

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

<cffunction name="contextSearch" returnType="query" output="false" access="public"
			hint="Contextual search API.">
	<cfargument name="context" type="string" required="true" hint="The context to extract meaning from.">
	<cfargument name="query" type="string" required="true" hint="Query to use with context.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 100.">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position. End postion (start+results) may not exceed 1000.">
	<cfargument name="format" type="string" required="false" default="any" hint="File formats to search. Valid values are: any, html, msword, pdf, ppt, rss, txt, xls">
	<cfargument name="adult" type="boolean" required="false" default="false" hint="If true, adult results may be returned.">
	<cfargument name="similar" type="boolean" required="false" default="false" hint="If true, return similar results.">
	<cfargument name="language" type="string" required="false" hint="Language for results. See supported languages here: http://developer.yahoo.com/search/languages.html">
	<cfargument name="country" type="string" required="false" hint="Country to restricts results. See supported country codes here: http://developer.yahoo.com/search/countries.html">
	<cfargument name="site" type="string" required="false" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">
	<cfargument name="license" type="string" required="false" hint="Creative Commons license to restrict results. Valid values are: any, cc_any, cc_commercial, cc_modifiable. Multiple values may be submitted.">
	<cfset var q = queryNew("title,summary,url,clickurl,mimetype,modificationdate,cacheurl,cachesize,firstresultposition,totalavailable")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://search.yahooapis.com/WebSearchService/V1/contextSearch">
	<cfset var totalResults = 0>
	<cfset var firstresultposition = 0>
	<cfset var x = "">
	<cfset var node = "">
	<cfset var data = "">
	<cfset var key = "">
	
	<cfif arguments.results lt 1 or arguments.results gt 100>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 100, min is 1.">
	</cfif>

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	

	<cfif not listFindNoCase("any,html,msword,pdf,ppt,rss,txt,xls", arguments.format)>
		<cfthrow message="Invalid format (#arguments.format#) passed. Only any, html, msword, pdf, ppt, rss, txt, xls allowed.">
	</cfif>

	<cfif structKeyExists(arguments, "site") and len(arguments.site)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.site))#">
			<cfset theURL = theURL & "&site=#listGetAt(arguments.site,x)#">
		</cfloop>
	</cfif>

	<cfif structKeyExists(arguments, "license") and len(arguments.license)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.license))#">
			<cfset theURL = theURL & "&license=#listGetAt(arguments.license,x)#">
		</cfloop>
	</cfif>
	
	<cfhttp url="#theURL#" result="result" method="post" charset="utf-8">
		<cfhttpparam type="formfield" name="appid" value="#getAppID()#">
		<cfhttpparam type="formfield" name="context" value="#arguments.context#">
		<cfif structKeyExists(arguments, "query")>
			<cfhttpparam type="formfield" name="query" value="#arguments.query#">
		</cfif>
		<cfhttpparam type="formfield" name="results" value="#arguments.results#">		
		<cfhttpparam type="formfield" name="start" value="#arguments.start#">
		<cfhttpparam type="formfield" name="format" value="#arguments.format#">
		<cfhttpparam type="formfield" name="adult_ok" value="#arguments.adult#">
		<cfhttpparam type="formfield" name="similar_ok" value="#arguments.similar#">
		<cfif structKeyExists(arguments, "language")>
			<cfhttpparam type="formfield" name="language" value="#arguments.language#">
		</cfif>
		<cfif structKeyExists(arguments, "country")>
			<cfhttpparam type="formfield" name="country" value="#arguments.country#">
		</cfif>
		
	</cfhttp>

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Context Search API Error: #xmlResult.error.message.xmlText#">
		</cfif>

		<cfset totalResults = xmlResult.resultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResultPosition = xmlResult.resultSet.xmlAttributes.firstResultPosition>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>
			
			<cfset data.totalavailable = totalResults>
			<cfset data.firstResultPosition = firstResultPosition>
			<cfset data.title = node.title.xmltext>
			<cfset data.summary = node.summary.xmltext>
			<cfset data.url = node.url.xmltext>
			<cfset data.clickurl = node.clickurl.xmltext>
			<cfset data.mimetype = node.mimetype.xmltext>
			<cfset data.modificationdate = epochTimeToDate(node.modificationdate.xmlText)>
			<cfset data.cacheurl = node.cache.url.xmlText>
			<cfset data.cachesize = node.cache.size.xmlText>

			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>

		</cfloop>
	</cfif>

	<cfreturn q>
</cffunction>


<cffunction name="search" returnType="query" output="false" access="public"
			hint="Main search API.">
	<cfargument name="query" type="string" required="true" hint="Search terms.">
	<cfargument name="region" type="string" required="false" default="us" hint="Region. Supported regions may be found here: http://developer.yahoo.com/search/regions.html">
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 100.">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position. End postion (start+results) may not exceed 1000.">
	<cfargument name="format" type="string" required="false" default="any" hint="File formats to search. Valid values are: any, html, msword, pdf, ppt, rss, txt, xls">
	<cfargument name="adult" type="boolean" required="false" default="false" hint="If true, adult results may be returned.">
	<cfargument name="similar" type="boolean" required="false" default="false" hint="If true, return similar results.">
	<cfargument name="language" type="string" required="false" default="" hint="Language for results. See supported languages here: http://developer.yahoo.com/search/languages.html">
	<cfargument name="country" type="string" required="false" default="" hint="Country to restricts results. See supported country codes here: http://developer.yahoo.com/search/countries.html">
	<cfargument name="site" type="string" required="false" default="" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">
	<cfargument name="subscription" type="string" required="false" default="" hint="Search premium sites. See supported values here: http://developer.yahoo.com/search/subscriptions.html">
	<cfargument name="license" type="string" required="false" default="" hint="Creative Commons license to restrict results. Valid values are: any, cc_any, cc_commercial, cc_modifiable. Multiple values may be submitted.">
	<cfset var q = queryNew("title,summary,url,clickurl,mimetype,modificationdate,cacheurl,cachesize,totalavailable")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=">
	<cfset var totalResults = 0>
	<cfset var x = "">
	<cfset var node = "">
	<cfset var title = "">
	<cfset var summary = "">
	<cfset var iURL = "">
	<cfset var clickURL = "">
	<cfset var mimetype = "">
	<cfset var modificationdate = "">
	<cfset var cacheurl = "">
	<cfset var cachesize = "">
	<cfset var theSite = "">
	
	<cfset theURL = theURL & getAppID()>
	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">
	<cfset theURL = theURL & "&region=#urlEncodedFormat(arguments.region)#">
	
	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">
	
	<cfif arguments.results lt 1 or arguments.results gt 100>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 100, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">
	
	<cfif not listFindNoCase("any,html,msword,pdf,ppt,rss,txt,xls", arguments.format)>
		<cfthrow message="Invalid format (#arguments.format#) passed. Only any, html, msword, pdf, ppt, rss, txt, xls allowed.">
	</cfif>
	<cfset theURL = theURL & "&format=#arguments.format#">

	<cfif arguments.adult>
		<cfset theURL = theURL & "&adult_ok=1">
	</cfif>

	<cfif arguments.similar>
		<cfset theURL = theURL & "&similar_ok=1">
	</cfif>

	<cfif len(arguments.language)>
		<cfset theURL = theURL & "&language=#arguments.language#">
	</cfif>
	
	<cfset theURL = theURL & "&country=#arguments.country#">
		
	<cfif len(arguments.site)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.site))#">
			<cfset theURL = theURL & "&site=#listGetAt(arguments.site,x)#">
		</cfloop>
	</cfif>

	<cfif len(arguments.subscription)>
		<cfset theURL = theURL & "&subscription=#arguments.subscription#">
	</cfif>
	
	<cfif len(arguments.license)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.license))#">
			<cfset theURL = theURL & "&license=#listGetAt(arguments.license,x)#">
		</cfloop>
	</cfif>

	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		
		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Map API Error: #xmlResult.error.message.xmlText#">
		</cfif>
		
		<cfset totalResults = xmlResult.resultSet.xmlAttributes.totalResultsAvailable>
		
		<cfloop index="x" from="1" to="#xmlResult.resultSet.xmlAttributes.totalResultsReturned#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset title = node.title.xmlText>
			<cfset summary = node.summary.xmlText>
			<cfset iUrl = node.url.xmlText>
			<cfset clickurl = node.clickurl.xmlText>
			<cfset mimetype = node.mimetype.xmlText>
			<cfset modificationdate = epochTimeToDate(node.modificationdate.xmlText)>
			<cfif structKeyExists(node, "cache")>
				<cfset cacheurl = node.cache.url.xmlText>
				<cfset cachesize = node.cache.size.xmlText>
			</cfif>	
			<cfset queryAddRow(q)>
			<cfset querySetCell(q, "title", title)>
			<cfset querySetCell(q, "summary", summary)>
			<cfset querySetCell(q, "url", iUrl)>
			<cfset querySetCell(q, "clickurl", clickurl)>
			<cfset querySetCell(q, "mimetype", mimetype)>
			<cfset querySetCell(q, "modificationdate", modificationdate)>
			<cfset querySetCell(q, "totalavailable", totalResults)>
			<cfset querySetCell(q, "cacheurl", cacheurl)>
			<cfset querySetCell(q, "cachesize", cachesize)>
			
		</cfloop>
	</cfif>

	<cfreturn q>
</cffunction>

<cffunction name="relatedSuggestion" returnType="array" output="false" access="public"
			hint="Retrieves related search term suggestions.">
	<cfargument name="query" type="string" required="true" hint="Search terms.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">
	
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://search.yahooapis.com/WebSearchService/V1/relatedSuggestion?appid=">	
	<cfset var suggestions = arrayNew(1)>
	<cfset var x = "">
	
	<cfset theURL = theURL & getAppID()>
	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Related Suggestion API Error: #xmlResult.error.message.xmlText#">
		</cfif>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn suggestions>
		</cfif>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset arrayAppend(suggestions, xmlResult.ResultSet.Result[x].xmlText)>
		</cfloop>
		
		<cfreturn suggestions>
	</cfif>
</cffunction>

<cffunction name="spellingSuggestion" returnType="array" output="false" access="public"
			hint="Retrieves spelling suggestions.">
	<cfargument name="query" type="string" required="true" hint="Word to use.">
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://search.yahooapis.com/WebSearchService/V1/spellingSuggestion?appid=">	
	<cfset var suggestions = arrayNew(1)>
	<cfset var x = "">
	
	<cfset theURL = theURL & getAppID()>
	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">

	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Spelling Suggestion API Error: #xmlResult.error.message.xmlText#">
		</cfif>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn suggestions>
		</cfif>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset arrayAppend(suggestions, xmlResult.ResultSet.Result[x].xmlText)>
		</cfloop>
		
		<cfreturn suggestions>
	</cfif>
</cffunction>

</cfcomponent>