indexing
	description: "Debugging settings for the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	DEBUG_STATE

create

	make

feature -- Initialization

	make_false is
			-- Set all BOOLEAN queries to false.
		do
			market_functions := False
			event_processing := False
			data_retrieval := False
		ensure
			all_false: not market_functions and not event_processing and
				not data_retrieval
		end

	make_true is
			-- Set all BOOLEAN queries to true.
		do
			market_functions := True
			event_processing := True
			data_retrieval := True
		ensure
			all_true: market_functions and event_processing and
				data_retrieval
		end

feature {NONE} -- Initialization

	make is
		do
		ensure
			all_false: not market_functions and not event_processing and
				not data_retrieval
		end

feature -- Access

	market_functions: BOOLEAN
			-- Is debugging on for MARKET_FUNCTIONs?

	event_processing: BOOLEAN
			-- Is debugging on for event processing?

	data_retrieval: BOOLEAN
			-- Is debugging on for data retrieval?

feature -- Element change

	set_market_functions (arg: BOOLEAN) is
			-- Set `market_functions' to `arg'.
		do
			market_functions := arg
		ensure
			market_functions_set: market_functions = arg
		end

	set_event_processing (arg: BOOLEAN) is
			-- Set `event_processing' to `arg'.
		do
			event_processing := arg
		ensure
			event_processing_set: event_processing = arg
		end

	set_data_retrieval (arg: BOOLEAN) is
			-- Set `data_retrieval' to `arg'.
		do
			data_retrieval := arg
		ensure
			data_retrieval_set: data_retrieval = arg
		end

end
