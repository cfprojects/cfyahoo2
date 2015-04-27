<cfset weatherAPI = createObject("component", "org.camden.yahoo.weather")>

<cfinvoke component="#weatherAPI#" method="getWeather" returnVariable="result">
	<cfinvokeargument name="location" value="70508">
	<cfinvokeargument name="units" value="F">
</cfinvoke>

<cfdump var="#result#" label="Weather for Lafayette, LA">

<cfinvoke component="#weatherAPI#" method="getForecast" returnVariable="result">
	<cfinvokeargument name="location" value="70508">
	<cfinvokeargument name="units" value="F">
</cfinvoke>

<cfdump var="#result#" label="Forecast for Lafayette, LA">

<cftry>
	<cfinvoke component="#weatherAPI#" method="getForecast" returnVariable="result">
		<cfinvokeargument name="location" value="poop">
		<cfinvokeargument name="units" value="F">
	</cfinvoke>
	
	<cfdump var="#result#" label="Forcast for Lafayette, LA">

	<cfcatch>
		<cfoutput>Failure: #cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>