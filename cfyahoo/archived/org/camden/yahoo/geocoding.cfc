<!---
	Name         : geocoding.cfc
	Author       : Raymond Camden 
	Created      : October 17, 2006
	Last Updated : 
	History      : 
	Purpose		 : Geocoding API

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

<cffunction name="geoSearch" returnType="query" output="false" access="public"
			hint="Main geocoding API.">
			
	<cfargument name="street" type="string" required="false" default="" hint="Street address (number is optional).">
	<cfargument name="city" type="string" required="false" default="" hint="City name.">
	<cfargument name="state" type="string" required="false" default="" hint="Full US State or abbreviation.">
	<cfargument name="zip" type="string" required="false" default="" hint="Either 5 or 9 digit zip.">
	<cfargument name="location" type="string" required="false" default="" hint="A free form address location. Takes priority over street/city/state.">

	<cfset var q = queryNew("precision,warning,latitude,longitude,address,city,state,zip,country")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=">
	<cfset var x = "">
	<cfset var node = "">

	<cfset var lastupdate = "">
	<cfset var warning = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset theURL = theURL & getAppID()>
	
	<cfif len(arguments.street)>
		<cfset theURL = theURL & "&street=#urlEncodedFormat(arguments.street)#">
	</cfif>
	<cfif len(arguments.city)>
		<cfset theURL = theURL & "&city=#urlEncodedFormat(arguments.city)#">
	</cfif>
	<cfif len(arguments.state)>
		<cfset theURL = theURL & "&state=#urlEncodedFormat(arguments.state)#">
	</cfif>
	<cfif len(arguments.zip)>
		<cfset theURL = theURL & "&zip=#arguments.zip#">
	</cfif>
	<cfif len(arguments.location)>
		<cfset theURL = theURL & "&location=#urlEncodedFormat(arguments.location)#">
	</cfif>

	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Geocoding API Error: #xmlResult.error.message.xmltext#">
		</cfif>
		
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.result[x]>
			<cfset data = structNew()>

			<cfset data.precision = node.xmlAttributes.precision>
			<cfif structKeyExists(node.xmlAttributes, "warning")>
				<cfset data.warning = node.xmlAttributes.warning>
			</cfif>
			
			<cfset data.latitude = node.latitude.xmlText>
			<cfset data.longitude = node.longitude.xmlText>
			<cfset data.address = node.address.xmlText>
			<cfset data.city = node.city.xmlText>
			<cfset data.state = node.state.xmlText>
			<cfset data.zip = node.zip.xmlText>
			<cfset data.country = node.country.xmlText>

			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>

</cffunction>

</cfcomponent>