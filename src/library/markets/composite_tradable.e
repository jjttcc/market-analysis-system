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
			operator: RESULT_COMMAND [REAL]
			variable: NUMERIC_VALUE_COMMAND
		do
			operator := operator_for_current_component
			variable := variable_for_current_component
			create current_tuple.make
			-- Iterate over each field extractor - open, high, ...
			from
				field_extractors.start
				field_setters.start
			until
				field_extractors.exhausted
			loop
				-- For the current field extractor, extract, operate on,
				-- and "accumulate" the corresponding field the current
				-- tuple of each element of `components'.
				from
					components.start
				until
					components.exhausted
				loop
					calculate_field (field_extractors.item, operator, variable)
					components.forth
				end
				field_setters.item.call ([current_tuple,
					field_extractors.item.value])
				field_extractors.forth
				field_setters.forth
			end
		ensure
			current_tuple_exists: current_tuple /= Void
		end

	prepare_for_processing is
			-- Perform any needed initialization before making `data'.
		do
			if open = Void then
				create open
				create high
				create low
				create close
				create volume
			end
		end

feature {NONE} -- Implementation - Hook routines

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

	calculate_field (field: BASIC_NUMERIC_COMMAND;
		operator: RESULT_COMMAND [REAL]; variable: NUMERIC_VALUE_COMMAND) is
			-- Calculate the value for `field' with `components.item'.
			-- The result will be stored in `accumulation_operator.value'.
		do
			-- Extract the current field:
			field.execute (components.item.data.item)
			variable.set_value (field.value)
			operator.execute (components.item.data.item)
			-- The following instruction allows the `accumulation_operator'
			-- to take the result, operator.value, from the above
			-- calculation and "accumulate" it.  The result of this
			-- accumulation can then be obtained from
			-- accumulation_operator.value.
			accumulation_variable.set_value (operator.value)
			accumulation_operator.execute (components.item.data.item)
		end

	operator_for_current_component: RESULT_COMMAND [REAL] is
			-- Operator for `component.item'
			-- The left operand, `operand1', of this operator will be
			-- set to one of the utility attributes - open, high, or etc. -
			-- to extract the field currently being operated on.  The
			-- right operand, `operand2', is expected to perform the
			-- appropriate calculation on the current field value
			-- extracted via `operand1'.
		deferred
		end

	variable_for_current_component: NUMERIC_VALUE_COMMAND is
			-- The "variable" to be operated on for `component.item'
		deferred
		ensure
			belongs_to_current_operator_or_current_volume_operator:
				operator_for_current_component.descendants.has (Result) or
				operator_for_current_component_volume.descendants.has (Result)
		end

	operator_for_current_component_volume: RESULT_COMMAND [REAL] is
			-- Operator for the volume value for `component.item'
		deferred
		end

feature {NONE} -- Implementation - Utility attributes

	current_tuple: BASIC_VOLUME_TUPLE
			-- Current value of the current tuple - used for calculation
			-- of `data'
			--@@@Check on whether BASIC_VOLUME_TUPLE is the right type.

	open: OPENING_PRICE
			-- Operator used to extract the open price of the input
			-- tuple currently being processed

	high: HIGH_PRICE
			-- Operator used to extract the high price of the input
			-- tuple currently being processed

	low: LOW_PRICE
			-- Operator used to extract the low price of the input
			-- tuple currently being processed

	close: CLOSING_PRICE
			-- Operator used to extract the close price of the input
			-- tuple currently being processed

	volume: VOLUME
			-- Operator used to extract the volume of the input
			-- tuple currently being processed

	field_extractors: LINKED_LIST [BASIC_NUMERIC_COMMAND] is
		once
			create Result.make
			Result.extend (open)
			Result.extend (high)
			Result.extend (low)
			Result.extend (close)
			Result.extend (volume)
		end

	field_setters: LINKED_LIST [PROCEDURE [ANY, TUPLE [
			BASIC_VOLUME_TUPLE, REAL]]] is
		once
			create Result.make
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_open (?))
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_high (?))
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_low (?))
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_close (?))
			Result.extend (agent {BASIC_VOLUME_TUPLE}.set_volume (?))
		end

feature {NONE} -- Implementation - Utility routines

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
