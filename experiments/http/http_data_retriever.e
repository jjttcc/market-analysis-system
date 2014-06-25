indexing
	description:
		"Root class for retrieval of tradable data via an HTTP GET command"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

--!!!!Remember to rename the file to match the new name.
class HTTP_DATA_RETRIEVER inherit

	HTTP_DATA_RETRIEVAL

	ARGUMENTS
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make is
		do
			initialize
			initialize_symbols
			if symbols /= Void and then not symbols.is_empty then
				execute
			end
		rescue
			handle_exception ("main routine")
		end

	initialize_symbols is
		local
			i: INTEGER
		do
			if argument_count >= 1 then
				create {LINKED_LIST [STRING]} symbols.make
				from i := 1 until i = argument_count + 1 loop
					symbols.extend (argument (i))
					i := i + 1
				end
			else
				symbols := symbols_from_file
			end
		end

feature {NONE} -- Implementation

	timing_on: BOOLEAN = True

	symbols: LIST [STRING]
			-- The symbols for which data are to be retrieved

--!!!!!Add exception handling
	execute is
			-- For each symbol, s, in `symbols', if data for s needs
			-- to be retrieved, retrieve them.
		do
			from
				symbols.start
			until
				symbols.exhausted
			loop
				parameters.set_symbol (symbols.item)
				if data_retrieval_needed then
					retrieve_data
				end
				symbols.forth
			end
			report_timing
		end

	data_retrieval_needed: BOOLEAN
			-- Does up-to-date data need to be retrieved for
			-- `parameters.symbol', based on the existence of the
			-- associated data cache file, the configuration settings,
			-- and the current date?
		do
			--@@NOTE: This algorithm is for EOD data.  If the ability to
			--handle intraday data is added, a separate algorithm will
			--be needed for that.
			Result := not output_file_exists
			if not Result then
				check_if_data_is_out_of_date
				Result := data_out_of_date
			end
		end

end
