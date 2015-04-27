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
<cfcomponent output="false" extends="base" displayName="News Search">

<cffunction name="search" returnType="query" output="false" access="public"
			hint="Search news.">
	<cfargument name="query" type="string" required="true" hint="Search term.">
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">
	<cfargument name="sort" type="string" required="false" default="rank" hint="Sort results. Valid values are: rank, date">
	<cfargument name="language" type="string" required="false"  hint="Language for results. See supported languages here: http://developer.yahoo.com/search/languages.html">
	<cfargument name="site" type="string" required="false" default="" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">
	<cfargument name="age" type="string" required="false" default="" hint="Restrict results to a date range. If not specified, will be 7d">

	<cfset var q = queryNew("totalresults,firstresult,title,abstract,url,clickurl,source,sourceurl,language,date,thumbnail,thumbnailwidth,thumbnailheight")>
	<cfset var result = "">
	<cfset var json = "">
	
	<cfset var theURL = "http://boss.yahooapis.com/ysearch/news/v1/">
	<cfset var x = "">
	<cfset var node = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		

	<cfset theURL = theURL & "#urlEncodedFormat(arguments.query)#/?appid=#getAppId()#">
	
	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<cfif not listFindNoCase("rank,date", arguments.sort)>
		<cfthrow message="Invalid sort (#arguments.sort#) passed. Only rank or date allowed.">
	</cfif>	
	<cfset theURL = theURL & "&sort=#arguments.sort#">

	<cfif structKeyExists(arguments, "language")>
		<cfset theURL = theURL & "&language=#arguments.language#">
	</cfif>


	<cfif structKeyExists(arguments, "age")>
		<cfset theURL = theURL & "&age=#arguments.age#">
	</cfif>
	

	<cfif len(arguments.site)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.site))#">
			<cfset theURL = theURL & "&site=#listGetAt(arguments.site,x)#">
		</cfloop>
	</cfif>
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />
	<cfif isJSON(result.fileContent.toString())>
	
		<cfset json = deserializeJSON(result.fileContent.toString())>

		<cfset totalResults = json.ysearchresponse.totalhits>
		<cfset firstresult = json.ysearchresponse.start>
		
		<cfif totalresults gt 0>
			<cfloop index="x" from="1" to="#arrayLen(json.ysearchresponse.resultset_news)#">
				<cfset node = json.ysearchresponse.resultset_news[x]>
				<cfset data = {}>
				
				<!--- metadata --->
				<cfset data.totalResults = totalResults>
				<cfset data.firstResult = firstResult>
				
				<cfset data.title = node.title>
				<cfset data.abstract = node.abstract>
				<cfset data.url = node.url>
				<cfset data.clickurl = node.clickurl>
				<cfset data.source = node.source>
				<cfset data.sourceurl = node.sourceurl>
				<cfset data.language = node.language>
				<cfset data.date = node.date>
	
				<cfif structKeyExists(node, "thumbnail")>
					<cfset data.thumbnail = node.thumbnail.url.xmltext>
					<cfset data.thumbnailwidth = node.thumbnail.width.xmlText>
					<cfset data.thumbnailheight = node.thumbnail.height.xmlText>
				</cfif>
				
				<cfset queryAddRow(q)>
				<cfloop item="key" collection="#data#">
					<cfset querySetCell(q, key, data[key])>
				</cfloop>		
			</cfloop>
		</cfif>
	</cfif>	
	
	<cfreturn q>
</cffunction>

</cfcomponent>