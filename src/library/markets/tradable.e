indexing
	description: "A tradable market entity, such as a stock or commodity";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE [G->BASIC_MARKET_TUPLE] inherit

	SIMPLE_FUNCTION [G]
		rename
			output as data, make as sf_make
		export {NONE}
			sf_make
		end

	MATH_CONSTANTS
		export {NONE}
			all
		undefine
			is_equal, copy, setup
		end

	GLOBAL_SERVICES
		export {NONE}
			all
				{ANY}
			period_types
		undefine
			is_equal, copy, setup
		end

feature -- Access

	symbol: STRING is
			-- The tradable's market symbol - example: IBM
			-- Defaults to name.
		do
			Result := name
		end

	indicators: LIST [MARKET_FUNCTION]
			-- Technical indicators that will process the data from
			-- `tuple_list' (`target_period_type'.name)

	indicator_groups: HASH_TABLE [LIST [MARKET_FUNCTION], STRING]
			-- Groupings of `indicators'
			-- Each group has a unique name

	indicator_group_names: ARRAY [STRING] is
			-- The name (key) of each group in `indicator_groups'
		do
			Result := indicator_groups.current_keys
		end

	tuple_list (period_type: STRING): SIMPLE_FUNCTION [BASIC_MARKET_TUPLE] is
			-- List associated with `period_type' whose tuples are
			-- made from the base data
		require
			not_void: period_type /= Void
			duration_valid: (period_types @ period_type).duration >=
				trading_period_type.duration
		do
			Result := tuple_lists @ period_type
			-- If the list has not been created and there is enough
			-- data, create/process the list of tuples.
			if Result = Void then
				if period_type.is_equal (trading_period_type.name) then
					-- No processing needed - just assign to base data.
					Result := Current
				elseif Current.count > 1 then
					Result := process_composite_list (
													period_types @ period_type)
				end
				tuple_lists.replace (Result, period_type)
			end
		ensure
			Result = tuple_lists @ period_type
		end

	tuple_list_names: ARRAY [STRING] is
			-- The period-type name (key) of each `tuple_list' associated
			-- with `Current'
		local
			l: LIST [TIME_PERIOD_TYPE]
			i: INTEGER
		do
			!!Result.make (1, 1)
			Result.compare_objects
			from
				l := period_types.linear_representation
				i := 1
				l.start
			until
				l.exhausted
			loop
				if l.item.duration >= trading_period_type.duration then
					Result.force (l.item.name, i)
					i := i + 1
				end
				l.forth
			end
		ensure
			object_comparison: Result.object_comparison
		end

	target_period_type: TIME_PERIOD_TYPE
			-- Type of data (daily, weekly, etc.) specifying which
			-- `tuple_list' will be processed by `indicators'.

feature -- Access

	yearly_high: PRICE is
			-- Highest closing price for the past year (52-week high)
		require
			not_empty: not data.empty
		do
			if y_high = Void then
				calc_y_high_low
			end
			Result := y_high
		end

	yearly_low: PRICE is
			-- Lowest closing price for the past year (52-week low)
		require
			not_empty: not data.empty
		do
			if y_low = Void then
				calc_y_high_low
			end
			Result := y_low
		end

feature -- Status report

	indicators_processed: BOOLEAN is
			-- Have all elements of indicators been processed?
		do
			from
				Result := true
				indicators.start
			until
				not Result or indicators.exhausted
			loop
				Result := indicators.item.processed
				indicators.forth
			end
		end

feature -- Status setting

	set_target_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set target_period_type to `arg' and update indicators so
			-- that their inner input value is set to tuple_list (arg.name).
		require
			arg_not_void: arg /= Void
			target_type_valid: tuple_list_names.has (arg.name)
		do
			target_period_type := arg
			from
				indicators.start
			until
				indicators.exhausted
			loop
				indicators.item.set_innermost_input (
					tuple_list (target_period_type.name))
				indicators.forth
			end
		ensure
			target_period_type_set: target_period_type = arg
						and target_period_type /= Void
		end

feature -- Element change

	add_indicator (f: MARKET_FUNCTION) is
			-- Add `f' to `indicators' and set its inner input value
			-- to tuple_list (target_period_type.name).
		require
			not_there: not indicators.has (f)
		do
			indicators.extend (f)
			f.set_innermost_input (tuple_list (target_period_type.name))
		ensure
			f_target_added: indicators.has (f)
			one_more: indicators.count = old indicators.count + 1
		end

feature -- Removal

	remove_indicator (f: MARKET_FUNCTION) is
			-- Remove `f' from `indicators'.
		do
			indicators.prune (f)
		ensure
			removed: not indicators.has (f)
		end

feature -- Basic operations

	process_indicators is
			-- Ensure that all elements of `indicators' have been processed.
		do
			from
				indicators.start
			until
				indicators.exhausted
			loop
				if not indicators.item.processed then
					indicators.item.process
				end
				check
					processed: indicators.item.processed
				end
				indicators.forth
			end
		ensure
			processed: indicators_processed
		end

feature {NONE} -- Initialization

	tradable_initialize (type: TIME_PERIOD_TYPE) is
			-- Establish the class invariant.
		do
			!LINKED_LIST [MARKET_FUNCTION]!indicators.make
			!!indicator_groups.make (0)
			!!tuple_lists.make (0)
			sf_make (type)
			initialize_tuple_lists
			target_period_type := trading_period_type
		ensure
			containers_not_void:
				indicators /= Void and indicator_groups /= Void and
					tuple_lists /= Void
			type_set: trading_period_type = type
			target_type_set_to_tp: target_period_type = trading_period_type
		end

	initialize_tuple_lists is
			-- Add elements to tuple_lists.
			-- Since composite tuples can only be made from tuples whose
			-- trading periods are smaller, tuple_lists will
			-- contain a list for each trading period type with a duration
			-- greater than or equal to that of trading_period_type (which
			-- corresponds to the duration of tuples in `data').  The
			-- relation is "greater than or equal to" rather than "greater
			-- than" because `data' is also added to the list.
		require
			type_set: trading_period_type /= Void
			table_empty: tuple_lists.empty
		local
			types: LINEAR [TIME_PERIOD_TYPE]
		do
			from
				types := period_types.linear_representation
				types.start
			until
				types.exhausted
			loop
				if
					types.item.duration >= trading_period_type.duration
				then
					tuple_lists.extend (Void, types.item.name)
				end
				types.forth
			end
		ensure
			all_void: tuple_lists.occurrences (Void) =
						tuple_lists.count
		end

feature {NONE}

	y_high: PRICE
			-- Cached yearly high value

	y_low: PRICE
			-- Cached yearly low value

	tuple_lists: HASH_TABLE [SIMPLE_FUNCTION [BASIC_MARKET_TUPLE], STRING]
			-- Lists whose tuples are made from the base data (e.g., weekly,
			-- monthy, if primary is daily)

feature {NONE}

	calc_y_high_low is
			-- Set y_high to the 52-week high closing price and y_low
			-- to the 52-week low closing price.
		require
			not_empty: not empty
		local
			--calculator: N_BOOLEAN_LINEAR_COMMAND
			greater_than: GT_OPERATOR
			less_than: LT_OPERATOR
			close_extractor: CLOSING_PRICE
			original_cursor: CURSOR
		do
			--NOTE:  It may be a little cleaner to use the HIGHEST_VALUE
			--and LOWEST_VALUE classes; perform a binary search (good for
			--efficiency since this is an ARRAYED_LIST) to find the element
			--whose date is 1 year less than the last element's date; get
			--the n value (for HV and LV) from that element's position; set
			--the cursor to the last element and put HV and LV into action.
			--!!greater_than; !!less_than; !!close_extractor
			if y_high = Void then
				!!y_high; !!y_low
			end
			original_cursor := cursor
			finish -- Set cursor to last position
			-- Initialize calculator to find the highest close value.
			--NOTE:  Not correct yet - needs to either what count needs
			--to be to go back exactly 52 weeks, or create a sublist that
			--contains the past 52-weeks worth of Current's data and
			--pass that sublist and sublist.count to calculator.make.
			--!!calculator.make (Current, count, greater_than, close_extractor)
			check
				islast
				--calculator.target_cursor_not_affected
			end
			--calculator.execute (Void)
			--y_high.set_value (calculator.value)
			-- Re-set calculator to find the lowest close value.
			--calculator.set_boolean_operator (less_than)
			--calculator.set_initial_value (99999999)
			--calculator.execute (Void)
			--y_low.set_value (calculator.value)
			go_to (original_cursor)
		ensure
			not_void: y_high /= Void and y_low /= Void
		end

	process_composite_list (type: TIME_PERIOD_TYPE):
				SIMPLE_FUNCTION [COMPOSITE_TUPLE] is
			-- Create a list of composite tuples from the base data.
		require
			not_empty: count > 1
		local
			ctf: COMPOSITE_TUPLE_FACTORY
			ctbuilder: COMPOSITE_TUPLE_BUILDER
			start_date_time: DATE_TIME
		do
			ctf := make_ctf
			start_date_time := clone (first.date_time)
			adjust_start_time (start_date_time, type)
			if type.irregular then
				--when ready:
				-- !IRREGULAR_COMPOSITE_TUPLE_BUILDER!ctbuilder.make (
				--										Current, ctf, type)
			else
				!!ctbuilder.make (Current, ctf, type, start_date_time)
			end
			ctbuilder.process
			Result := ctbuilder.output
		end

feature {NONE} -- Hook methods

	make_ctf: COMPOSITE_TUPLE_FACTORY is
			-- Create the appropriate type of tuple factory - intended
			-- to be redefined in descendants - for example, to create
			-- a COMPOSITE_VOLUME_TUPLE_FACTORY
		once
			!!Result
		end

invariant

	containers_not_void: indicators /= Void and indicator_groups /= Void and
							tuple_lists /= Void
	target_type_valid: target_period_type /= Void and
		tuple_list_names.has (target_period_type.name)

end -- class TRADABLE
