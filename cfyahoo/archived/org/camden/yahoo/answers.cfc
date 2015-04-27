<!---
	Name         : answers.cfc
	Author       : Raymond Camden 
	Created      : October 12, 2006
	Last Updated : October 12, 2006
	History      : Added header.
	Purpose		 : Answer API

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

<cffunction name="questionSearch" returnType="query" output="false" access="public"
			hint="Main answer search API.">
	<cfargument name="query" type="string" required="true" hint="Search terms.">
	<cfargument name="search_in" type="string" required="false" default="all" hint="Search for keywords in: all (default), question, best_answer, nickname.">
	<cfargument name="category_id" type="string" required="false" default="" hint="Restrict to a list of category IDs.">
	<cfargument name="category_name" type="string" required="false" default="" hint="Restrict to category name.">
	<cfargument name="region" type="string" required="false" default="us" hint="Region. Supported regions are: us,uk,ca,au,in,es,br,ar,mx,e1,it,de,fr,sg.">
	<cfargument name="date_range" type="string" required="false" default="all" hint="Filter based on date submitted. all,7,7-30,30-60,60-90,more90. Values are in days.">
	<cfargument name="sort" type="string" required="false" default="relevance" hint="Sorts results. Supported values are: relevance, date_desc, and date-asc.">
	<cfargument name="type" type="string" required="false" default="all" hint="Question type status. Valid values are: all, resolved, open, undecided.">
	<cfargument name="start" type="numeric" required="false" default="0" hint="Starting position.">
	<cfargument name="results" type="numeric" required="false" default="10" hint="Number of results. Max is 50.">


	<cfset var q = queryNew("id,type,subject,question,date,link,category,categoryid,userid,usernick,userphotourl,numanswers,numcomments,chosenanswer,chosenanswererid,chosenanswerernick,chosenanswerdate,chosenanswerawarddate")>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://answers.yahooapis.com/AnswersService/V1/questionSearch?appid=">
	<cfset var x = "">
	<cfset var node = "">

	<cfset var data = structNew()>
	<cfset var key = "">
		
	<cfset theURL = theURL & getAppID()>
	<cfset theURL = theURL & "&query=#urlEncodedFormat(arguments.query)#">
	
	<cfif not listFindNoCase("all,question,best_answer,nickname", arguments.search_in)>
		<cfthrow message="Invalid search_in (#arguments.search_in#) passed. Only all, question, best_answer, nickname allowed.">
	</cfif>
	<cfset theURL = theURL & "&search_in=#arguments.search_in#">

	<cfif len(arguments.category_id)>
		<cfset theURL = theURL & "&category_id=#arguments.category_id#">
	</cfif>

	<cfif len(arguments.category_name)>
		<cfset theURL = theURL & "&category_name=#urlEncodedFormat(arguments.category_name)#">
	</cfif>

	<cfset theURL = theURL & "&region=#arguments.region#">

	<cfif not listFindNoCase("all,7,7-30,30-60,60-90,more90", arguments.date_range)>
		<cfthrow message="Invalid date_range (#arguments.date_range#) passed. Only all, 7, 7-30, 30-60, 60-90, more90 allowed.">
	</cfif>
	<cfset theURL = theURL & "&date_range=#arguments.date_range#">

	<cfif not listFindNoCase("relevance,date_desc,date_asc", arguments.sort)>
		<cfthrow message="Invalid sort (#arguments.sort#) passed. Only relevance, date_desc, date_asc allowed.">
	</cfif>
	<cfset theURL = theURL & "&sort=#arguments.sort#">

	<cfif not listFindNoCase("all,resolved,open,undecided", arguments.type)>
		<cfthrow message="Invalid type (#arguments.type#) passed. Only all, resolved, open, undecided allowed.">
	</cfif>
	<cfset theURL = theURL & "&type=#arguments.type#">
	
	<cfif arguments.results lt 1 or arguments.results gt 50>
		<cfthrow message="Invalid results (#arguments.results#) passed. Max is 50, min is 1.">
	</cfif>
	<cfset theURL = theURL & "&results=#arguments.results#">

	<cfif arguments.start lt 0>
		<cfthrow message="Invalid start (#arguments.start#) passed. Min value is 0.">
	</cfif>	
	<cfset theURL = theURL & "&start=#arguments.start#">
	
	<cfhttp url="#theURL#" result="result" charset="utf-8" />

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>

		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Question)#">
			<cfset node = xmlResult.resultSet.xmlChildren[x]>
			<cfset data = structNew()>

			<cfset data.id = node.xmlAttributes.id>
			<cfset data.type = node.xmlAttributes.type>
			<cfset data.subject = node.subject.xmlText>
			<cfset data.question = node.content.xmlText>
			<cfset data.date = epochTimeToDate(node.timestamp.xmlText)>
			<cfset data.link = node.link.xmlText>
			<cfset data.category = node.category.xmlText>
			<cfset data.categoryid = node.category.xmlattributes.id>
			<cfset data.userid = node.userid.xmlText>
			<cfset data.usernick = node.usernick.xmlText>
			<cfset data.userphotourl = node.userphotourl.xmlText>
			<cfset data.numanswers = node.numanswers.xmlText>
			<cfset data.numcomments = node.numcomments.xmlText>
			<cfset data.chosenanswer = node.chosenanswer.xmlText>
			<cfset data.chosenanswererid = node.chosenanswererid.xmlText>
			<cfset data.chosenanswerernick = node.chosenanswerernick.xmlText>
			<cfset data.chosenanswerdate = node.chosenanswertimestamp.xmlText>
			<cfif len(data.chosenanswerdate)>
				<cfset data.chosenanswerdate = epochTimeToDate(data.chosenanswerdate)>
			</cfif>
			<cfset data.chosenanswerawarddate = node.chosenanswerawardtimestamp.xmlText>
			<cfif len(data.chosenanswerawarddate)>
				<cfset data.chosenanswerawarddate = epochTimeToDate(data.chosenanswerawarddate)>
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