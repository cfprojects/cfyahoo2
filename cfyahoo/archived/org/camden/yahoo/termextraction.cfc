<!---
	Name         : termextraction.cfc
	Author       : Raymond Camden 
	Created      : October 23, 2006
	Last Updated : 
	History      : 
	Purpose		 : Term Extraction API

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

<cffunction name="getTerms" returnType="array" output="false" access="public"
			hint="Main term extraction API.">
	<cfargument name="context" type="string" required="true" hint="Text to grab terms from.">
	<cfargument name="query" type="string" required="false" hint="Helps extraction process.">

	<cfset var q = arrayNew(1)>
	<cfset var result = "">
	<cfset var xmlResult = "">
	
	<cfset var theURL = "http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction">
	<cfset var x = "">
	
	<cfif not len(trim(arguments.context))>
		<cfthrow message="Context cannot be empty.">	
	</cfif>
				
	<cfhttp url="#theURL#" result="result" charset="utf-8" method="post">
		<cfhttpparam type="formfield" name="appid" value="#getAppID()#">
		<cfhttpparam type="formfield" name="context" value="#arguments.context#">
		<cfif structKeyExists(arguments,"query") and len(trim(arguments.query))>
			<cfhttpparam type="formfield" name="query" value="#arguments.query#">
		</cfif>
		
	</cfhttp>

	<cfif len(result.fileContent) and isXml(result.fileContent)>
		<cfset xmlResult = xmlParse(result.fileContent)>
		
		<cfif not structKeyExists(xmlResult.ResultSet, "Result")>
			<cfreturn q>
		</cfif>
		
		<cfloop index="x" from="1" to="#arrayLen(xmlResult.ResultSet.Result)#">
			<cfset arrayAppend(q, xmlresult.ResultSet.Result[x].xmlText)>
		</cfloop>
	</cfif>

	<cfreturn q>
</cffunction>

</cfcomponent>