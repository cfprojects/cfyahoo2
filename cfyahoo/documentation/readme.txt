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
   
   
If you find this code worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)

Last Updated: February 11, 2010 (2.0B)
/org/yahoo/weather.cfc - added day.code
/org/yahoo/traffic.cfc - updated to use most recent url
/org/yahoo/termexectraction.cfc - REMOVED. Notice - the code still works fine - but I do not see it documented anymore. I've copied the test file to the archived folder.
/org/yahoo/map.cfc - new URL
/org/yahoo/local.cfc - fixes a bug where an error would occur if businessurl didn't exist
/org/yahoo/image.cfc - New URL, new arguments

Notice - all of the CFCs in the package were updated for copyright upates.

Last Updated: September 24, 2009 (2.0A)

IMPORTANT NOTICE

This is the beginning of an updated version of the CFYahoo package. Many of the APIs have changed and I'm beginning the process of updating
the code. I'm detailing what I know SHOULD work. Anything NOT listed here is NOT gauranteed to work now. The archived folder contains the 1.0
version of the CFCs. The CFCs in ORG now are the ones that are in progress.

As for September 24, I've updated

search.cfc
weather.cfc

to support the latest APIs. The weather API did not change, but the URL was updated. The search API had massive updates, including new arguments
and results. Please look at the method hint arguments for details. 

Also note that base.cfc was updated to include my Application ID. I believe this is ok with Yahoo, but if I'm wrong, I'll be removing it.

Last Updated: December 6, 2007 (1.0)
search.cfc - handle missing cache 

Last Updated: February 26, 2007 (0.9)
search.cfc - check for error in returned xml

Last Updated: February 26, 2007 (0.8)
locale.cfc - Code now checks lastreviewdate to ensure it isn't empty.

Last Updated: January 5, 2007 (0.7)
Addition of installation instructions. These are not complete, but cover installing, getting an application key, and the Answers API.
/org/camden/yahoo/base.cfc - Removed my application key from the code.

