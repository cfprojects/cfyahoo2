<cfset mapAPI = createObject("component", "org.camden.yahoo.maps")>

<cfinvoke component="#mapAPI#" method="getMap" returnVariable="result">
	<cfinvokeargument name="zip" value="90210">
</cfinvoke>

<cfoutput>
#result#<br />
<img src="#result#">
</cfoutput>

<p>
<hr>
<p>

<cfinvoke component="#mapAPI#" method="getMap" returnVariable="result">
	<cfinvokeargument name="location" value="San Francisco, CA">
</cfinvoke>

<cfoutput>
#result#<br />
<img src="#result#">
</cfoutput>

<p>
<hr>
<p>

<cfoutput>
<img src="#mapAPI.getMap('Lafayette, LA')#">
</cfoutput>

<p>
<hr>
<p>

<cftry>
	<cfinvoke component="#mapAPI#" method="getMap" returnVariable="result">
		<cfinvokeargument name="location" value="Lafaydlndjfdjfjfkldjkfldfjlkdfklfdkl">
	</cfinvoke>
	

	<cfcatch>
		<cfoutput>Failure: Message was #cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>
