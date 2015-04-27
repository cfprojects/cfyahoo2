<cfset searchAPI = createObject("component", "org.camden.yahoo.search")>

<cfset words = "categry,Camden,convinence,beleive,reduced,allaviate">

<cfloop index="word" list="#words#">

	<cfoutput>
	<h2>Spelling suggestions for #word#</h2>
	</cfoutput>
	
	<cfinvoke component="#searchAPI#" method="spellingSuggestion" returnVariable="result">
		<cfinvokeargument name="query" value="#word#">
	</cfinvoke>
	
	<cfdump var="#result#">

</cfloop>