<cfset geoAPI = createObject("component", "org.camden.yahoo.geocoding")>

<cfinvoke component="#geoAPI#" method="geoSearch" returnVariable="result">
	<cfinvokeargument name="zip" value="90210">
</cfinvoke>

<cfdump var="#result#" label="Zip search for 90210">

<p>
<hr>
<p>

<cfinvoke component="#geoAPI#" method="geoSearch" returnVariable="result">
	<cfinvokeargument name="location" value="San Francisco, CA">
</cfinvoke>

<cfdump var="#result#" label="location search: San Franciso, CA">

<p>
<hr>
<p>

<cftry>
	<cfinvoke component="#geoAPI#" method="geoSearch" returnVariable="result">
		<cfinvokeargument name="location" value="Pluto, Solar System">
	</cfinvoke>
	
	<cfdump var="#result#" label="location search: Pluto, Solor System">

	<cfcatch>
		<cfoutput>Failure: Message was #cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>
