note
	description: "Abstraction for managing multiple tradable lists"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_LIST_HANDLER inherit

	TRADABLE_DISPENSER

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make (daily_list, intraday_list: TRADABLE_LIST;
			inds: SEQUENCE [MARKET_FUNCTION])
		require
			one_not_void: intraday_list /= Void or daily_list /= Void
			inds_exist: inds /= Void
			counts_equal_if_both_valid: daily_list /= Void and then
				not daily_list.is_empty and then intraday_list /= Void and then
				not intraday_list.is_empty implies
				intraday_list.count = daily_list.count
			consistent_caching: daily_list /= Void and intraday_list /= Void
				implies daily_list.caching_on = intraday_list.caching_on
			-- for_all i member_of 1 .. daily_list.count it_holds
			--    (daily_list.symbols @ i).is_equal (intraday_list.symbols @ i)
		local
			ptypes: expanded PERIOD_TYPE_FACILITIES
		do
			daily_market_list := daily_list
			intraday_market_list := intraday_list
			indicators := inds
			standard_period_types := ptypes.standard_period_types
		ensure
			lists_set: daily_market_list = daily_list and
				intraday_market_list = intraday_list
			indicators_set: indicators = inds
		end

feature -- Access

	index: INTEGER
		do
			if symbol_list /= Void then
				Result := symbol_list.index
			end
		end

	tradable (symbol: STRING; period_type: TIME_PERIOD_TYPE; update: BOOLEAN):
				TRADABLE [BASIC_MARKET_TUPLE]
		local
			l: TRADABLE_LIST
			t: TRADABLE [BASIC_MARKET_TUPLE]
		do
			last_tradable := Void
			reset_error_state
			l := list_for (period_type)
			if l /= Void then
				if l.symbols.has (symbol) then
					--@@With MT version, thread-safe action may be needed
					--here - ensure there is no conflict re. `t'.
					l.search_by_symbol (symbol)
					if not l.fatal_error then
						t := l.item
						if
							t /= Void and then
							t.valid_period_type (period_type)
						then
							check
								t_is_item: t = l.item
							end
							if update then
								-- Ensure `t' contains the latest data.
								l.update_item
							end
							Result := t
							last_tradable := t
						end
					end
					if l.fatal_error then
						error_occurred := True
						last_error := concatenation (<<
							"Error occurred retrieving data for ", symbol>>)
						l.clear_error
					end
				else
					error_occurred := True
					last_error := concatenation (<<
						"Symbol ", symbol, " not found">>)
				end
			end
		end

	symbols: LIST [STRING]
		do
			reset_error_state
			if daily_market_list /= Void then
				Result := daily_market_list.symbols
			elseif intraday_market_list /= Void then
				Result := intraday_market_list.symbols
			end
		ensure then
			correct_count: daily_market_list /= Void implies
				Result.count = daily_market_list.count and
				intraday_market_list /= Void implies
					Result.count = intraday_market_list.count
		end

	period_type_names_for (symbol: STRING): ARRAYED_LIST [STRING]
		local
			t: TRADABLE [BASIC_MARKET_TUPLE]
			target_set: PART_SORTED_SET [TIME_PERIOD_TYPE]
			std_types: LINKED_SET [TIME_PERIOD_TYPE]
			g: expanded GLOBAL_SERVER_FACILITIES
		do
			reset_error_state
			create target_set.make
			create Result.make (0)
			if intraday_market_list /= Void then
				intraday_market_list.search_by_symbol (symbol)
				if not intraday_market_list.fatal_error then
					t := intraday_market_list.item
				end
				if not intraday_market_list.fatal_error then
					target_set.fill (t.period_types.linear_representation)
					if
						not
						g.command_line_options.allow_non_standard_period_types
					then
						create std_types.make
						std_types.compare_objects
						target_set.compare_objects
						std_types.fill (standard_period_types)
						-- Since "non-standard" period types are not allowed,
						-- remove from `target_set' all period types that
						-- do not occur in `standard_period_types'.
						target_set.intersect (std_types)
					end
				else
					error_occurred := True
					last_error := concatenation (<<"Error occurred ",
						"retrieving intraday period types for ", symbol>>)
				end
			end
			if not error_occurred and daily_market_list /= Void then
				daily_market_list.search_by_symbol (symbol)
				if not daily_market_list.fatal_error then
					t := daily_market_list.item
				end
				if not daily_market_list.fatal_error then
					target_set.fill (t.period_types.linear_representation)
				else
					error_occurred := True
					last_error := concatenation (<<"Error occurred ",
						"retrieving non-intraday period types for ", symbol>>)
				end
			end
			from
				target_set.start
			until
				target_set.after
			loop
				Result.extend (target_set.item.name)
				target_set.forth
			end
		end

	current_symbol: STRING
		do
			Result := symbol_list.item
		end

	indicators: SEQUENCE [MARKET_FUNCTION]

feature -- Status report

	after: BOOLEAN
		do
			Result := symbol_list = Void or else symbol_list.after
		end

	is_empty: BOOLEAN
		do
			if daily_market_list /= Void then
				Result := daily_market_list.is_empty
			else
				Result := intraday_market_list.is_empty
			end
		end

	isfirst: BOOLEAN
		do
			Result := symbol_list /= Void and symbol_list.isfirst
		end

	off: BOOLEAN
		do
			Result := symbol_list = Void or else symbol_list.off or else
				is_empty
		end

	caching_on: BOOLEAN
		do
			Result := (daily_market_list = Void or else
				daily_market_list.caching_on) and (intraday_market_list = Void
				or else intraday_market_list.caching_on)
		end

feature -- Cursor movement

	finish
		do
			symbol_list.finish
		end

	forth
		do
			symbol_list.forth
		end

	start
		do
			if symbol_list = Void then
				symbol_list := symbols
			end
			symbol_list.start
		end

feature -- Basic operations

	clear_caches
			-- Clear the cache of all lists.
		do
			if daily_market_list /= Void then
				daily_market_list.clear_cache
			end
			if intraday_market_list /= Void then
				intraday_market_list.clear_cache
			end
			symbol_list := Void
		end

	turn_caching_off
		do
			if daily_market_list /= Void then
				daily_market_list.turn_caching_off
			end
			if intraday_market_list /= Void then
				intraday_market_list.turn_caching_off
			end
		end

	turn_caching_on
		do
			if daily_market_list /= Void then
				daily_market_list.turn_caching_on
			end
			if intraday_market_list /= Void then
				intraday_market_list.turn_caching_on
			end
		end

feature {NONE} -- Implementation

	daily_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is daily

	intraday_market_list: TRADABLE_LIST
			-- Tradables whose base data period-type is intraday

	symbol_list: LIST [STRING]
			-- List of all tradable symbols - used for iteration

	standard_period_types: LINKED_LIST [TIME_PERIOD_TYPE]
			-- All "standard" period types (e.g., excluding 3-minute,
			-- 4-minute, etc. types)

	list_for (period_type: TIME_PERIOD_TYPE): TRADABLE_LIST
			-- The tradable list that holds data for `period_type'
		do
			if period_type.intraday then
				Result := intraday_market_list
			else
				Result := daily_market_list
			end
		end

	both_lists_valid: BOOLEAN
			-- Are both lists non-void and nonempty?
		do
			Result := daily_market_list /= Void and then
				not daily_market_list.is_empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.is_empty
		ensure
			definition: Result = (daily_market_list /= Void and then
				not daily_market_list.is_empty and then
				intraday_market_list /= Void and then
				not intraday_market_list.is_empty)
		end

	reset_error_state
			-- Reset internal error state to no errors.
		do
			error_occurred := False
			if daily_market_list /= Void then
				daily_market_list.clear_error
			end
			if intraday_market_list /= Void then
				intraday_market_list.clear_error
			end
		end

invariant

	both_lists_not_void:
		not (daily_market_list = Void and intraday_market_list = Void)
	counts_equal_if_both_valid: both_lists_valid implies
		daily_market_list.count = intraday_market_list.count
	consistent_caching: daily_market_list /= Void and
		intraday_market_list /= Void implies
		daily_market_list.caching_on = intraday_market_list.caching_on
	standard_period_types_exists: standard_period_types /= Void
	-- for_all i member_of 1 .. daily_market_list.count it_holds
	--    (daily_market_list.symbols @ i).is_equal (
	--       intraday_market_list.symbols @ i)

end -- class TRADABLE_LIST_HANDLER
