indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class DATA_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND

	PRINTING
		rename
			output_medium as active_medium
		export
			{NONE} all
		end

	STRING_UTILITIES
		rename
			make as su_make_unused
		export
			{NONE} all
		end

feature -- Access

	market_symbol: STRING
			-- Symbol for the selected market

	trading_period_type: TIME_PERIOD_TYPE
			-- Selected trading period type

	parse_error: BOOLEAN

feature {NONE} -- Utility

	parse_symbol_and_period_type (sindx, ptindx: INTEGER;
				fields: LIST [STRING]) is
			-- Extract the symbol and trading period type and place the
			-- results into `market_symbol' and `trading_period_type'.
		local
			pt_names: ARRAY [STRING]
			pt_name: STRING
			object_comparison: BOOLEAN
		do
			parse_error := false
			pt_names := period_type_names
			object_comparison := pt_names.object_comparison
			pt_names.compare_objects
			market_symbol := fields @ sindx
			pt_name := fields @ ptindx
			if not pt_names.has (pt_name) then
				report_error (Error, <<"Bad period type">>)
				parse_error := true
			else
				trading_period_type := period_types @ pt_name
			end
			if not object_comparison then
				pt_names.compare_references
			end
		end

	set_print_parameters is
			-- Set parameters for printing.
			-- `print_start_date' and `print_end_date' are set according to
			-- the respective settings in `session' for `trading_period';
			-- if there is no corresponding setting, the date will
			-- be set to Void.  Justification is set to off.
		do
			if session.start_dates.has (trading_period_type.name) then
				print_start_date := session.start_dates @
					trading_period_type.name
			else
				print_start_date := Void
			end
			if session.end_dates.has (trading_period_type.name) then
				print_end_date := session.end_dates @
					trading_period_type.name
			else
				print_end_date := Void
			end
		end

end -- class DATA_REQUEST_CMD
