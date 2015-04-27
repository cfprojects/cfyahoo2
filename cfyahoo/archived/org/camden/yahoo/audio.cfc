<!---
	Name         : audio.cfc
	Author       : Raymond Camden 
	Created      : October 23, 2006
	Last Updated : December 8, 2006
	History      : podcast search added (rkc 11/6/06)
				 : invalid query col in artist search (rkc 12/8/06)
	Purpose		 : Audio API

LICENSE 
Copyright 2006 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->
<cfcomponent output="false" extends="base">

<cffunction name="albumSearch" returnType="query" output="false" access="public"
			hint="Search just albums.">
	<cfargument name="artist" type="string" required="false" hint="Artist name.">
	<cfargument name="artistid" type="string" required="false" hint="Specific Artist ID (as returned by earlier queries).">
	<cfargument name="album" type="string" required="false" hint="Album name.">
	<cfargument name="albumid" type="string" required="false" hint="Specific Album ID (as returned by earlier queries).">
	
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">


	<cfset var q = queryNew("totalresults,firstresult,id,title,artist,artistid,publisher,releasedate,thumbnail,thumbnailwidth,thumbnailheight,relatedalbums")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/AudioSearchService/V1/albumSearch?appid=">
	<cfset var x = "">
	<cfset var y = "">
	<cfset var node = "">
	<cfset var rAlbum = "">
	<cfset var relatedAlbums = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">
	
	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<!--- must have artist or artistid  or album or album id--->
	<cfif not structKeyExists(arguments, "artist") and not structKeyExists(arguments, "artistid")
		  and not structKeyExists(arguments, "album") and not structKeyExists(arguments, "albumid")
			>
		<cfthrow message="Must pass either Album, Album ID, Artist, or ArtistID argument.">
	</cfif>

	<!--- give preference to album --->
	<cfif structKeyExists(arguments, "album")>
		<cfset theURL = theURL & "&album=#urlEncodedFormat(arguments.album)#">
	<cfelseif structKeyExists(arguments, "albumid")>
		<cfset theURL = theURL & "&albumid=#arguments.albumid#">
	<cfelseif structKeyExists(arguments, "artist")>
		<cfset theURL = theURL & "&artist=#urlEncodedFormat(arguments.artist)#">
	<cfelse>
		<cfset theURL = theURL & "&artistid=#arguments.artistid#">
	</cfif>	
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>

		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			
			<cfset data.id = node.xmlAttributes.id>
			<cfset data.title = node.title.xmlText>

			<cfset data.artistid = node.artist.xmlAttributes.id>
			<cfset data.artist = node.artist.xmlText>

			<cfset data.publisher = node.publisher.xmlText>
			<cfset data.releasedate = node.releasedate.xmlText>
			
			<cfif structKeyExists(node, "thumbnail")>
				<cfset data.thumbnail = node.thumbnail.url.xmltext>
				<cfset data.thumbnailwidth = node.thumbnail.width.xmlText>
				<cfset data.thumbnailheight = node.thumbnail.height.xmlText>
			</cfif>
			
			<cfset relatedAlbums = arrayNew(1)>
			<cfif structKeyExists(node, "RelatedAlbums")>
				<cfloop index="y" from="1" to="#arrayLen(node.RelatedAlbums.Artist)#">
					<cfset rAlbum = structNew()>
					<cfset rAlbum.id = node.RelatedAlbums.Album[y].xmlAttributes.id>
					<cfset rAlbum.name = node.RelatedAlbums.Album[y].xmlText>
					<cfset arrayAppend(relatedAlbums, rAlbum)>
				</cfloop>
			</cfif>
			<cfset data.relatedAlbums = relatedAlbums>
						
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>
</cffunction>

<cffunction name="artistSearch" returnType="query" output="false" access="public"
			hint="Search just artists.">
	<cfargument name="artist" type="string" required="false" hint="Artist name.">
	<cfargument name="artistid" type="string" required="false" hint="Specific Artist ID (as returned by earlier queries).">
	
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">


	<cfset var q = queryNew("totalresults,firstresult,id,name,thumbnail,thumbnailwidth,thumbnailheight,relatedartists,popularsongs,song,yahoomusicurl")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/AudioSearchService/V1/artistSearch?appid=">
	<cfset var x = "">
	<cfset var y = "">
	<cfset var node = "">
	<cfset var rArtist = "">
	<cfset var relatedArtists = "">
	<cfset var pSongs = "">
	<cfset var pSong = "">
	
	<cfset var data = "">
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<!--- must have artist or artistid --->
	<cfif not structKeyExists(arguments, "artist") and not structKeyExists(arguments, "artistid")>
		<cfthrow message="Must pass either Artist or ArtistID argument.">
	</cfif>
	
	
	<!--- give preference to artist --->
	<cfif structKeyExists(arguments, "artist")>
		<cfset theURL = theURL & "&artist=#urlEncodedFormat(arguments.artist)#">
	<cfelse>
		<cfset theURL = theURL & "&artistid=#arguments.artistid#">
	</cfif>	
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>

		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			
			<cfset data.id = node.xmlAttributes.id>
			<cfset data.name = node.name.xmlText>
			
			<cfif structKeyExists(node, "thumbnail")>
				<cfset data.thumbnail = node.thumbnail.url.xmltext>
				<cfset data.thumbnailwidth = node.thumbnail.width.xmlText>
				<cfset data.thumbnailheight = node.thumbnail.height.xmlText>
			</cfif>
			
			<cfset relatedArtists = arrayNew(1)>
			<cfif structKeyExists(node, "RelatedArtists")>
				<cfloop index="y" from="1" to="#arrayLen(node.RelatedArtists.Artist)#">
					<cfset rArtist = structNew()>
					<cfset rArtist.id = node.RelatedArtists.Artist[y].xmlAttributes.id>
					<cfset rArtist.name = node.RelatedArtists.Artist[y].xmlText>
					<cfset arrayAppend(relatedArtists, rArtist)>
				</cfloop>
			</cfif>
			<cfset data.relatedartists = relatedArtists>
			
			<cfset pSongs = arrayNew(1)>
			<cfif structKeyExists(node, "PopularSongs")>
				<cfloop index="y" from="1" to="#arrayLen(node.PopularSongs.Song)#">
					<cfset pSong = structNew()>
					<cfset pSong.id = node.PopularSongs.Song[y].xmlAttributes.id>
					<cfset pSong.name = node.PopularSongs.Song[y].xmlText>
					<cfset arrayAppend(pSongs, pSong)>
				</cfloop>
			</cfif>
			<cfset data.popularsongs = pSongs>
			
			<cfif structKeyExists(node, "yahoomusicpage")>
				<cfset data.yahoomusicurl = node.yahoomusicpage.xmlText>
			</cfif>
			
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>
</cffunction>

<!--- Doc for restrictions code:

    *   drm denotes files with some form of digital rights management.
    * subrequired means a subscription to the appropriate service is required.
    * subnotrequired means a subscription to the appropriate service is not required.
    * win denotes files that will play on Windows.
    * mac denotes files that will play on Apple Macintoshes.
    * copyokay means this file may be copied.
    * copynotokay means this file may not be copied.
    * cdokay means this file may be burned to CD.
	
	Taken from here: http://developer.yahoo.com/search/audio/V1/songDownloadLocation.html
--->
<cffunction name="downloadSearch" returnType="query" output="false" access="public"
			hint="Searches for downloads. For quality, 1 is worst, 5 is best. ">
	<cfargument name="songid" type="string" required="true" hint="Song ID.">	
	<cfargument name="source" type="string" required="false" default="" hint="Where to search. Valid values are: audiolunchbox,artistdirect,buymusic,dmusic,emusic,epitonic,garageband,itunes,yahoo,livedownloads,mp34u,msn,musicmatch,napster,passalong,rhapsody,soundclick,theweb">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">


	<cfset var q = queryNew("totalresults,firstresult,source,url,format,price,length,channels,restrictions,quality")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/AudioSearchService/V1/songDownloadLocation?appid=">
	<cfset var x = "">
	<cfset var y = "">
	<cfset var node = "">
	<cfset var rAlbum = "">
	<cfset var relatedAlbums = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<cfset theURL = theURL & "&songid=#arguments.songid#">
	<cfset theURL = theURL & "&source=#arguments.source#">
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		
		<cfif structKeyExists(xmlResult, "error")>
			<cfthrow message="Audio API Error: #xmlResult.error.message.xmltext#">
		</cfif>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>

		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>

		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			
			<cfset data.source = node.source.xmltext>
			<cfset data.url = node.url.xmltext>
			<cfset data.format = node.format.xmltext>
			<cfif structKeyExists(node, "price")>
				<cfset data.price = node.price.xmltext>
			<cfelse>
				<cfset data.price = "">
			</cfif>
			<cfset data.length = node.length.xmltext>
			<cfset data.channels = node.channels.xmltext>
			<cfset data.restrictions = node.restrictions.xmltext>
			<cfif structKeyExists(node, "quality")>
				<cfset data.quality = node.quality.xmltext>
			<cfelse>
				<cfset data.quality = "">
			</cfif>
			
						
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>
</cffunction>

<cffunction name="podcastSearch" returnType="query" output="false" access="public"
			hint="Search podcasts.">
	<cfargument name="query" type="string" required="true" hint="The query to search for. You can use + to include terms, - to remove them, and quotes fora phase search.">	
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">
	<cfargument name="format" type="string" required="false" default="all" hint="Kind of audio file to search for. Valid values are: 	all, aiff, midi, mp3, msmedia, quicktime, realmedia, wav, other">
	<cfargument name="adult" type="boolean" required="false" default="false" hint="If true, adult results may be returned.">

	<cfset var q = queryNew("totalresults,firstresult,title,summary,url,clickurl,refererurl,filesize,fileformat,duration,samplesize,channels,streaming,publisher,restrictions,copyright")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/AudioSearchService/V1/podcastSearch?appid=">
	<cfset var x = "">
	<cfset var node = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">
	
	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<cfset theURL = theURL & "&format=#arguments.format#">
	<cfset theURL = theURL & "&adult_ok=#arguments.adult#">
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>

		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			
			<cfset data.title = node.title.xmlText>
			<cfset data.summary = node.summary.xmlText>
			<cfset data.url = node.url.xmlText>
			<cfset data.clickurl = node.clickurl.xmlText>
			<cfset data.refererUrl = node.refererUrl.xmlText>
			<cfset data.filesize = node.filesize.xmlText>
			<cfset data.fileformat = node.fileformat.xmlText>
			<cfset data.duration = node.duration.xmlText>
			<cfif structKeyExists(node, "samplesize")>
				<cfset data.samplesize = node.samplesize.xmlText>
			<cfelse>
				<cfset data.samplesize = "">
			</cfif>
			<cfset data.channels = node.channels.xmlText>
			<cfset data.streaming = node.streaming.xmlText>
			<cfset data.publisher = node.publisher.xmlText>
			<cfif structKeyExists(node, "restrictions")>
				<cfset data.restrictions = node.restrictions.xmlText>
			<cfelse>
				<cfset data.restrictions = "">
			</cfif>
			<cfset data.copyright = node.copyright.xmlText>
		
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>
</cffunction>

<cffunction name="songSearch" returnType="query" output="false" access="public"
			hint="Search just albums.">
	<cfargument name="artist" type="string" required="false" hint="Artist name.">
	<cfargument name="artistid" type="string" required="false" hint="Specific Artist ID (as returned by earlier queries).">
	<cfargument name="album" type="string" required="false" hint="Album name.">
	<cfargument name="albumid" type="string" required="false" hint="Specific Album ID (as returned by earlier queries).">
	<cfargument name="song" type="string" required="false" hint="Song name.">
	<cfargument name="songid" type="string" required="false" hint="Specific Song ID (as returned by earlier queries).">
	
	<cfargument name="type" type="string" required="false" default="all" hint="Type of search. Valid values are: all (searches all search terms), any (searches any search term), phrase (phrase based search)">
	<cfargument name="start" type="numeric" required="false" default="1" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">


	<cfset var q = queryNew("totalresults,firstresult,id,title,artist,artistid,album,albumid,publisher,releasedate,length,track,thumbnail,thumbnailwidth,thumbnailheight")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/AudioSearchService/V1/songSearch?appid=">
	<cfset var x = "">
	<cfset var node = "">
	
	<cfset var data = structNew()>
	<cfset var key = "">
	
	<cfset var totalresults = "">
	<cfset var firstResult = "">
		
	<cfset theURL = theURL & getAppID()>

	<cfif not listFindNoCase("all,any,phrase", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, any, or phrase allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">

	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 1 or arguments.start + arguments.results gt 1000>
		<cfthrow message="Invalid start (#arguments.start#) passed. Max value of start + results value must be less than 1000, min is 1.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">

	<!--- must have artist or artistid  or album or album id--->
	<cfif not structKeyExists(arguments, "artist") and not structKeyExists(arguments, "artistid")
		  and not structKeyExists(arguments, "album") and not structKeyExists(arguments, "albumid")
		  and not structKeyExists(arguments, "song") and not structKeyExists(arguments, "songid")		  	
			>
		<cfthrow message="Must pass either Album, Album ID, Artist, or ArtistID argument.">
	</cfif>

	<!--- give preference to song --->
	<cfif structKeyExists(arguments, "song")>
		<cfset theURL = theURL & "&song=#urlEncodedFormat(arguments.song)#">
	<cfelseif structKeyExists(arguments, "songid")>
		<cfset theURL = theURL & "&songid=#arguments.songid#">
	<cfelseif structKeyExists(arguments, "album")>
		<cfset theURL = theURL & "&album=#urlEncodedFormat(arguments.album)#">
	<cfelseif structKeyExists(arguments, "albumid")>
		<cfset theURL = theURL & "&albumid=#arguments.albumid#">
	<cfelseif structKeyExists(arguments, "artist")>
		<cfset theURL = theURL & "&artist=#urlEncodedFormat(arguments.artist)#">
	<cfelse>
		<cfset theURL = theURL & "&artistid=#arguments.artistid#">
	</cfif>	
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfset totalResults = xmlResult.ResultSet.xmlAttributes.totalResultsAvailable>
		<cfset firstResult = xmlResult.ResultSet.xmlAttributes.firstResultPosition>

		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<!--- metadata --->
			<cfset data.totalResults = totalResults>
			<cfset data.firstResult = firstResult>
			
			<cfset data.id = node.xmlAttributes.id>
			<cfset data.title = node.title.xmlText>

			<cfset data.artistid = node.artist.xmlAttributes.id>
			<cfset data.artist = node.artist.xmlText>

			<cfset data.albumid = node.album.xmlAttributes.id>
			<cfset data.album = node.album.xmlText>
			<cfset data.publisher = node.publisher.xmlText>
			<cfset data.releasedate = node.releasedate.xmlText>
			<cfset data.length = node.length.xmlText>
			<cfset data.track = node.track.xmlText>
			
			<cfif structKeyExists(node, "thumbnail")>
				<cfset data.thumbnail = node.thumbnail.url.xmltext>
				<cfset data.thumbnailwidth = node.thumbnail.width.xmlText>
				<cfset data.thumbnailheight = node.thumbnail.height.xmlText>
			</cfif>
			
			<cfset queryAddRow(q)>
			<cfloop item="key" collection="#data#">
				<cfset querySetCell(q, key, data[key])>
			</cfloop>
			
		</cfloop>

	</cfif>

	<cfreturn q>
</cffunction>


</cfcomponent>