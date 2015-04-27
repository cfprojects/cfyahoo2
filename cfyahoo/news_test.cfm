<cfset newsAPI = createObject("component", "org.camden.yahoo.news")>

<cfinvoke component="#newsAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="Iraq">
	<cfinvokeargument name="age" value="12h">
</cfinvoke>

<h2>News search for Iraq</h2>

<p>
<cfoutput>Total results were: #result.totalresults#</cfoutput>
</p>

<cfoutput query="result">
<cfif len(thumbnail)>
<img src="#thumbnail#" width="#thumbnailwidth#" height="#thumbnailheight#" alt="#title#" align="left">
</cfif>
<h3>#title#</h3>
URL: <a href="#clickurl#">#result.url#</a><br />

#abstract#

<p>
<hr>
</p>
</cfoutput>
