indexing
	description: "Abstraction for a dispenser of tradables from the list %
		%of all available tradables"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_DISPENSER

feature -- Access

	item (period_type: TIME_PERIOD_TYPE): TRADABLE [BASIC_MARKET_TUPLE] is
			-- Tradable for `period_type' at the current cursor position
		require
			type_not_void: period_type /= Void
			cursor_valid: not off
		do
			Result := tradable (current_symbol, period_type)
		ensure
			Result = tradable (current_symbol, period_type)
		end

	index: INTEGER is
			-- index of current cursor position
		deferred
		end

	tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				TRADABLE [BASIC_MARKET_TUPLE] is
			-- The tradable for `period_type' associated with `symbol' -
			-- Void if the tradable for `symbol' is not found or if
			-- `period_type' is not a valid type for `symbol'
		deferred
		ensure
			period_type_valid: Result /= Void implies
				Result.tuple_list_names.has (period_type.name)
		end

	tuple_list (symbol: STRING; period_type: TIME_PERIOD_TYPE):
				SIMPLE_FUNCTION [BASIC_MARKET_TUPLE] is
			-- Tuple list for `period_type' for tradable with `symbol' -
			-- Void if the tradable for `symbol' is not found or if
			-- `period_type' is not a valid type for `symbol'
		deferred
		ensure
			same_period_type: Result /= Void implies
				Result.trading_period_type.is_equal (period_type)
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		deferred
		ensure then
			object_comparison: Result.object_comparison
		end

	period_types (symbol: STRING): ARRAYED_LIST [STRING] is
			-- Names of all period types available for `symbol' -
			-- Void if the tradable for `symbol' is not found
		deferred
		end

	current_symbol: STRING is
			-- Symbol at the current cursor position
		require
			cursor_valid: not off
		deferred
		ensure
			result_valid: Result /= Void
		end


	last_error: STRING
			-- Description of last error

feature -- Status report

	error_occurred: BOOLEAN
			-- Did an error occur during the last operation?

	after: BOOLEAN is
			-- Is there not valid position to the right of the current
			-- cursor position?
		deferred
		end

	empty: BOOLEAN is
			-- Are there not tradables?
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

feature -- Cursor movement

	forth is
			-- Move to next position; if not next position, ensure
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
