<cfset searchAPI = createObject("component", "org.camden.yahoo.search")>

<cfsavecontent variable="context">
This is some text that involves ColdFusion, Art, and the Pizza. I'm
not really sure what I want to write here, but I need to get something
that convinces Yahoo to find some cool responses. Dharma is behind everything
ya know? They run Yahoo, Google, and the NSA. It's true - I read it on the Internet.
</cfsavecontent>

<cfinvoke component="#searchAPI#" method="contextSearch" returnVariable="result">
	<cfinvokeargument name="context" value="#context#">
	<cfinvokeargument name="query" value="coldfusion">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion blog'">
