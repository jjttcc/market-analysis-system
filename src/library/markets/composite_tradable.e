indexing
	description: "TRADABLEs made up of other TRADABLEs";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License TBD (Not public - @@@Make sure this is not released.)"

deferred class COMPOSITE_TRADABLE inherit

	--@@Check wether the generic parameter should be VOLUME_TUPLE,
	-- BASIC_MARKET_TUPLE, or something else.
	TRADABLE [VOLUME_TUPLE]
		export {ANY}
			valid_stock_processor
		--@@@May need to refine the exports more.
		redefine
			symbol, make_ctf, short_description, finish_loading,
			valid_indicator
		end

feature {NONE} -- Initialization

	make (accum_op: RESULT_COMMAND [REAL];
		accum_variable: NUMERIC_VALUE_COMMAND) is
		require
			args_exists: accum_op /= Void and accum_variable /= Void
			accum_op_has_accum_var: accum_op.descendants.has (accum_variable)
		do
			accumulation_operator := accum_op
			accumulation_variable := accum_variable
			--@@@Remainder to be determined.
		ensure
			accumulation_op_set: accumulation_operator = accum_op
			accumulation_var_set: accumulation_variable = accum_variable
		end

feature -- Access

	symbol: STRING

	name: STRING is
		do
			--@@@To be determined - probably an attribute
		end

	short_description: STRING is
		do
			--@@@To be determined - probably an attribute
		end

	components: CHAIN [TRADABLE [VOLUME_TUPLE]]
			-- The components, which may include COMPOSITE_TRADABLEs, that
			-- make up Current
			--@@@Check on whether VOLUME_TUPLE is the right type.

	accumulation_operator: RESULT_COMMAND [REAL]
			-- Operator used to "accumulate" the value of the current field
			-- of the current tuple ....!!!
			--@@@There may be a need for each element of `components' to
			--be associated with its own accumulation_operator, but
			--probably, and hopefully, not.
			--@@@Implementation note: The accumulation can probably be done
			--with an appropriate command structure for 
			--`operator_for_current_component'; it seems though that it
			--may be better to keep the accumulation operator to separate
			--"weighting" calculations from "accumulation" calculations.

	accumulation_variable: NUMERIC_VALUE_COMMAND
			-- The "variable" that will be set to the result of applying
			-- the main calculation to the current field of the current
			-- tuple - It is expected to be one of
			-- `accumulation_operator.descendants' so that
			-- `accumulation_operator' can use its value to perform its
			-- "accumulation".  (It will most likely be the "left-most"
			-- operator of a COMMAND_SEQUENCE belonging to
			-- `accumulation_operator'.)

feature -- Status report

	valid_indicator (f: MARKET_FUNCTION): BOOLEAN is
		do
			--@@@To be determined
		ensure then
		end

	has_open_interest: BOOLEAN is
		do
			--@@@To be determined - possibly an attribute
		end

	source_data_is_intraday: BOOLEAN is
			-- Is the source data used to create Current's data intraday data?
		do
			if not components.is_empty then
				Result := components.first.trading_period_type.intraday
			end
		ensure
			no_if_components_empty: components.is_empty implies not Result
		end

feature -- Basic operations

	finish_loading is
		do
			Precursor
			--@@@This may be where the output needs to be calculated, if
			--it has not yet been calculated.
		end

feature {NONE} -- Implementation

	make_ctf: COMPOSITE_TUPLE_FACTORY is
		once
			--@@@Check
			create {COMPOSITE_VOLUME_TUPLE_FACTORY} Result
		end

	make_data is
			-- Use `components' to create Current's `data'.
		local
			first_input_sequence: MARKET_TUPLE_LIST [MARKET_TUPLE]
		do
			arrayed_list_make (0)
			if
				not components.is_empty and then not
				components.first.data.is_empty
			then
				prepare_for_processing
				start_data_cursors
				synchronize_component_cursors
				-- Iterate over the tuples of the data set for each
				-- element of `components', in parallel.
				from
					-- Use the data sequence from the first element of
					-- `components' to control the iteration.
					first_input_sequence := components.first.data
				variant
					index_increases: first_input_sequence.count -
						first_input_sequence.index + 1
				until
					first_input_sequence.exhausted
				loop
					make_current_tuple
					force (current_tuple)
					increment_data_cursors
				end
			end
		end

	make_current_tuple is
			-- Use the tuple at the current cursor position of each element
			-- of `components' to make `current_tuple'.
		local
			main_field_extractor_array: ARRAY [BASIC_NUMERIC_COMMAND]
			extractors: LINEAR [BASIC_NUMERIC_COMMAND]
		do
			create current_tuple.make
			main_field_extractor_array := <<open, high, low, close, volume>>
			extractors := main_field_extractor_array.linear_representation
			extractors.do_all (agent process_components_for_current_tuple)
		ensure
			current_tuple_exists: current_tuple /= Void
		end

	process_components_for_current_tuple (
		field_extractor: BASIC_NUMERIC_COMMAND) is
			-- For each element, c, of `components', use the field obtained
			-- by `field_extractor' of c's current tuple to calculate the
			-- value to be used for the current output tuple.
		local
			post_operator: RESULT_COMMAND [REAL]
			post_variable: NUMERIC_VALUE_COMMAND
		do
			post_operator := post_processing_operator (field_extractor.name)
			post_variable := post_processing_variable (field_extractor.name)
			from
				components.start
			until
				components.exhausted
			loop
				calculate_field (field_extractor)
				components.forth
			end
			post_variable.set_value (accumulation_operator.value)
			post_operator.execute (post_variable.value)
			-- Need a 'postprocessing_operator.execute ...' - e.g., to
			-- divide a "divisor" for a stock index.  Set a
			-- 'postprocessing_variable' to accumulation_operator.value,
			-- then execute the postprocessing_operator, and use its
			-- value for the tuple, below, instead of
			-- accumulation_operator.value.
			--!!!Check if this call is set up right.
			field_setters.item (field_extractor.name).call ([current_tuple,
				accumulation_operator.value])
		end

feature {NONE} -- Implementation - Hook routines

	prepare_for_processing is
			-- Perform any needed initialization before making `data'.
		do
			-- Null routine - redefine if needed.
		end

--!!!Check this and make_current_tuple and add comments/advice about
--using sequence commands
	calculate_field (field_extractor: BASIC_NUMERIC_COMMAND) is
			-- Calculate the value for `field_extractor' with
			-- `components.item'.  The result will be stored in
			-- `accumulation_operator.value'.
		local
			operator: RESULT_COMMAND [REAL]
			variable: NUMERIC_VALUE_COMMAND
		do
			operator := operator_for_current_component (field_extractor.name)
			variable := variable_for_current_component (field_extractor.name)
			-- Extract the current field:
			field_extractor.execute (components.item.data.item)
			variable.set_value (field_extractor.value)
			operator.execute (components.item.data.item)
			-- The following instruction allows the `accumulation_operator'
			-- to take the result, operator.value, from the above
			-- calculation and "accumulate" it.  The result of this
			-- accumulation can then be obtained from
			-- accumulation_operator.value.
			accumulation_variable.set_value (operator.value)
			accumulation_operator.execute (components.item.data.item)
		end

	operator_for_current_component (field_extractor_name: STRING):
		RESULT_COMMAND [REAL] is
			-- Operator for `component.item', possibly specialized with
			-- `field_extractor_name'
		deferred
			-- Specialization on `field_extractor_name' will most likely
			-- only occur for "volume", with the other field extractors
			-- sharing the same operator.
		end

	variable_for_current_component (field_extractor_name: STRING):
		NUMERIC_VALUE_COMMAND is
			-- The "variable" to be operated on for `component.item',
			-- possibly specialized with `field_extractor_name'
		deferred
		ensure
			belongs_to_current_operator_or_current_volume_operator:
				operator_for_current_component (
				field_extractor_name).descendants.has (Result)
		end

	post_processing_operator (field_extractor_name: STRING):
		RESULT_COMMAND [REAL] is
			-- Operator to be used for any needed post-processing for the
			-- current field of the current tuple (possibly specialized
			-- with `field_extractor_name')
		deferred
			-- Specialization on `field_extractor_name' will most likely
			-- only occur for "volume", with the other field extractors
			-- sharing the same operator.
		end

	post_processing_variable (field_extractor_name: STRING):
		NUMERIC_VALUE_COMMAND is
			-- The variable to be operated on for any needed post-processing
			-- for the current field of the current tuple (possibly
			-- specialized with `field_extractor_name')
		deferred
		ensure
			belongs_to_current_operator_or_current_volume_operator:
				operator_for_current_component (
				field_extractor_name).descendants.has (Result)
		end

feature {NONE} -- Implementation - Utility attributes

	current_tuple: BASIC_VOLUME_TUPLE
			-- Current value of the current tuple - used for calculation
			-- of `data'
			--@@@Check on whether BASIC_VOLUME_TUPLE is the right type.

	open: OPENING_PRICE is
			-- Operator used to extract the open price of the input
			-- tuple currently being processed
		once
			create Result
			Result.set_name ("open")
		end

	high: HIGH_PRICE is
			-- Operator used to extract the high price of the input
			-- tuple currently being processed
		once
			create Result
			Result.set_name ("high")
		end

	low: LOW_PRICE is
			-- Operator used to extract the low price of the input
			-- tuple currently being processed
		once
			create Result
			Result.set_name ("low")
		end

	close: CLOSING_PRICE is
			-- Operator used to extract the close price of the input
			-- tuple currently being processed
		once
			create Result
			Result.set_name ("close")
		end

	volume: VOLUME is
			-- Operator used to extract the volume of the input
			-- tuple currently being processed
		once
			create Result
			Result.set_name ("volume")
		end

	field_setters: HASH_TABLE [PROCEDURE [ANY, TUPLE [
		BASIC_VOLUME_TUPLE, REAL]], STRING] is
			-- Tuple field setters, corresponding to the tuple extractors
			-- (open, high, low, etc.) - The key is the name of the
			-- extractor.
		once
			create Result.make (0)
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_open, open.name)
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_high, high.name)
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_low, low.name)
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_close, close.name)
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_volume, volume.name)
		end

feature {NONE} -- Implementation - Utility routines

	synchronize_component_cursors is
			-- For each element, c, of `components', ensure: equal (
			-- c.data.item.date_time, l.data.item.date_time),
			-- where l is the element of `components' such that
			-- l.data.item is the item at l.data's current cursor position
			-- and l.data.item.date_time is the latest date_time compared to
			-- the current item of the `data' feature of the other elements
			-- of `components'.  In other words, move the cursor of the
			-- `data' feature of each element of `components' forward as
			-- little as possible to ensure that `data.item.date_time' is
			-- the same for each element.
			-- If this is not possible, c.data.exhausted will hold for
			-- each element of `components'.
		do
			--@@@To be implemented.
		ensure
			cursor_not_moved_back: components.count > 0 implies
				components.first.data.index >= old components.first.data.index
			date_times_match: components.count > 0 and
				not components.first.data.exhausted implies
				components.for_all (agent tradable_date_matches (?,
				components.first.data.item.date_time))
		end

	tradable_date_matches (t: TRADABLE [VOLUME_TUPLE];
		dt: DATE_TIME): BOOLEAN is
			-- Is the date-time of `t.data.item' the same as `dt'?
		require
			args_exist: t /= Void and dt /= Void
		do
			Result := t.data.item.date_time.is_equal (dt)
		end

	date_times_match (dt1, dt2: DATE_TIME): BOOLEAN is
			-- Do `dt1' and `dt2' specify the same date-time?
		require
			at_least_one_component: not components.is_empty
			args_exist: dt1 /= Void and dt2 /= Void
		do
			if equal (dt1.date, dt2.date) then
				if source_data_is_intraday then
					Result := equal (dt1.time, dt2.time)
				else
					-- No need to compare the time values if the data
					-- is not intraday.
					Result := True
				end
			else
				Result := False
			end
		end

	start_data_cursors is
			-- Position the cursor of the `data' feature of each element of
			-- `components' on the first element.
		local
			last_date_time: DATE_TIME
		do
			from
				components.start
			until
				components.exhausted
			loop
				components.item.data.start
				components.forth
			end
		end

	increment_data_cursors is
			-- Move the cursor of the `data' feature of each element of
			-- `components' forward one element.  If a gap in the data is
			-- found such that `data.item.date_time' of one element of
			-- `components' does not match that of one or more of the
			-- other elements, call synchronize_component_cursors to
			-- ensure that all date-times match.
		local
			last_date_time: DATE_TIME
			gap_found: BOOLEAN
		do
			from
				components.start
			until
				components.exhausted
			loop
				components.item.data.forth
				if
					last_date_time /= Void and then
					not date_times_match (last_date_time,
						components.item.data.item.date_time)
				then
					gap_found := True
				end
				last_date_time := components.item.data.item.date_time
				components.forth
			end
			if gap_found then
				synchronize_component_cursors
			end
		end

invariant

	components_exist: components /= Void
	operators_exists: accumulation_operator /= Void and
		accumulation_variable /= Void
	accumulation_op_has_accumulation_var:
		accumulation_operator.descendants.has (accumulation_variable)

end
