indexing
	description: "Abstraction for a dispenser of tradables from the list %
		%of all available tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class TRADABLE_DISPENSER

feature -- Access

	item (period_type: TIME_PERIOD_TYPE): TRADABLE [BASIC_MARKET_TUPLE] is
			-- Tradable for `period_type' at the current cursor position -
			-- Void if `period_type' is not a valid type for the current
			-- symbol
		require
			type_not_void: period_type /= Void
			cursor_valid: not off
		do
			if valid_period_type (current_symbol, period_type) then
				Result := tradable (current_symbol, period_type)
			end
		ensure
			result_definition: Result = tradable (current_symbol, period_type)
			last_tradable_set: last_tradable = Result
		end

	index: INTEGER is
			-- Index of current cursor position
		deferred
		end

	tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				TRADABLE [BASIC_MARKET_TUPLE] is
			-- The tradable for `period_type' associated with `symbol' -
			-- Void if the tradable for `symbol' is not found or if
			-- `period_type' is not a valid type for `symbol'
		require
			not_empty: not empty
			not_void: symbol /= Void and period_type /= Void
		deferred
		ensure
			period_type_valid: Result /= Void implies
				Result.valid_period_type (period_type)
			last_tradable_set: last_tradable = Result
			not_void_if_valid_and_no_error: not error_occurred and
				valid_period_type (symbol, period_type) implies Result /= Void
			intraday_correspondence: Result /= Void implies
				period_type.intraday = Result.trading_period_type.intraday
			void_if_not_valid: not valid_period_type (symbol, period_type)
				implies Result = Void
		end

	tuple_list (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				SIMPLE_FUNCTION [BASIC_MARKET_TUPLE] is
			-- Tuple list for `period_type' for tradable with `symbol' - Void
			-- if the tradable for `symbol' is not found or if `period_type'
			-- is not a valid type for `symbol'.  `last_tradable' will be set
			-- to `tradable (symbol, period_type)'.
		require
			not_empty: not empty
			not_void: symbol /= Void and period_type /= Void
			period_type_valid: valid_period_type (symbol, period_type)
		local
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			t := tradable (symbol, period_type)
			if t /= Void then
				Result := t.tuple_list (period_type.name)
			end
		ensure
			same_period_type: Result /= Void implies
				Result.trading_period_type.is_equal (period_type)
			not_void_if_no_error: not error_occurred implies Result /= Void
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		deferred
		ensure
			object_comparison: Result.object_comparison
			not_void_if_no_error: not error_occurred implies Result /= Void
		end

	period_types (symbol: STRING): ARRAYED_LIST [STRING] is
			-- Names of all period types available for `symbol', sorted in
			-- ascending order according to period-type duration -
			-- Void if the tradable for `symbol' is not found
		require
			not_empty: not empty
			not_void: symbol /= Void
			symbol_valid: symbols.has (symbol)
		deferred
		ensure
			not_void_if_no_error: not error_occurred implies Result /= Void
		end

	current_symbol: STRING is
			-- Symbol at the current cursor position
		require
			cursor_valid: not off
		deferred
		ensure
			result_valid: Result /= Void
		end

	last_tradable: TRADABLE [BASIC_MARKET_TUPLE]
			-- Last tradable accessed

	last_error: STRING
			-- Description of last error

feature -- Status report

	error_occurred: BOOLEAN
			-- Did an error occur during the last operation?

	after: BOOLEAN is
			-- Is there no valid position to the right of the current
			-- cursor position?
		deferred
		end

	empty: BOOLEAN is
			-- Are there no tradables?
		deferred
		end

	isfirst: BOOLEAN is
			-- Is the cursor at the first position?
		deferred
		end

	exhausted: BOOLEAN is
			-- Has the dispenser been completely explored?
		do
			Result := off
		ensure
			exhausted_when_off: off implies Result
		end

	off: BOOLEAN is
			-- Is there no current item?
		deferred
		end

	valid_period_type (symbol: STRING; t: TIME_PERIOD_TYPE): BOOLEAN is
			-- does `t' for `symbol' match a member of `period_types'?
		require
			not_void: symbol /= Void and t /= Void
			not_empty: not empty
		local
			change_back: BOOLEAN
			ptypes: LIST [STRING]
		do
			if symbols.has (symbol) then
				ptypes := period_types (symbol)
				if ptypes /= Void then
					if not ptypes.object_comparison then
						change_back := true
						ptypes.compare_objects
					end
					Result := ptypes.has (t.name)
					if change_back then
						ptypes.compare_references
					end
				end
			end
		end

feature -- Cursor movement

	forth is
			-- Move to next position; if no next position, ensure
			-- `exhausted'.
		require
			not_after: not after
		deferred
		ensure
			index_incremented: index = old index + 1
		end

	start is
		deferred
		ensure
			not empty = not after
			atfirst: not empty implies isfirst
		end

feature -- Basic operations

	clear_caches is
			-- Clear all caches - that is, force re-reading of tradable data.
		deferred
		end

invariant

	after_constraint: after implies off

	empty_constraint: empty implies off

end -- class TRADABLE_DISPENSER
