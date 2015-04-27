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

<!---
Yahoo's API returns both weather info as well as a forecast. 
Therefore I have one main function to get it, and then two
child functions to get the pieces they want.
--->
<cffunction name="getWeatherData" returnType="any" output="false" access="public"
			hint="Gets all the data.">
	<cfargument name="datatype" type="string" required="true" hint="Either weather or forecast.">
	<cfargument name="location" type="string" required="true" hint="Either a zip or a Yahoo Location ID. ">
	<cfargument name="units" type="string" required="false" default="c" hint="Either F for Fahrenheit or C for Celsius">

	<cfset var result = "">
	<cfset var xmlResult = "">
	<cfset var data = "">
	<cfset var numForecast = "">
	<cfset var x = "">
	<cfset var day = "">
	
	<cfset var theURL = " http://weather.yahooapis.com/forecastrss?p=">
	
	<!--- lowcase units --->
	<cfset arguments.units = lcase(arguments.units)>
	
	<cfif not listFindNoCase("f,c", arguments.units)>
		<cfthrow message="Invalid units (#arguments.units#) passed. Only f or c is allowed.">	
	</cfif>
	
	<cfset theURL = theURL & arguments.location & "&u=" & arguments.units>
				
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<!--- No real way to get error case unless we do a string check. --->		
		<cfif findNoCase("error",xmlResult.rss.channel.title.xmlText)>
			<cfthrow message="Weather API Error: #xmlResult.rss.channel.item.title.xmlText# #xmlResult.rss.channel.item.description.xmlText#">
		</cfif>

		<cfif arguments.datatype is "weather">
			<!--- handle current weather info --->
			
			<cfset data = structNew()>
			
			<!--- last updated --->
			<cfset data.lastUpdated = xmlResult.rss.channel.lastBuildDate.xmlText>
			
			
			<!--- more info url --->
			<cfset data.link = xmlResult.rss.channel.link.xmlText>
			
			<!--- unit strings --->
			<cfset data.units = structNew()>
			<cfset data.units.speed = xmlResult.rss.channel["yweather:units"].xmlAttributes.speed>
			<cfset data.units.temp = xmlResult.rss.channel["yweather:units"].xmlAttributes.temperature>
			<cfset data.units.distance = xmlResult.rss.channel["yweather:units"].xmlAttributes.distance>
			<cfset data.units.pressure = xmlResult.rss.channel["yweather:units"].xmlAttributes.pressure>
			
			<!--- wind stuff --->
			<cfset data.windChill = xmlResult.rss.channel["yweather:wind"].xmlAttributes.chill>
			<cfset data.windDirection = xmlResult.rss.channel["yweather:wind"].xmlAttributes.direction>
			<cfset data.windSpeed = xmlResult.rss.channel["yweather:wind"].xmlAttributes.speed>

			<!--- atmos stuff --->
			<cfset data.humidity = xmlResult.rss.channel["yweather:atmosphere"].xmlAttributes.humidity>
			<cfset data.pressure = xmlResult.rss.channel["yweather:atmosphere"].xmlAttributes.pressure>
			<cfset data.rising = xmlResult.rss.channel["yweather:atmosphere"].xmlAttributes.rising>
			<cfset data.visibility = xmlResult.rss.channel["yweather:atmosphere"].xmlAttributes.visibility>

			<!--- big giant ball of gas outside stuff --->
			<cfset data.sunrise = xmlResult.rss.channel["yweather:astronomy"].xmlAttributes.sunrise>
			<cfset data.sunset = xmlResult.rss.channel["yweather:astronomy"].xmlAttributes.sunset>

			<!--- Current Info --->
			<cfset data.temperature = xmlResult.rss.channel.item["yweather:condition"].xmlAttributes.temp>
			<cfset data.condition = xmlResult.rss.channel.item["yweather:condition"].xmlAttributes.text>
			<cfset data.description = xmlResult.rss.channel.item.description.xmlText>
			
			<!--- location --->
			<cfset data.city = xmlResult.rss.channel["yweather:location"].xmlAttributes.city>
			<cfset data.country = xmlResult.rss.channel["yweather:location"].xmlAttributes.country>
			<cfset data.region = xmlResult.rss.channel["yweather:location"].xmlAttributes.region>
			
		<cfelse>
		
			<!--- handle forecast --->
			<cfset numForecast = arrayLen(xmlResult.rss.channel.item["yweather:forecast"])>
			
			<cfset data = arrayNew(1)>

			<cfloop index="x" from="1" to="#numForecast#">
			   <cfset day = structNew()>
			   <cfset day.date = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.date>
			   <cfset day.dow = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.day>
			   <cfset day.high = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.high>
			   <cfset day.low = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.low>
			   <cfset day.condition = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.text>
               <cfset day.code = xmlResult.rss.channel.item["yweather:forecast"][x].xmlAttributes.code>
			   <cfset arrayAppend(data, day)>
			</cfloop>

		</cfif>
		
	</cfif>

	<cfreturn data>

</cffunction>

<cffunction name="getForecast" returnType="array" output="false" access="public"
			hint="Gets the weather.">
	<cfargument name="location" type="string" required="true" hint="Either a zip or a Yahoo Location ID. ">
	<cfargument name="units" type="string" required="false" default="c" hint="Either F for Fahrenheit or C for Celsius">

	<cfreturn getWeatherData("forecast", arguments.location, arguments.units)>
</cffunction>

<cffunction name="getWeather" returnType="struct" output="false" access="public"
			hint="Gets the weather.">
	<cfargument name="location" type="string" required="true" hint="Either a zip or a Yahoo Location ID. ">
	<cfargument name="units" type="string" required="false" default="c" hint="Either F for Fahrenheit or C for Celsius">

	<cfreturn getWeatherData("weather", arguments.location, arguments.units)>
</cffunction>

</cfcomponent>