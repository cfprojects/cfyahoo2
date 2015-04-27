<cfset audioAPI = createObject("component", "org.camden.yahoo.audio")>

<cfinvoke component="#audioAPI#" method="songSearch" returnVariable="result">
	<cfinvokeargument name="song" value="The Reflex">
</cfinvoke>

<h2>Song search for Precious Things</h2>

<p>
<cfoutput>Total results were: #result.totalresults#</cfoutput>
</p>

<cfdump var="#result#">
