<cfparam name="form.song" default="">

Enter a song to search for it and the code will first do a song search, then tell
you where you can download it.

<cfoutput>
<form action="#cgi.script_name#" method="post">
<input type="text" name="song" value="#form.song#"> <input type="submit" value="Search">
</form>
</cfoutput>

<cfif len(trim(form.song))>
	<cfset audioAPI = createObject("component", "org.camden.yahoo.audio")>

	<cfinvoke component="#audioAPI#" method="songSearch" returnVariable="result">
		<cfinvokeargument name="song" value="#form.song#">
	</cfinvoke>

	<cfoutput>
	<h2>Song search for #form.song#</h2>
	</cfoutput>
	
	<p>
	<cfoutput>Total results were: #result.totalresults#</cfoutput>
	</p>
	
	<cfoutput query="result">
	Match: #title#<br>
		<cfset downloads = audioAPI.downloadSearch(id)>
		<cfdump var="#downloads#" label="Downloads">
				
		<p>
		<hr>
		<p>
	</cfoutput>

</cfif>