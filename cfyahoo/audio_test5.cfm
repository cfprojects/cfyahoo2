<cfset audioAPI = createObject("component", "org.camden.yahoo.audio")>

<cfset term = "e">

<cfinvoke component="#audioAPI#" method="podcastSearch" returnVariable="result">
	<cfinvokeargument name="query" value="#term#">
	<cfinvokeargument name="results" value="20">
</cfinvoke>

<cfoutput>
<h2>Podcast search for #term#</h2>
</cfoutput>

<p>
<cfoutput>Total results were: #result.totalresults#</cfoutput>
</p>

<cfdump var="#result#">
