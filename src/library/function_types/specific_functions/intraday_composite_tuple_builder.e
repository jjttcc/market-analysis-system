indexing
	description: "Abstraction that provides services for building a list %
		%of COMPOSITE_TUPLE instances built from inraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INTRADAY_COMPOSITE_TUPLE_BUILDER inherit

	COMPOSITE_TUPLE_BUILDER
		redefine
			do_process
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Basic operations

	do_process is
			-- Make a list of COMPOSITE_TUPLE
		local
			src_sublist: ARRAYED_LIST [BASIC_MARKET_TUPLE]
			current_date: DATE_TIME
		do
			from
				check
					output_empty: output /= Void and output.is_empty
				end
				-- Ensure postcondition - intraday data always has
				-- missing data:
				missing_data := True
				create src_sublist.make (0)
				source_list.start
				check output.count = 0 end
			until
				source_list.after
			loop
				if
					source_list.isfirst or
					not source_list.item.date_time.date.is_equal (
						source_list.i_th (source_list.index - 1).date_time.date)
				then
					current_date := clone (source_list.item.date_time)
					adjust_intraday_start_time (
						current_date, trading_period_type)
				end
				if source_list.item.date_time < current_date + duration then
					from
						-- Remove all previously inserted items.
						src_sublist.wipe_out
						src_sublist.extend (source_list.item)
						source_list.forth
					invariant
						inner_invariant: src_sublist.last.date_time <
							current_date + duration
						sublist_sorted: -- src_sublist is sorted by date_time
					until
						source_list.after or
							source_list.item.date_time >=
								current_date + duration
					loop
						src_sublist.extend (source_list.item)
						source_list.forth
					end
					tuple_maker.set_tuplelist (src_sublist)
					tuple_maker.execute
					tuple_maker.product.set_date_time (current_date)
					output.extend (tuple_maker.product)
				end
				current_date := current_date + duration
			end
			output.finish_loading
		end

end -- INTRADAY_COMPOSITE_TUPLE_BUILDER
