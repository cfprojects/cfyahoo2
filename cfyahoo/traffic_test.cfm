<cfset trafficAPI = createObject("component", "org.camden.yahoo.traffic")>

<cfinvoke component="#trafficAPI#" method="trafficSearch" returnVariable="result">
	<cfinvokeargument name="zip" value="90210">
</cfinvoke>

<cfdump var="#result#" label="Zip search for 90210">

<p>
<hr>
<p>

<cfinvoke component="#trafficAPI#" method="trafficSearch" returnVariable="result">
	<cfinvokeargument name="zip" value="90210">
	<cfinvokeargument name="map" value="true">
</cfinvoke>

<cfdump var="#result#" label="Zip search for 90210, with maps">


<p>
<hr>
<p>

<cfinvoke component="#trafficAPI#" method="trafficSearch" returnVariable="result">
	<cfinvokeargument name="location" value="San Francisco, CA">
</cfinvoke>

<cfdump var="#result#" label="location search: San Franciso, CA">

<p>
<hr>
<p>

<cftry>
	<cfinvoke component="#trafficAPI#" method="trafficSearch" returnVariable="result">
		<cfinvokeargument name="location" value="Lafayette, LA">
	</cfinvoke>
	
	<cfdump var="#result#" label="location search: Lafayette, LA">

	<cfcatch>
		<cfoutput>Failure: Message was #cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>
