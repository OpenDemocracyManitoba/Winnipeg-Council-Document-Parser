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

Scripts exist to:

* Download all available DOCX Disposition From Wpg Open Data Portal
* Convert DOCX Dispositions to JSON Format
* Convert JSON Dispositions to Web Pages for WinnipegElected.ca

### To Do

* Add images of "Movers" to Council Motions
* Style Recorded Votes with Icons and Colours for Web Dispositions
* Colourize Disposition Column for Reports, Motions, ByLaws
* Show Councillors Not in Attendance
* Create DB for YouTube & DMIS disposition metadata.
* Pre-process all Docx Disposition tables to remove blank rows.

### Changes Made to Official Disposition Docx Files

When downloading new Disposition Docx files:

* Change recorded vote members in all docx dispositions from tables to paragraphs.
* Change conflict of interest declaration members in all docx dispositoins from tables to paragraphs.

* *September 30, 2015* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *October 28, 2015* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *November 25, 2015* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *January 01, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text. Recorded votes had to be combined into a single table. Removed a blank row from the first report. 
* *February 25, 2016* - Conflict of interest declaration member lists changes from table to line line-separated text.
* *March 23, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *April 27, 2016* - Motion table was connected to the bylaws table. Split the tables.
* *April 27, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text.
* *May 18, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *June 15, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *July 13, 2016* - Conflict of interest declaration member lists changes from table to line line-separated text.
* *September 28, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *October 26, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *November 16, 2016* - Recorded vote Yeas/Nays lists changed from tables to line-separated text
* *December 14, 2016* - Recorded vote Yeas/Nays and conflict of interest lists changed from tables to line-separated text

### Report to City Clerks' Department

* Reported: Changes to disposition template: Recorded vote and conflict of interest lists changes from tables to line-separated text.

### Setup Instructions

Assuming command line with git and Ruby (2.3.x) installed:

    git clone git@github.com:OpenDemocracyManitoba/Winnipeg-Council-Document-Parser.git
    cd Winnipeg-Council-Document-Parser
    bundle install
    bundle exec guard
    
### WinnipegElection.ca Build Process

    ruby download_dispositions.rb -l -f word_dispositions/
    ./all_docx_to_json.sh word_dispositions json_dispositions
    ruby ./disposition_all_json_to_html.rb html_templates/disposition_template.html.erb html_templates/index_template.html.erb json_dispositions html_dispositions

Note: The `disposition_all_json_to_html.rb` script must be manually updated for each new disposition with YouTube and DMIS details.
