indexing
	description: "A tradable market entity, such as a stock or commodity";
	development_note: "!!!NOTE:  Make sure h_high and y_low are initialized %
		%to 0.  Also, check on viability of calc_y_high_low.!!!"
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE [G->BASIC_MARKET_TUPLE] inherit

	SIMPLE_FUNCTION [G]

feature -- Access

	indicators: LIST [MARKET_FUNCTION]
			-- Technical indicators associated with this tradable

	indicator_groups: HASH_TABLE [LIST [MARKET_FUNCTION], STRING]
			-- Groupings of the above technical indicators
			-- Each group has a unique name

	indicator_group_names: ARRAY [STRING] is
			-- The name (key) of each group in indicator_groups
		do
			Result := indicator_groups.current_keys
		end

	composite_tuple_lists: HASH_TABLE [LIST [MARKET_TUPLE], STRING]
			-- Lists whose tuples are made from those of the primary
			-- list (e.g., weekly, monthy, if primary is daily)

	composite_list_names: ARRAY [STRING] is
			-- The name (key) of each list in composite_tuple_lists
		do
			Result := composite_tuple_lists.current_keys
		end

feature -- Access

	principal_data: LIST [MARKET_TUPLE] is
			-- The principal data associated with the main trading period
		do
			Result := Current
		end

	yearly_high: PRICE is
			-- Highest closing price for the past year (52-week high)
		require
			data_not_empty: not principal_data.empty
		do
			if y_high = Void then
				calc_y_high_low
			end
			Result := y_high
		end

	yearly_low: PRICE is
			-- Lowest closing price for the past year (52-week low)
		require
			not_empty: not principal_data.empty
		do
			if y_low = Void then
				calc_y_high_low
			end
			Result := y_low
		end

feature {NONE}

	y_high: PRICE
			-- Cached yearly high value

	y_low: PRICE
			-- Cached yearly low value

feature {NONE}

	calc_y_high_low is
		require
			not_empty: not empty
		local
			calculator: N_BOOLEAN_LINEAR_COMMAND
			greater_than: GT_OPERATOR [REAL]
			less_than: LT_OPERATOR [REAL]
			close_extractor: CLOSING_PRICE
			original_cursor: CURSOR
		do
			!!greater_than; !!less_than; !!close_extractor
			!!y_high; !!y_low
			original_cursor := cursor
			finish -- Set cursor to last position
			-- Initialize calculator to find the highest close value.
			--!!!NOTE:  Not correct yet - needs to either what count needs
			--!!!to be to go back exactly 52 weeks, or create a sublist that
			--!!!contains the past 52-weeks worth of Current's data and
			--!!!pass that sublist and sublist.count to calculator.make.
			!!calculator.make (Current, count, greater_than, close_extractor)
			check
				islast
				calculator.target_cursor_not_affected
			end
			calculator.execute (Void)
			y_high.set_value (calculator.value)
			-- Re-set calculator to find the lowest close value.
			calculator.set_boolean_operator (less_than)
			calculator.set_initial_value (99999999)
			calculator.execute (Void)
			y_low.set_value (calculator.value)
			go_to (original_cursor)
		end

end -- class TRADABLE
