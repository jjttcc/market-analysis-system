NOTES ABOUT THE WINDOWS RELEASE OF MAS VERSION 1.6.5


The MAS Desktop Icons

By default, the setup program will place four icons on the desktop:
"Mas Server (web)", "MAS Charts", "MAS Command Line", and "MAS Server
(files)".  "Mas Server (web)" starts the server so that it retrieves its
data from the yahoo finance site.  "MAS Charts" starts the GUI charting
program, which gets its data from the server.  "MAS Command Line" starts
a command-line interface to the server, which provides functionality
not available from the charting program (such as the ability to create
new indicators).  And "MAS Server (files)" starts the server so that it
gets its data from files on your hard drive.


Viewing Charts with Data Obtained from Yahoo

To view stock charts with data retrieved from yahoo, first make sure
your computer is connected to the internet, then double-click on the
"Mas Server (web)" icon to start the server; then double-click on the
"MAS Charts" icon to start the charting program.

To add or remove symbols of stocks you wish to view, edit the file named
"symbols" in the {mas_dir}/lib directory (where {mas_dir} stands for the
directory in which you chose to install MAS).  Delete the symbol for any
stocks you don't want in your list and add the symbol, each on a separate
line, for any stocks you want to view that are not already in the list.


Shutting Down the MAS Server

To exit the server, first close any windows opened with the "MAS Charts"
icon and then double-click on "MAS Command Line".  A command-line
interface will appear with a list of options to select from.  Simply type
Control-E.  (Hold the "Control" key down and then press on the "E" key.)
Then hit the "Enter" key.  This should shut down the server.


Viewing Charts with Data Obtained from Files on Your Hard Drive

To view stock charts with data retrieved from files on your hard drive,
you will need to find a source for your data and find a way to put the
data into files readable by the server.  When MAS is installed on your
system, some sample data files are placed in {mas_dir}/lib/data (where
{mas_dir} stands for the directory in which you chose to install MAS).
You can use these files as examples of the data format needed by the MAS
server.  Your data files will also need to be in the {mas_dir}/lib/data
directory, with one file for each stock you want to analyze.

Once you have placed your data files in {mas_dir}/lib/data, start the
server by double-clicking on "MAS Server (files)".  Then double-click
on the "MAS Charts" icon to start the charting program.


Changing the Settings for Obtaining Data from Yahoo

To change settings used for obtaining data from yahoo (when running the
server via the "Mas Server (web)" icon), such as the start-date for
the retrieved data, or the time at which to retrieve end-of-day data
for the current day, edit the file "mas_httprc" in the {mas_dir}/lib
directory (where {mas_dir} stands for the directory in which you chose
to install MAS).  The "mas_httprc" contains comments describing the
purpose and format of each setting.
