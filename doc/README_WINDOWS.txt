NOTES ABOUT THE WINDOWS RELEASE OF MAS VERSION 1.6.5


Important Note About Starting MAS for the First Time

The MAS environment settings may not take effect right away.  If you
have just installed MAS and it fails to run at first on your system,
this may be the cause.  This can be fixed on Windows 95, 98, and Me
systems by rebooting and on Windows NT, 2000, and XP systems by doing
either of the following:

   - Right-click on "My Computer", select "Properties", Select the
     "Environment" settings, and left-click on the "OK" button or

   - Log out and then log back in.


Prerequisites for the Charting Application

The Java Runtime Environment (JRE) needs to be installed on your system
before the GUI client, the part of MAS that does charting, can be run.
If you don't have the JRE on your system, you can download and install it
(the latest version at the time of this release, 1.4.1) by pointing your
web browser to: http://java.sun.com/j2se/1.4.1/download.html and clicking
on the link for the Windows version of the JRE.  If you like, you can
also view the site: http://java.sun.com/j2se/downloads.html to check
if there is a later release available.  (Note: If you're a developer,
The Java Development Kit (JDK) can be used in place of the JRE.)


Further Documentation

Under the directory in which you installed MAS, in the doc directory, you
will find some further documentation.  The file INTRODUCTION.html
provides a brief introduction to MAS, as well as license and other
information.  (The file INTRODUCTION.ps is a printable Postscript version
of this file.)  The file feature_list.txt contains a summary of MAS's
current features.  Users wanting to take advantage of MAS's advanced
capabilities, such as trading-signal generation, will probably want to
read some of the other files in the doc directory.


The MAS Desktop Icons

If you installed MAS with the default setup, you should have four icons
on your desktop: "MAS Server (web)", "MAS Charts", "MAS Command Line",
and "MAS Server (files)".  "MAS Server (web)" starts the server so
that it retrieves its data from the yahoo finance site.  "MAS Charts"
starts the GUI charting program, which gets its data from the server.
"MAS Command Line" starts a command-line interface to the server, which
provides functionality not available from the charting program (such
as the ability to create new indicators).  And "MAS Server (files)"
starts the server so that it gets its data from files on your hard drive.


Viewing Charts with Data Obtained from Yahoo

To view stock charts with data retrieved from yahoo, first make sure
your computer is connected to the internet, then double-click on the
"MAS Server (web)" icon to start the server; then double-click on the
"MAS Charts" icon to start the charting program.

To add or remove symbols of stocks you wish to view, edit the file named
"symbols" in the lib directory (under the directory in which you installed
MAS) as a plain text file.  (Notepad can be used for this purpose.)
Delete the symbol for any stocks you don't want in your list and add
the symbol, each on a separate line, for any stocks you want to view
that are not already in the list.


Shutting Down the MAS Server

To exit the server, first close any windows opened with the "MAS Charts"
icon and then double-click on "MAS Command Line".  A command-line
interface will appear with a list of options to select from.  Simply type
Control-E.  (Hold the "Control" key down and then press the "E" key.)
Then hit the "Enter" key.  This should shut down the server.


Viewing Charts with Data Obtained from Files on Your Hard Drive

To view stock charts with data retrieved from files on your hard drive,
you will need to find a source for your data and find a way to put
the data into files readable by the server.  When MAS is installed
on your system, some sample data files are placed in lib\data (under
the directory in which you installed MAS).  You can use these files as
examples of the data format needed by the MAS server.  Your data files
will also need to be in the lib\data directory, with one file for each
stock you want to analyze.

Once you have placed your data files in lib\data, start the server
by double-clicking on "MAS Server (files)".  Then double-click on the
"MAS Charts" icon to start the charting program.


Changing the Settings for Obtaining Data from Yahoo

To change settings used for obtaining data from yahoo (when running
the server via the "MAS Server (web)" icon), such as the start-date for
the retrieved data (eod_start_date), or the time at which to retrieve
end-of-day data for the current day (eod_turnover_time), edit the file
"mas_httprc" in the lib directory (under the directory in which you
installed MAS).  The "mas_httprc" file contains comments describing the
purpose and format of each setting.
