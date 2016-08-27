## Winnipeg Council Documents Parser

Extracts data from [Winnipeg Council Dispositions posted to data.winnipeg.ca](https://data.winnipeg.ca/Council-Services/Public-Meeting-Disposition-Word-Format/hsbq-sj6t).

Dispositions are prepared by the City Clerks' Department using Microsoft Word. Tables are used to structure the council meeting information. 

Word saves files in docx format, which is actually a zip file full of XML. The [disposition.rb](https://github.com/OpenDemocracyManitoba/Winnipeg-Council-Document-Parser/blob/master/disposition.rb) extraction script uses the [docx gem](https://github.com/chrahunt/docx) to load up the disposition tables.

Ruby methods exist to extract:

* Council Meeting Attendance
* Reports to Council
* Bylaws
* Motions
* Recorded Votes
* Conflict of Interest Declarations

### To Do

* ~~Docx Disposition Download Script~~
* ~~Download all available docx dispositions.~~
* Change recorded vote members in all docx dispositions from tables to paragraphs.
* Change conflict of interest declaration members in all docx dispositoins from tables to paragraphs.
* Docx Disposition to JSON Script
* JSON to HTML5 Disposition Viewer 

### Changes Made to Official Disposition Docx Files

* *September 30, 2015* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *January 01, 2016* - Disposition not downloadable via data.winnipeg.ca. Download url shows as zip instead of msword.
* *April 27, 2016* - Motion table was connected to the bylaws table. Split the tables.
* *April 27, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text.
* *July 13, 2016* - Conflict of interest declaration member lists changes from table to line line-separated text.


### Setup Instructions

Assuming command line with git and Ruby (2.3.x) installed:

    git clone git@github.com:OpenDemocracyManitoba/Winnipeg-Council-Document-Parser.git
    cd Winnipeg-Council-Document-Parser
    bundle install
    bundle exec guard
