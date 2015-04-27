<!---
	Name         : image.cfc
	Author       : Raymond Camden 
	Created      : October 12, 2006
	Last Updated : October 12, 2006
	History      : Added header.
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

<cffunction name="search" returnType="query" output="false" access="public"
			hint="Image search API.">
	<cfargument name="query" type="string" required="true" hint="Query to use with context.">
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position. End postion (start+results) may not exceed 1000.">
	<cfargument name="format" type="string" required="false" default="any" hint="File formats to search. Valid values are: any, bmp, gif, jpeg, png">
	<cfargument name="adult" type="boolean" required="false" default="false" hint="If true, adult results may be returned.">
	<cfargument name="coloration" type="string" required="false" default="any" hint="Return any image, image in color, or images in black and white. Valid values are: any, color, bw">	
	<cfargument name="site" type="string" required="false" hint="Restrict results to a site or list of sites. Up to 30 may be passed.">

	<cfset var q = queryNew("title,summary,url,clickurl,refererurl,filesize,fileformat,height,width,thumbnail,thumbnailwidth,thumbnailheight,publisher,restrictions,copyright,firstresultposition,totalavailable")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var theURL = "http://search.yahooapis.com/ImageSearchService/V1/imageSearch?appid=">
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

	<cfif not listFindNoCase("any,bmp,gif,jpeg,png", arguments.format)>
		<cfthrow message="Invalid format (#arguments.format#) passed. Only any, bmp, gif, jpeg, png allowed.">
	</cfif>

	<cfset theURL = theURL & getAppID()>
	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">
	<cfset theURL = theURL & "&type=#arguments.type#">
	<cfset theURL = theURL & "&results=#arguments.results#">
	<cfset theURL = theURL & "&start=#arguments.start#">
	<cfset theURL = theURL & "&format=#arguments.format#">
	<cfset theURL = theURL & "&adult_ok=#arguments.adult#">
	<cfset theURL = theURL & "&coloration=#arguments.coloration#">
	
	<cfif structKeyExists(arguments, "site") and len(arguments.site)>
		<cfloop index="x" from="1" to="#min(30, listLen(arguments.site))#">
			<cfset theURL = theURL & "&site=#listGetAt(arguments.site,x)#">
		</cfloop>
	</cfif>
		
	<cfhttp url="#theURL#" result="result" charset="utf-8" />
	
	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Image Search API Error: #xmlResult.error.message.xmlText#">
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
			<cfset data.refererurl = node.refererurl.xmltext>
			<cfset data.filesize = node.filesize.xmltext>
			<cfset data.fileformat = node.fileformat.xmltext>
			<cfset data.height = node.height.xmltext>
			<cfset data.width = node.width.xmltext>

			<cfif structKeyExists(node, "thumbnail")>
				<cfset data.thumbnail = node.thumbnail.url.xmltext>
				<cfset data.thumbnailwidth = node.thumbnail.width.xmlText>
				<cfset data.thumbnailheight = node.thumbnail.height.xmlText>
			</cfif>

			<cfif structKeyExists(node, "publisher")>
				<cfset data.publisher = node.publisher.xmltext>
			<cfelse>
				<cfset data.publisher = "">
			</cfif>
			<cfif structKeyExists(node, "restrictions")>
				<cfset data.restrictions = node.restrictions.xmltext>
			<cfelse>
				<cfset data.restrictions = "">
			</cfif>
			<cfif structKeyExists(node, "copyright")>
				<cfset data.copyright = node.copyright.xmltext>
			<cfelse>
				<cfset data.copyright = "">
			</cfif>
			
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>

		</cfloop>
	</cfif>

	<cfreturn q>
</cffunction>

</cfcomponent>