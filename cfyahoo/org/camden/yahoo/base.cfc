<!---
LICENSE 
Copyright 2010 Raymond Camden

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
<cfcomponent output="false">

<cfset variables.appid = "5rJLaITV34GaU8t05tz.MIYQfRol9PBL51PyK3KAhmRiFa0FEAtvFyD36r4xTns_VRP1">

<!---
CFLib info:
/**
* Converts a UNIX epoch time to a ColdFusion date object.
*
* @param epoch     Epoch time, in seconds. (Required)
* @return Returns a date object.
* @author Chris Mellon (mellon@mnr.org)
* @version 1, June 21, 2002
*/
--->
<cffunction name="epochTimeToDate" access="public" returnType="date" output="false">
	<cfargument name="epoch" type="numeric" required="true">
	<cfreturn dateAdd("s", epoch, "January 1 1970 00:00:00")>
</cffunction>

<cffunction name="getAppID" access="public" returnType="string" output="false" 
			hint="Returns the AppID. Used by various services.">
	<cfreturn variables.appid>
</cffunction>

<cffunction name="setAppID" access="public" returnType="void" output="false"
			hint="Sets the AppID if you do not want to use the default.">
	<cfargument name="appid" type="string" required="true">
	
	<cfset variables.appid = arguments.appid>
</cffunction>

</cfcomponent>