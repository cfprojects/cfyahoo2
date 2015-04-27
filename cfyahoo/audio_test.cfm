<cfset audioAPI = createObject("component", "org.camden.yahoo.audio")>

<cfinvoke component="#audioAPI#" method="artistSearch" returnVariable="result">
	<cfinvokeargument name="artist" value="Duran Duran">
</cfinvoke>

<h2>Audio search for Duran Duran</h2>

<p>
<cfoutput>Total results were: #result.totalresults#</cfoutput>
</p>

<cfoutput query="result">
	<cfif len(thumbnail)>
	<img src="#thumbnail#" width="#thumbnailwidth#" height="#thumbnailheight#" alt="#name#" align="left">
	</cfif>
	<h3>#name#</h3>
	<cfif len(yahoomusicurl)>URL: <a href="#yahoomusicurl#">#yahoomusicurl#</a><br /></cfif>

	<cfif arrayLen(popularsongs)>
		<cfset psongs = result.popularsongs[currentRow]>
	<b>Popular Songs</b> : 
		<cfloop index="x" from="1" to="#arrayLen(psongs)#">
			#psongs[x].name#<cfif x is not arrayLen(psongs)>, </cfif>
		</cfloop>
		<br />
	</cfif>

	<cfif arrayLen(relatedartists)>
		<cfset rartists = result.relatedartists[currentRow]>
	<b>Related Artists</b> : 
		<cfloop index="x" from="1" to="#arrayLen(rartists)#">
			#rartists[x].name#<cfif x is not arrayLen(rartists)>, </cfif>
		</cfloop>
		<br />
	</cfif>

	<p>
	<hr>
	</p>
</cfoutput>
	
	
