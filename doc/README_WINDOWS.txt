NOTES ABOUT THE WINDOWS RELEASE OF MAS VERSION 1.6.6q



Prerequisites for the Charting Application

The Java Runtime Environment (JRE) needs to be installed on your system
before the charting program can be run.  If you don't have the JRE
on your system, you can download and install it (the latest version
at the time of this release, 1.4.2) by pointing your web browser to:
http://java.sun.com/j2se/1.4.2/download.html and clicking on the link
under the heading "Download J2SE v 1.4.2_03" (about half-way down the
page), under JRE.  The link will go to a license agreement.  The JRE
is free and using it to run the charting program is allowed by the
license, so it's not necessary to read it thoroughly, though you may
want to scan it to get a sense of what it covers.  Then click "Accept"
at the bottom and click the "Continue" button to go to the next page,
where you can choose either the "Windows Offline Installation" or the
"Windows Installation", whichever you prefer, to download and install
the JRE.

If you like, you can also view the site:
http://java.sun.com/j2se/downloads.html to check if there is a later
release available.  (Note: If you're a developer, The Java Development
Kit (JDK) can be used in place of the JRE.)


Further Documentation

Under the directory in which you installed MAS, in the doc directory, you
will find some further documentation.  The file INTRODUCTION.html
provides a brief introduction to MAS, as well as license and other
information.  (The file INTRODUCTION.ps is a printable Postscript version
of this file.)  The file feature_list.txt contains a summary of MAS's
current features.  Users wanting to take advantage of MAS's advanced
capabilities, such as trading-signal generation, will probably want to
read some of the other files in the doc directory.  See the README file in
the doc directory for a short description of each file.


Viewing Charts with Data Obtained from Yahoo

To add or remove symbols of stocks you wish to view, edit the file named
"symbols" in the lib directory (under the directory in which you installed
MAS) as a plain text file.  (Notepad can be used for this purpose.)
Delete the symbol for any stocks you don't want in your list and add
the symbol, each on a separate line, for any stocks you want to view
that are not already in the list.


Viewing Charts with Data Obtained from Files on Your Hard Drive

To view stock charts with data retrieved from files on your hard drive,
you will need to find a source for your data and find a way to put
the data into files readable by the server.  When MAS is installed
on your system, some sample data files are placed in lib\data (under
the directory in which you installed MAS).  You can use these files as
examples of the data format needed by the MAS server.  Your data files
will also need to be in the lib\data directory, with one file for each
stock you want to analyze.


Changing the Settings for Obtaining Data from Yahoo

If you've configured the system to get its data from the web, you can
change settings used for obtaining the data, such as the start-date for
the retrieved data (eod_start_date), or the time at which to retrieve
end-of-day data for the current day (eod_turnover_time).  To do this,
edit the file "mas_httprc" in the lib directory (under the directory
in which you installed MAS).  The "mas_httprc" file contains comments
describing the purpose and format of each setting.
