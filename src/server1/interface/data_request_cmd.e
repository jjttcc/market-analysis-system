indexing
	description: "A command that responds to a client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class DATA_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND

	PRINTING
		rename
			output_record_separator as Message_record_separator,
			output_field_separator as Message_field_separator,
			output_date_field_separator as Message_date_field_separator,
			output_time_field_separator as Message_time_field_separator
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

feature {NONE} -- Hook routine implementations

	do_execute (msg: STRING) is
		local
			fields: LIST [STRING]
		do
			target := msg -- set up for tokenization
			fields := tokens (Message_field_separator)
			if
				fields.count /= expected_field_count and
				additional_field_constraints (fields)
			then
				report_error (Error, <<field_constraint_error>>)
			else
				parse_symbol_and_period_type (symbol_index, period_type_index,
					fields)
				parse_remainder (fields)
				if not parse_error then
					prepare_response (fields)
					create_and_send_response
				end
			end
		end

feature {NONE} -- Hook routines

	expected_field_count: INTEGER is
			-- The expected field count in the argument passed to `do_execute'
		deferred
		end

	additional_field_constraints (fields: LIST [STRING]): BOOLEAN is
			-- Are the additional constraints, if any, for `fields' fulfilled?
		do
			Result := True -- Yes - Redefine if needed.
		end

	field_constraint_error: STRING is
			-- The error message applicable when constraint checking for
			-- the fields extracted from the argument passed to `do_execute'
			-- fails
		once
			Result := "Wrong number of fields." -- Redefine if needed.
		end

	symbol_index: INTEGER is
			-- Field index for the 'symbol' passed to
			-- `parse_symbol_and_period_type'
		deferred
		end

	period_type_index: INTEGER is
			-- Field index for the 'period type' passed to
			-- `parse_symbol_and_period_type'
		deferred
		end

	parse_remainder (fields: LIST [STRING]) is
			-- Parse any remaining fields of `fields' after calling
			-- `parse_symbol_and_period_type'
		require
			fields_exist: fields /= Void
		do
			do_nothing -- Redefine is something needs to be done.
		end

	prepare_response (fields: LIST [STRING]) is
			-- Perform any needed preparation (using `fields', if appropriate
			-- before calling `create_and_send_response'.
		require
			fields_exist: fields /= Void
		do
			do_nothing -- Redefine is something needs to be done.
		end

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Use `t' to obtain the requested data and send them
			-- back to the client.
		require
			t_exists: t /= Void
		do
			do_nothing -- Redefine if action is needed.
		end

feature {NONE} -- Implementation

	create_and_send_response is
			-- Create the requested data and send them to the client.
		require
			tpt_ms_not_void: trading_period_type /= Void and
				market_symbol /= Void
		local
			tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			tradable := cached_tradable (market_symbol, trading_period_type)
			if tradable = Void then
				send_tradable_not_found_response
			else
				send_response_for_tradable (tradable)
			end
		end

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
			parse_error := False
			pt_names := period_type_names
			object_comparison := pt_names.object_comparison
			pt_names.compare_objects
			market_symbol := fields @ sindx
			pt_name := fields @ ptindx
			if not pt_names.has (pt_name) then
				report_error (Error, <<bad_period_type_msg>>)
				parse_error := True
			else
				trading_period_type := period_types @ pt_name
			end
			if not object_comparison then
				pt_names.compare_references
			end
		end

	send_tradable_not_found_response is
			-- Report to the client that the requested tradable was not found.
		require
			tpt_ms_not_void: trading_period_type /= Void and
				market_symbol /= Void
		do
			if server_error then
				report_server_error
			elseif not tradables.symbols.has (market_symbol) then
				report_error (Invalid_symbol, <<symbol_not_found_prefix,
					market_symbol, symbol_not_found_suffix>>)
			else
				report_error (Invalid_period_type, <<invalid_period_type_prefix,
					trading_period_type.name>>)
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

feature {NONE} -- Implementation - string constants

	symbol_not_found_prefix: STRING is "Symbol "

	symbol_not_found_suffix: STRING is " not in database."

	invalid_period_type_prefix: STRING is "Invalid period type: "

	bad_period_type_msg: STRING is "Bad period type"

end -- class DATA_REQUEST_CMD
