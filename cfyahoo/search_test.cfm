<cfset searchAPI = createObject("component", "org.camden.yahoo.search")>

<cfinvoke component="#searchAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion blog">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion blog'" expand="false">

<p>
<hr>
</p>

<cfinvoke component="#searchAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion blog">
	<cfinvokeargument name="start" value="50">
	<cfinvokeargument name="longabstract" value="true">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion blog', start=50,longabstract=true" expand="false">

<p>
<hr>
</p>

<cfinvoke component="#searchAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion blog">
	<cfinvokeargument name="highlight" value="false">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion', no highlight" expand="false">

<p>
<hr>
</p>

<cfinvoke component="#searchAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
	<cfinvokeargument name="format" value="msoffice">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion', msoffice" expand="false">

<p>
<hr>
</p>

<cfinvoke component="#searchAPI#" method="search" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
	<cfinvokeargument name="site" value="www.coldfusionjedi.com">
</cfinvoke>

<cfdump var="#result#" label="Search for 'coldfusion', site restriction">
