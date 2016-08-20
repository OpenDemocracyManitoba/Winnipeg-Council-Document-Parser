## Winnipeg Council Documents Parser

Extracts data from [Winnipeg Council Dispositions posted to data.winnipeg.ca](https://data.winnipeg.ca/Council-Services/Public-Meeting-Disposition-Word-Format/hsbq-sj6t).

Dispositions are prepared by the City Clerks' Department using Microsoft Word. Tables are used to structure the council meeting information. 

Word saves files in docx format, which is actually a zip file full of XML. The [disposition.rb](https://github.com/OpenDemocracyManitoba/Winnipeg-Council-Document-Parser/blob/master/disposition.rb) extraction script uses the [docx gem](https://github.com/chrahunt/docx) to load up the disposition tables.

Ruby methods exist to extract:

* Council Meeting Attendance (done)
* Reports to Council (done)
* Bylaws (done)
* Motions (done)
* Recorded Votes (done)
* Conflict of Interest Declarations (done)

### To Do

* Docx Disposition to JSON Script
* Docx Disposition Download Script
* Change recorded vote members in all docx dispositions from tables to paragraphs.
* Change conflict of interest declaration members in all docx dispositoins from tables to paragraphs.
* Fix April 27, 2016 docx disposition. Motion table is connected to the bylaws table. Then remove TODO from spec code.
* JSON to HTML5 Disposition Viewer 

### Setup Instructions

Assuming command line with git and Ruby (2.3.x) installed:

    git clone git@github.com:OpenDemocracyManitoba/Winnipeg-Council-Document-Parser.git
    cd Winnipeg-Council-Document-Parser
    bundle install
    bundle exec guard
