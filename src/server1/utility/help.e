indexing
	description: "Help messages for user interface"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HELP inherit

	ARRAY [STRING]
		rename
			make as arr_make
		end

creation

	make

feature -- Initialization

	make is
		local
			s: STRING
		do
			arr_make (Main, Compound_event_generator_left_target_type)
			s :=
"%NSelect market: Select a market out of the current list for viewing.%N%
%View data: View the selected markets's data, or one or more technical%N%
%   indicators for that market.%N%
%Edit indicators: Edit technical indicators used directly on market data or%N%
%   technical indicators used for market analysis.%N%
%Run market analysis: Run an analysis of all markets for each registrant%N%
%   using the parameters configured for the registrant.%N%
%Set date for market analysis: Set the date of the earliest trading period %N%
%   to be processed in market analysis.%N%
%Edit event registrants: Add, remove, view, or edit registrants for%N%
%   notification of events detected during market analysis.%N%
%Memory usage: view information on memory used by the program.%N"
			put (s, Main)
			s :=
"%NView market data: View data of the selected trading period for the %
%current %N   market.%N%
%View an indicator: Select a technical indicator and view its results on %N%
%   the current market or view its description.%N%
%Change data period type: Change the type of trading period (daily, weekly, %N%
%    etc.) to use for the current market.%N"
			put (s, View_data)
			s :=
"%NEdit market-data indicators: Edit the technical indicators that are %N%
%   used directly on market data.%N%
%Edit market-analysis indicators: Edit the technical indicators that are %N%
%   used on the market data for market analysis.%N"
			put (s, Edit_indicators)
			s :=
"%NSet date: Set the date at which to begin market analysis.%N%
%Set time: Set the time at which to begin market analysis.%N%
%Set date relative to current date: Set the date a specified number of %N%
%   days, months, or years back from the current date.%N%
%Set market analysis date to currently selected date: Update the system %N%
%   the newly selected date and time for market analysis.%N"
			put (s, Set_analysis_date)
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
			put (s, Edit_event_registrants)
			s :=
"%NUser: Create a registrant that is a user with an email address.%N%
%Log file: Create a registrant that is a log file.  (Not recommended at %N%
%   this point, since a bug related to saving the configuration for the %N%
%   log file will cause a core dump.)%N"
			put (s, Add_registrants)
			s :=
"%NRemove event type: Select an event type registered to the current %N%
%   registrant and remove it from the registrant's list of event types.%N%
%Add event types: Select one or more event types and register them to %N%
%   the current registrant.%N"
			put (s, Edit_registrant)
			s :=
"%NPrint indicator: Print the result of processing the data for the current %N%
%   market using the selected indicator.%N%
%View description: View a short description of the currently selected %N%
%   indicator.%N%
%View long description: View a detailed description of the curretnly %N%
%   selected indicator.%N"
			put (s, View_indicator)
			s := "(This will soon be 'edit event generators' help)%N"
			put (s, Edit_event_generators)
			s := "(This will soon be help for setting CEG time extensions)%N"
			put (s, Compound_event_generator_time_extensions)
			s := "(This will soon be help for setting CEG left target type)%N"
			put (s, Compound_event_generator_left_target_type)
		end

feature -- Access

	Main, View_data, Set_analysis_date, Edit_event_registrants,
	Add_registrants, Edit_registrant, View_indicator, Edit_indicators,
	Edit_event_generators, Compound_event_generator_time_extensions,
	Compound_event_generator_left_target_type:
		INTEGER is unique

end -- class HELP
