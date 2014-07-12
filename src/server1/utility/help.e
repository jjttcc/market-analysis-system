note
	description: "Help messages for user interface"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class HELP inherit

	APPLICATION_HELP

creation

	make

feature -- Initialization

	make
		local
			s: STRING
		do
			-- (Was changed from arr_make(n1, n2) - See PERIOD_TYPE_FACILITIES
			-- for info on the bug/reason.)
			create contents.make_empty
			s :=
"%NSelect tradable: Select a tradable out of the current list for viewing.%N%
%View data: View the selected tradable's data, or one or more technical%N%
%   indicators for that tradable.%N%
%Edit indicators: Create, edit, or remove technical indicators.%N%
%Edit market analyzers: Create, edit, or remove market analyzers.%N%
%Run market analysis: Run an analysis of all tradables for each registrant%N%
%   using the parameters configured for the registrant.%N%
%Set date for market analysis: Set the date of the earliest trading period %N%
%   to be processed in market analysis.%N%
%Edit event registrants: Add, remove, view, or edit registrants for%N%
%   notification of events detected during market analysis.%N%
%End client session: Exit this command-line client session.%N%
%%NNote:  Set env. var. MAS_NO_CLOSE to force sockets to stay open%N%
%after each response is sent to the client. (Default is always close.)%N"
			contents.force(s, Main)
			s :=
"%NView market data: View data of the selected trading period for the %
%current %N   tradable.%N%
%View an indicator: Select a technical indicator and view its results on %N%
%   the current tradable or view its description.%N%
%View name: View the name of the currently selected tradable.%N%
%Change data period type: Change the type of trading period (daily, weekly, %N%
%    etc.) to use for the current tradable.%N"
			contents.force(s, View_data)
			s :=
"%NAdd registrants: Add one or more registrants (users or log files) who %N%
%   will receive notification of market analysis events.%N%
%Remove registrants: Remove an existing registrant from the database.%N%
%View registrants: View information about a registrant.%N%
%Edit registrants: Add or remove event types for a registrant.  (An event %N%
%   type specifies a specific kind of market analysis event, such as %N%
%   %"Stochastic %%K + -> - slope change event%".  A registrant who is %N%
%   registered for an event type will receive notification of all events %N%
%   for that type that are detected by the system during a market %N%
%   analysis run.)%N"
			contents.force(s, Edit_event_registrants)
			s :=
"%NUser: Create a registrant that is a user with an email address.%N%
%Log file: Create a registrant that is a log file.  (Not recommended at %N%
%   this point, since a bug related to saving the configuration for the %N%
%   log file will cause a core dump.)%N"
			contents.force(s, Add_registrants)
			s :=
"%NRemove event type: Select an event type registered to the current %N%
%   registrant and remove it from the registrant's list of event types.%N%
%Add event types: Select one or more event types and register them to %N%
%   the current registrant.%N"
			contents.force(s, Edit_registrant)
			s :=
"%NPrint indicator: Print the result of processing the data for the current %N%
%   tradable using the selected indicator.%N%
%View description: View a short description of the currently selected %N%
%   indicator.%N%
%View long description: View a detailed description of the currently %N%
%   selected indicator.%N"
			contents.force(s, View_indicator)
			s := "(This will soon be help for setting CEG time extensions)%N"
			contents.force(s, Compound_event_generator_time_extensions)
			s := "(This will soon be help for setting CEG left target type)%N"
			contents.force(s, Compound_event_generator_left_target_type)
		end

feature -- Access

	Main: INTEGER = 3
	View_data: INTEGER = 4
	Set_analysis_date: INTEGER = 5
	Edit_event_registrants: INTEGER = 6
	Add_registrants: INTEGER = 7
	Edit_registrant: INTEGER = 8
	View_indicator: INTEGER = 9
	Compound_event_generator_time_extensions: INTEGER = 11
	Compound_event_generator_left_target_type: INTEGER = 12

feature -- Access

	infix "@" (i: INTEGER): STRING
		do
			Result := contents @ i
		end

feature {NONE} -- Implementation

	contents: ARRAY [STRING]

end -- class HELP
