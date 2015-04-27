<cfset imageAPI = createObject("component", "org.camden.yahoo.image")>

<cfset term = "ColdFusion">
<cfinvoke component="#imageAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="#term#">
	<cfinvokeargument name="dimensions" value="wallpaper">
</cfinvoke>

<cfoutput>
<h2>Image search for #term#</h2>
</cfoutput>

<p>
<cfoutput>Total results were: #result.recordcount#</cfoutput>
</p>

<cfoutput query="result">
<cfif len(thumbnail_url)>
<img src="#thumbnail_url#" width="#thumbnail_width#" height="#thumbnail_height#" alt="#title#" align="left">
</cfif>
<h3>#title#</h3>
URL: <a href="#clickurl#">#result.url#</a><br />

#abstract#

<br clear="left">

<p>
<hr>
</p>
</cfoutput>
