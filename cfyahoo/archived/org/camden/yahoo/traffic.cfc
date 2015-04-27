<!---
	Name         : traffic.cfc
	Author       : Raymond Camden 
	Created      : October 12, 2006
	Last Updated : October 15, 2006
	History      : Forgot to include severity in my url (rkc 10/15/06)
	Purpose		 : Traffic API

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

<cffunction name="trafficSearch" returnType="query" output="false" access="public"
			hint="Main traffic search API.">
	<cfargument name="street" type="string" required="false" default="" hint="Street address (number is optional).">
	<cfargument name="city" type="string" required="false" default="" hint="City name.">
	<cfargument name="state" type="string" required="false" default="" hint="Full US State or abbreviation.">
	<cfargument name="zip" type="string" required="false" default="" hint="Either 5 or 9 digit zip.">
	<cfargument name="location" type="string" required="false" default="" hint="A free form address location. Takes priority over street/city/state.">
	<cfargument name="latitude" type="numeric" required="false" hint="Latitude of starting location.">
	<cfargument name="longitude" type="numeric" required="false" hint="Longitude of starting location.">
	<cfargument name="severity" type="numeric" required="false" default="1" hint="Minimum severity level to return. Valid range is 1 to 5. 5 is most severe.">
	<cfargument name="zoom" type="numeric" required="false" default="6" hint="Zoom level for data. Valid range is from 1 (street level) to 12 (country level). Ignored if radius supplied.">	
	<cfargument name="radius" type="numeric" required="false" hint="Range in miles from the location to provide reports for. ">
	<cfargument name="map" type="boolean" required="false" default="false" hint="If true, a map URL will be returned with the results.">
	<cfargument name="imagetype" type="string" required="false" default="png" hint="Image format for map (if requested).">
	<cfargument name="imageheight" type="numeric" required="false" default="500" hint="Height of map (if requested) in pixels. Valid range is from 10 to 2000. ">
	<cfargument name="imagewidth" type="numeric" required="false" default="620" hint="Width of map (if requested) in pixels. Valid range is from 10 to 2000. ">


	<cfset var q = queryNew("lastupdate,warning,type,title,description,latitude,longitude,direction,severity,reportdate,updatedate,enddate,mapurl")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://api.local.yahoo.com/MapsService/V1/trafficData?appid=">
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

	<cfif structKeyExists(arguments, "latitude")>
		<cfif arguments.latitude lt -90 or arguments.latitude gt 90>
			<cfthrow message="Latitude value (#arguments.latitude#) is invalid. Must be between -90 and 90.">
		</cfif>
		<cfset theURL = theURL & "&latitude=#arguments.latitude#">
	</cfif>
	
	<cfif structKeyExists(arguments, "longitude")>
		<cfif arguments.longitude lt -180 or arguments.longitude gt 180>
			<cfthrow message="Longitude value (#arguments.longitude#) is invalid. Must be between -180 and 180.">
		</cfif>
		<cfset theURL = theURL & "&longitude=#arguments.longitude#">
	</cfif>

	<cfif len(arguments.severity)>
		<cfif arguments.severity lt 1 or arguments.severity gt 5>
			<cfthrow message="Severity value (#arguments.severity#) is invalid. Must be between 1 and 5.">
		</cfif>
		<cfset theURL = theURL & "&severity=#arguments.severity#">
	</cfif>

	<cfif len(arguments.zoom)>
		<cfif arguments.zoom lt 1 or arguments.zoom gt 12>
			<cfthrow message="Zoom value (#arguments.zoom#) is invalid. Must be between 1 and 12.">
		</cfif>
		<cfset theURL = theURL & "&zoom=#arguments.zoom#">
	</cfif>

	<cfif structKeyExists(arguments, "radius")>
		<cfset theURL = theURL & "&radius=#arguments.radius#">
	</cfif>

	<cfif arguments.map>
		<cfset theURL = theURL & "&include_map=1">
		
		<cfif not listFindNoCase("png,gif", arguments.imagetype)>
			<cfthrow message="ImageType value (#arguments.imagetype#) is invalid. Only png or gif is allowed.">
		</cfif>
		
		<cfif arguments.imageheight lt 10 or arguments.imageheight gt 2000>
			<cfthrow message="ImageHeight value (#arguments.imageheight#) is invalid. Must be between 10 and 2000.">
		</cfif>
		<cfset theURL = theURL & "&image_height=#arguments.imageheight#">

		<cfif arguments.imagewidth lt 10 or arguments.imagewidth gt 2000>
			<cfthrow message="ImageWidth value (#arguments.imagewidth#) is invalid. Must be between 10 and 2000.">
		</cfif>
		<cfset theURL = theURL & "&image_width=#arguments.imagewidth#">

	</cfif>
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Traffic API Error: #xmlResult.error.message.xmltext#">
		</cfif>
		
		<!--- get the md first --->
		<cfset lastupdate = epochTimeToDate(xmlResult.resultSet.lastUpdateDate.xmlText)>
		<cfif structKeyExists(xmlResult.resultSet, "warning")>
			<cfset warning = xmlResult.resultSet.warning.xmlText>	
		</cfif>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.result[x]>
			<cfset data = structNew()>
			
			<cfset data.lastupdate = lastupdate>
			<cfset data.warning = warning>
			
			<cfset data.type = node.xmlAttributes.type>
			<cfset data.title = node.title.xmlText>
			<cfset data.description = node.description.xmlText>			
			<cfset data.latitude = node.latitude.xmlText>
			<cfset data.longitude = node.longitude.xmlText>
			<cfset data.direction = node.direction.xmlText>
			<cfset data.severity = node.severity.xmlText>
			<cfset data.reportdate = epochTimeToDate(node.reportdate.xmlText)>
			<cfset data.updatedate = epochTimeToDate(node.updatedate.xmlText)>
			<cfset data.enddate = epochTimeToDate(node.enddate.xmlText)>
			<cfif structKeyExists(node, "imageurl")>
				<cfset data.mapurl = node.imageurl.xmlText>
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