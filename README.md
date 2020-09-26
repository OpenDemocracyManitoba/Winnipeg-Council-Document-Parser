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

* Current tool can only parse Council's "Regular Meetings". Enhancements are needed to parse special meetings, like yearly committee appointment meetings.
* Automate the retrieval of YouTube and DMIS disposition metadata.
* HTML Disposition Styling and Features
    * Add images of "Movers" to Council Motions  
    * Style Recorded Votes with Icons and Colours 
    * Colourize Disposition Column for Reports, Motions, ByLaws
    * Show Councillors Not in Attendance
* Some tables span multiple pages and can accumulate bad data when the paragraphs within the cells are join. For an example, [see motion 2 in Dec 2017](http://www.winnipegelected.ca/disposition-2017-12-13.html#motions).  

### Changes Made to Official Disposition Docx Files

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
* *December 14, 2016* - Recorded vote Yeas/Nays and conflict of interest lists changed from tables to line-separated text. Fix recorded votes to match hansard. 
* *February 22, 2017* - Conflict of interest declaration member lists changes from table to line line-separated text. Typos and cases fixed in two report headers that were blocking parsing.
* *April 26, 2017* - Added missing date to the header of the water and waste report.
* *May 24, 2017* - Split two report tables (Finance May 4 and Water and Waste May 1) that were accidentally combined.
* *July 19, 2017* - Fixed spacing in recorded vote subjects. Fix recorded votes to match hansard. 
* *December 13, 2017* - Removed a misplaced comma from the end of mayor's entry in one of the recorded votes. Fix recorded votes to match hansard. 
* *March 22, 1018* - Removed a rogue number "3" in under By-Law number 30/2018.
* *July 19, 2018* - Two rows from one of the report tables were orphaned. Joined these rows to the correct table.
* *January 31, 2019* - Split two Property And Development, Heritage And Downtown Development report tables. Reworded two report titled that didn't match the usual report template. 
* *September 26, 2019* - Split a report table into two tables. Added the word "dated" to one report that was mistitled.
* *October 24, 2019* - Split a report table into two tables.
* *February 27, 2020* - Date was missing on two reports. Missing dates added after referencing official minutes on DMIS. 
* *May 29, 2020* - Recorded votes table was split into multiple tables causing the parsing to fail. Joined all recorded votes tables into a single table.
* *July 23, 2020* - Motion 7 was missing mover and seconder. Added details from DMIS.


### Report to City Clerks' Department

* Reported: Changes to disposition template: Recorded vote and conflict of interest lists changes from tables to line-separated text.

### Setup Instructions

Assuming command line with git and Ruby (2.7.x) installed:

    git clone git@github.com:OpenDemocracyManitoba/Winnipeg-Council-Document-Parser.git
    cd Winnipeg-Council-Document-Parser
    bundle install
    bundle exec guard
    
### WinnipegElection.ca Build Process

    ruby download_dispositions.rb -l -f word_dispositions/
    ./all_docx_to_json.sh word_dispositions json_dispositions
    ruby ./disposition_all_json_to_html.rb html_templates/disposition_template.html.erb html_templates/index_template.html.erb json_dispositions html_dispositions

Note: The `disposition_all_json_to_html.rb` script must be manually updated for each new disposition with YouTube and DMIS details.
