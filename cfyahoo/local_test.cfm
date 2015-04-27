<cfset localAPI = createObject("component", "org.camden.yahoo.local")>

<cfset term = "comic book">
<cfset zip = "70508">
<cfinvoke component="#localAPI#" method="search" returnVariable="results">
	<cfinvokeargument name="query" value="#term#">
	<cfinvokeargument name="zip" value="#zip#">
</cfinvoke>

<cfoutput>
<h2>Local search for #term#/#zip#</h2>
</cfoutput>

<cfdump var="#results#">