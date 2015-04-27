<cfset audioAPI = createObject("component", "org.camden.yahoo.audio")>

<cfinvoke component="#audioAPI#" method="albumSearch" returnVariable="result">
	<cfinvokeargument name="album" value="Roses">
</cfinvoke>

<h2>Album search for Roses</h2>

<p>
<cfoutput>Total results were: #result.totalresults#</cfoutput>
</p>

<cfdump var="#result#">
