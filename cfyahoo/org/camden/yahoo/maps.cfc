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

<cffunction name="getMap" returnType="string" output="false" access="public"
			hint="Gets a simple map.">
	<cfargument name="location" type="string" required="false" default="" hint="A free form address location. Takes priority over street/city/state.">
	<cfargument name="street" type="string" required="false" default="" hint="Street address (number is optional).">
	<cfargument name="city" type="string" required="false" default="" hint="City name.">
	<cfargument name="state" type="string" required="false" default="" hint="Full US State or abbreviation.">
	<cfargument name="zip" type="string" required="false" default="" hint="Either 5 or 9 digit zip.">
	<cfargument name="latitude" type="numeric" required="false" hint="Latitude of starting location.">
	<cfargument name="longitude" type="numeric" required="false" hint="Longitude of starting location.">
	<cfargument name="imagetype" type="string" required="false" default="png" hint="Image format for map (if requested). Valid values are png or gif.">
	<cfargument name="imageheight" type="numeric" required="false" default="500" hint="Height of map (if requested) in pixels. Valid range is from 10 to 2000. ">
	<cfargument name="imagewidth" type="numeric" required="false" default="620" hint="Width of map (if requested) in pixels. Valid range is from 10 to 2000. ">
	<cfargument name="zoom" type="numeric" required="false" default="6" hint="Zoom level for data. Valid range is from 1 (street level) to 12 (country level). Ignored if radius supplied.">	
	<cfargument name="radius" type="numeric" required="false" hint="Range in miles from the location to provide reports for. ">

	<cfset var mapurl = "">
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://local.yahooapis.com/MapsService/V1/mapImage?appid=">
		
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

	<cfif len(arguments.zoom)>
		<cfif arguments.zoom lt 1 or arguments.zoom gt 12>
			<cfthrow message="Zoom value (#arguments.zoom#) is invalid. Must be between 1 and 12.">
		</cfif>
		<cfset theURL = theURL & "&zoom=#arguments.zoom#">
	</cfif>

	<cfif structKeyExists(arguments, "radius")>
		<cfset theURL = theURL & "&radius=#arguments.radius#">
	</cfif>

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
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Map API Error: #xmlResult.error.message.xmlText#">
		</cfif>
		<cfset mapurl = xmlResult.result.xmltext>
	</cfif>

	<cfreturn mapurl>
</cffunction>

<!---
<cffunction name="getAnnotedMap" returnType="string" output="false" access="public" 
			hint="Allows you to get a map with annotations on it.">
	<cfargument name="link" type="string" required="true" default="" hint="URL for referring source. Not used but required.">
	<cfargument name="title" type="string" required="true" default="" hint="Title for link.">

	<cfargument name="imageurl" type="string" required="false" default="" hint="Image URL to be used above map. Must be no bigger than 144x100.">

	<cfset var theURL = "http://api.maps.yahoo.com/Maps/V1/annotatedMaps?appid=">

	<cfset theURL = theURL & getAppID()>
				
</cffunction>	
--->
</cfcomponent>