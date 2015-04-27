<cfset answerAPI = createObject("component", "org.camden.yahoo.answers")>

<cfinvoke component="#answerAPI#" method="questionSearch" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
</cfinvoke>

<cfdump var="#result#" label="Question search for 'coldfusion'">

<cfinvoke component="#answerAPI#" method="questionSearch" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
	<cfinvokeargument name="search_in" value="best_answer">
</cfinvoke>

<cfdump var="#result#" label="Question search for 'coldfusion', search in best_answer">

<cfinvoke component="#answerAPI#" method="questionSearch" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
	<cfinvokeargument name="results" value="5">
	<cfinvokeargument name="start" value="5">
</cfinvoke>

<cfdump var="#result#" label="Question search for 'coldfusion', start=5, results=5">

<cfinvoke component="#answerAPI#" method="questionSearch" returnVariable="result">
	<cfinvokeargument name="query" value="coldfusion">
	<cfinvokeargument name="type" value="resolved">
</cfinvoke>

<cfdump var="#result#" label="Question search for 'coldfusion', type=resolved">
