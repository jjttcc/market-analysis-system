note
	description: "A tradable market entity, such as a stock or commodity";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class TRADABLE [G->BASIC_MARKET_TUPLE] inherit

	SIMPLE_FUNCTION [G]
		rename
			make as sf_make, name as function_name,
			set_name as set_function_name, set_trading_period_type as
			sf_set_trading_period_type
		export {NONE}
			sf_make
		redefine
			sf_set_trading_period_type, finish_loading
		end

	MATH_CONSTANTS
		export {NONE}
			all
		undefine
			is_equal, copy, out
		end

	TRADABLE_FACILITIES
		undefine
			is_equal, copy, out
		end

	GLOBAL_SERVICES
		rename
			period_types as gs_period_types
		export {NONE}
			all
		undefine
			is_equal, copy, out
		end

feature -- Access

	symbol: STRING
			-- The tradable's market symbol - example: IBM
			-- Defaults to name.
		do
			Result := name
		end

	name: STRING
			-- The identifying name of the tradable
		deferred
		end

	indicators: LIST [MARKET_FUNCTION]
			-- Technical indicators that will process the data from
			-- `tuple_list' (`target_period_type'.name)

	indicator_groups: HASH_TABLE [LIST [MARKET_FUNCTION], STRING]
			-- Groupings of `indicators'
			-- Each group has a unique name

	indicator_group_names: ARRAY [STRING]
			-- The name (key) of each group in `indicator_groups'
		do
			Result := indicator_groups.current_keys
		end

	tuple_list (period_type: STRING): SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]
			-- List associated with `period_type' whose tuples are
			-- made from the base data
		require
			not_void: period_type /= Void
			period_type_valid: period_types.has (period_type)
			loaded: loaded
		do
			Result := tuple_lists @ period_type
			-- If the list has not been created and there is enough
			-- data, create/process the list of tuples.
			if Result = Void then
				if period_type.is_equal (trading_period_type.name) then
					-- No processing needed - just assign to base data.
					Result := Current
				else
					Result := process_composite_list (
						period_types @ period_type)
				end
				tuple_lists.force (Result, period_type)
			end
		ensure
			Result = tuple_lists @ period_type
		end

	target_period_type: TIME_PERIOD_TYPE
			-- Type of data (daily, weekly, etc.) specifying which
			-- `tuple_list' will be processed by `indicators'.

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
			-- Valid period types for this tradable
		require
			loaded: loaded
		local
			types: LIST [TIME_PERIOD_TYPE]
		do
			if cached_period_types = Void then
				create cached_period_types.make (0)
				if trading_period_type.intraday then
					types := intraday_period_types.linear_representation
					from
						types.start
					until
						types.exhausted
					loop
						if
							types.item.duration >= trading_period_type.duration
						then
							cached_period_types.put (types.item,
								types.item.name)
						end
						types.forth
					end
				else
					cached_period_types := non_intraday_period_types
				end
			end
			Result := cached_period_types
		end

feature -- Status report

	indicators_processed: BOOLEAN
			-- Have all elements of indicators been processed?
		do
			from
				Result := True
				indicators.start
			until
				not Result or indicators.exhausted
			loop
				Result := indicators.item.processed
				indicators.forth
			end
		end

	has_open_interest: BOOLEAN
			-- Does the data returned by `data' and `tuple_list' contain
			-- an open-interest field?
		deferred
		end

	valid_period_type (t: TIME_PERIOD_TYPE): BOOLEAN
			-- Is `t' a valid period type for this tradable?
		do
			Result := period_types.has (t.name)
		ensure
			valid_if_in_period_types: Result = period_types.has (t.name)
		end

	valid_indicator (f: MARKET_FUNCTION): BOOLEAN
			-- Is `f' a valid indicator for this tradable type?
		do
			Result := True
		end

feature -- Status setting

	set_target_period_type (arg: TIME_PERIOD_TYPE)
			-- Set target_period_type to `arg' and update indicators so
			-- that their inner input value is set to tuple_list (arg.name).
		require
			arg_not_void: arg /= Void
			arg_valid: valid_period_type (arg)
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

	flush_indicators
			-- Flush the contents of `indicators' - needed when the
			-- indicators are shared with another tradable object.
		do
			set_target_period_type (target_period_type)
		end

feature {FACTORY, MARKET_FUNCTION_EDITOR} -- Status setting

	set_trading_period_type (arg: TIME_PERIOD_TYPE)
		require
			daily_if_not_intraday: not arg.intraday implies
				arg.name.is_equal (arg.daily_name)
		do
			trading_period_type := arg
			target_period_type := trading_period_type
		ensure then
			target_type_set_to_tp: target_period_type = trading_period_type
			tpt_set: trading_period_type = arg
		end

	finish_loading
		do
			Precursor
			--@@@Note: With auto-refresh the following command will cause
			--all of the composite data sets to be recalculated.  It would
			--be more efficient to process just the newly arrived data and
			--only the least number of existing composite records needed for
			--the result to be correct (i.e., possible optimization).
			tuple_lists.clear_all
			initialize_tuple_lists
		end

feature -- Element change

	add_indicator (f: MARKET_FUNCTION)
			-- Add `f' to `indicators' and set its inner input value
			-- to tuple_list (target_period_type.name).
		require
			valid: valid_indicator (f)
			not_there: not indicators.has (f)
			period_type_set: target_period_type /= Void
			loaded: loaded
		do
			indicators.extend (f)
			f.set_innermost_input (tuple_list (target_period_type.name))
		ensure
			f_target_added: indicators.has (f)
			one_more: indicators.count = old indicators.count + 1
		end

feature -- Removal

	remove_indicator (f: MARKET_FUNCTION)
			-- Remove `f' from `indicators'.
		do
			indicators.prune (f)
		ensure
			removed: not indicators.has (f)
		end

feature -- Basic operations

	process_indicators
			-- Ensure that all elements of `indicators' have been processed.
		require
			loaded: loaded
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

	tradable_initialize
			-- Establish the class invariant.
		do
			create {LINKED_LIST [MARKET_FUNCTION]} indicators.make
			create indicator_groups.make (0)
			create tuple_lists.make (0)
			sf_make (Void)
		ensure
			containers_not_void:
				indicators /= Void and indicator_groups /= Void and
					tuple_lists /= Void
		end

	initialize_tuple_lists
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
			table_exists: tuple_lists /= Void
			table_empty: tuple_lists.is_empty
		local
			types: LINEAR [TIME_PERIOD_TYPE]
		do
			from
				types := period_types.linear_representation
				types.start
			until
				types.exhausted
			loop
				tuple_lists.extend (Void, types.item.name)
				types.forth
			end
		ensure
			all_void: tuple_lists.occurrences (Void) =
						tuple_lists.count
		end

feature {NONE}

	tuple_lists: HASH_TABLE [SIMPLE_FUNCTION [BASIC_MARKET_TUPLE], STRING]
			-- Lists whose tuples are made from the base data (e.g., weekly,
			-- monthy, if base is daily)

	cached_period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING]

feature {NONE}

	process_composite_list (type: TIME_PERIOD_TYPE):
				SIMPLE_FUNCTION [COMPOSITE_TUPLE]
			-- Create a list of composite tuples from the base data.
		local
			ctf: COMPOSITE_TUPLE_FACTORY
			ctbuilder: COMPOSITE_TUPLE_BUILDER
			start_date_time: DATE_TIME
		do
			ctf := make_ctf
			if not is_empty then
				start_date_time := clone (first.date_time)
				adjust_start_time (start_date_time, type)
			else
				create start_date_time.make_now
			end
			if type.intraday then
				create {INTRADAY_COMPOSITE_TUPLE_BUILDER} ctbuilder.make (
					Current, ctf, type, start_date_time)
			else
				create ctbuilder.make (Current, ctf, type, start_date_time)
			end
			ctbuilder.process
			Result := ctbuilder.output
		end

feature {NONE} -- Hook methods

	make_ctf: COMPOSITE_TUPLE_FACTORY
			-- Create the appropriate type of tuple factory - intended
			-- to be redefined in descendants - for example, to create
			-- a COMPOSITE_VOLUME_TUPLE_FACTORY
-- !!!! indexing once_status: global??!!! [probaly not, but check]
		once
			create Result
		end

feature {NONE} -- Inapplicable

	sf_set_trading_period_type (arg: TIME_PERIOD_TYPE)
		do
			check
				TRADABLE_sf_set_trading_period_type_not_called: False
				-- That is, this routine should never be called
			end
		end

invariant

	containers_not_void:
		indicators /= Void and indicator_groups /= Void and tuple_lists /= Void
	target_type_valid: loaded implies target_period_type /= Void and
		valid_period_type (target_period_type)
	trading_period_daily_if_not_intraday:
		loaded and then not trading_period_type.intraday implies
			trading_period_type.name.is_equal (trading_period_type.daily_name)
	symbol_not_void: symbol /= Void

end -- class TRADABLE
