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
			hint="Do a local based search.">
	<cfargument name="query" type="string" required="false" default="" hint="Search term. Use * to return everything.">
	<cfargument name="listing_id" type="string" required="false" default="" hint="Specific location id to filter by.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results to return. Max is 20.">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Record to start with.">	
	<cfargument name="sort" type="string" required="false" default="relevance" hint="How to sort results. Valid values are relevance, title, distance, rating.">
	<cfargument name="radius" type="numeric" required="false" hint="Range in miles from the location to provide reports for. ">
	<cfargument name="street" type="string" required="false" hint="Street address (number is optional).">
	<cfargument name="city" type="string" required="false" hint="City name.">
	<cfargument name="state" type="string" required="false" hint="Full US State or abbreviation.">
	<cfargument name="zip" type="string" required="false" hint="Either 5 or 9 digit zip.">
	<cfargument name="location" type="string" required="false" hint="A free form address location. Takes priority over street/city/state.">
	<cfargument name="latitude" type="numeric" required="false" hint="Latitude of starting location.">
	<cfargument name="longitude" type="numeric" required="false" hint="Longitude of starting location.">
	<cfargument name="category" type="string" required="false" hint="One or more category IDs to filter results by.">
	<cfargument name="omitcategory" type="string" required="false" hint="One or more category IDs that cannot be in the results.">
	<cfargument name="minimumRating" type="numeric" required="false" hint="Minimum average rating (on a five point scale) to filter results by.">
	
	<cfset var x = "">
	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var node = "">
	
	<cfset var theURL = "http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=">

	<cfset var q = queryNew("totalresults,firstresult,resultsetmapurl,id,title,address,city,state,phone,latitude,longitude,averagerating,totalratings,totalreviews,lastreviewdate,lastreviewintro,distance,url,clickurl,mapurl,businessurl,businessclickurl,categories")>

	<cfset var totalresults = "">
	<cfset var firstResult = "">
	<cfset var resultsetmapURL = "">
	
	<cfset var data = "">
	<cfset var key = "">
	
	<cfset var pCats = "">
	<cfset var pCat = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfif trim(arguments.query) is "" and trim(arguments.listing_id) is "">
		<cfthrow message="Local API: Must pass query or listing_id attribute.">
	</cfif>
	
	<cfif len(arguments.query)>
		<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">	
	</cfif>

	<cfif len(arguments.listing_id)>
		<cfset theURL = theURL & "&listing_id=#arguments.listing_id#">	
	</cfif>

	<cfif arguments.results lt 1 or arguments.results gt 20>
		<cfthrow message="Local API: Invalid results (#arguments.results#) passed. Max is 20, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1>
		<cfthrow message="Local API: Invalid start (#arguments.start#) passed. Start value min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<cfif not listFindNoCase("relevance,title,distance,rating", arguments.sort)>
		<cfthrow message="Local API: Invalid sort (#arguments.sort#) passed. Only relevance, title, distance, or rating allowed.">
	</cfif>	
	<cfset theURL = theURL & "&sort=#arguments.sort#">

	<cfif structKeyExists(arguments, "radius")>
		<cfset theURL = theURL & "&radius=#arguments.radius#">
	</cfif>
	
	<cfif structKeyExists(arguments, "street")>
		<cfset theURL = theURL & "&street=#urlEncodedFormat(arguments.street)#">
	</cfif>

	<cfif structKeyExists(arguments, "city")>
		<cfset theURL = theURL & "&city=#urlEncodedFormat(arguments.city)#">
	</cfif>
	
	<cfif structKeyExists(arguments, "state")>
		<cfset theURL = theURL & "&state=#urlEncodedFormat(arguments.state)#">
	</cfif>

	<cfif structKeyExists(arguments, "zip")>
		<cfset theURL = theURL & "&zip=#arguments.zip#">
	</cfif>
	
	<cfif structKeyExists(arguments, "location")>
		<cfset theURL = theURL & "&location=#urlEncodedFormat(arguments.location)#">
	</cfif>

	<cfif structKeyExists(arguments, "latitude")>
		<cfif arguments.latitude lt -90 or arguments.latitude gt 90>
			<cfthrow message="Local API: Latitude value (#arguments.latitude#) is invalid. Must be between -90 and 90.">
		</cfif>
		<cfset theURL = theURL & "&latitude=#arguments.latitude#">
	</cfif>
	
	<cfif structKeyExists(arguments, "longitude")>
		<cfif arguments.longitude lt -180 or arguments.longitude gt 180>
			<cfthrow message="Local API: Longitude value (#arguments.longitude#) is invalid. Must be between -180 and 180.">
		</cfif>
		<cfset theURL = theURL & "&longitude=#arguments.longitude#">
	</cfif>

	<cfif structKeyExists(arguments, "category") and len(arguments.category)>
		<cfloop index="x" from="1" to="#listLen(arguments.category)#">
			<cfset theURL = theURL & "&category=#listGetAt(arguments.category,x)#">
		</cfloop>
	</cfif>

	<cfif structKeyExists(arguments, "omitcategory") and len(arguments.omitcategory)>
		<cfloop index="x" from="1" to="#listLen(arguments.omitcategory)#">
			<cfset theURL = theURL & "&omit_category=#listGetAt(arguments.omitcategory,x)#">
		</cfloop>
	</cfif>
	
	<cfif structKeyExists(arguments, "minimumRating") and (arguments.minimumRating lte 0 or arguments.minimumRating gte 6)>
		<cfthrow message="Local API: Minimum rating must be between 1 and 5.">
	<cfelseif structKeyExists(arguments, "minimumRating")>
		<cfset theURL = theURL & "&minimum_rating=#arguments.minimum_rating#">
	</cfif>
		
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Local API Error: #xmlResult.error.message.xmlText#">
		</cfif>
		
		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>
		<cfset resultsetmapurl = xmlResult.ResultSet.ResultSetMapUrl.xmlText>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
		
			<cfset node = xmlResult.resultSet.Result[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			<cfset data.resultsetmapurl = resultsetmapurl>
			
			<cfset data.id = node.xmlAttributes.id>
			<cfset data.title = node.title.xmlText>
			<cfset data.address = node.address.xmlText>
			<cfset data.city = node.city.xmlText>
			<cfset data.state = node.state.xmlText>
			<cfset data.phone = node.phone.xmlText>
			<cfset data.latitude = node.latitude.xmlText>
			<cfset data.longitude = node.longitude.xmlText>
			<cfset data.averagerating = node.rating.averagerating.xmlText>
			<cfset data.totalratings = node.rating.totalratings.xmlText>
			<cfset data.totalreviews = node.rating.totalreviews.xmlText>
			<cfif len(node.rating.lastreviewdate.xmlText)>
				<cfset data.lastreviewdate = epochTimeToDate(node.rating.lastreviewdate.xmlText)>
			</cfif>
			<cfset data.lastreviewintro = node.rating.lastreviewintro.xmlText>
			<cfset data.distance = node.distance.xmlText>
			<cfset data.url = node.url.xmlText>
			<cfset data.clickurl = node.clickurl.xmlText>
			<cfset data.mapurl = node.mapurl.xmlText>
			<cfif structKeyExists(node, "businessurl")>
				<cfset data.businessurl = node.businessurl.xmlText>
			</cfif>
			<cfif structKeyExists(node, "businessclickurl")>
				<cfset data.businessclickurl = node.businessclickurl.xmlText>
			</cfif>
			
			<cfset pCats = arrayNew(1)>
			<cfif structKeyExists(node.Categories, "Category")>
				<cfloop index="y" from="1" to="#arrayLen(node.Categories.Category)#">
					<cfset pCat = structNew()>
					<cfset pCat.id = node.Categories.Category[y].xmlAttributes.id>
					<cfset pCat.name = node.Categories.Category[y].xmlText>
					<cfset arrayAppend(pCats, pCat)>
				</cfloop>
			</cfif>
			<cfset data.categories = pCats>

			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>

		</cfloop>		
categories
	</cfif>
	
	<cfreturn q>
</cffunction>

</cfcomponent>