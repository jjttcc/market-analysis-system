indexing
	description: "Abstraction that provides services for building a list %
	%of COMPOSITE_TUPLE instances"
	detailed_description:
		"This class builds a list of composite tuples from a list of %
		%market tuples, using a duration to determine how many source %
		%tuples to use to create a composite tuple."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_TUPLE_BUILDER inherit

	ONE_VARIABLE_FUNCTION
		rename
			target as source_list, make as ovf_make
		redefine
			do_process, output, source_list, operator_used, input,
			trading_period_type
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in: like input; ctf: COMPOSITE_TUPLE_FACTORY;
			time_period_type: TIME_PERIOD_TYPE; date: DATE_TIME) is
		require
			not_void:
				in /= Void and ctf /= Void and time_period_type /= Void and
				date /= Void
			duration_gt_in_duration:
				time_period_type.duration > in.trading_period_type.duration
		do
			ovf_make (in, Void)
			set_tuple_maker (ctf)
			set_trading_period_type (time_period_type)
			start_date := date
		ensure
			set: tuple_maker = ctf and tuple_maker /= Void and
				trading_period_type = time_period_type and
				trading_period_type /= Void
			input_set: input = in and input /= Void
			start_date_set: start_date = date and start_date /= Void
			duration_gt_in_duration:
				duration > in.trading_period_type.duration
		end

feature -- Access

	output: MARKET_TUPLE_LIST [COMPOSITE_TUPLE]
			-- Resulting list of tuples

	duration: DATE_TIME_DURATION is
			-- Duration of the composite tuples to be created
		do
			Result := trading_period_type.duration
		ensure
			period_type_duration: Result = trading_period_type.duration
		end

	trading_period_type: TIME_PERIOD_TYPE

	source_list: MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]
			-- Tuples used to manufacture output

	tuple_maker: COMPOSITE_TUPLE_FACTORY
			-- Factory used to create tuples

	start_date: DATE_TIME
			-- Date/time that will be assigned to the first compostie tuple

feature -- Status report

	times_correct: BOOLEAN is
			-- Are the date/time values of elements of `output' correct
			-- with respect to each other?
		require
			not output.empty
			-- output is sorted by date/time
		local
			previous: MARKET_TUPLE
		do
			Result := true
			from
				output.start
				previous := output.item
				output.forth
			until
				output.exhausted or not Result
			loop
				Result := (output.item.date_time -
							previous.date_time).duration.is_equal (duration)
				previous := output.item
				output.forth
			end
			if Result then
				from
					output.start
				until
					output.exhausted or not Result
				loop
					Result := output.item.last.date_time <
								output.item.date_time + duration
					output.forth
				end
			end
		ensure
			-- for_all p member_of output [2 .. output.count]
			--   it_holds p.date_time - previous (p).date_time equals duration
			-- for_all p member_of output it_holds
			--   p.last.date_time < p.date_time + duration
		end

	operator_used: BOOLEAN is false

feature -- Status setting

	set_tuple_maker (f: COMPOSITE_TUPLE_FACTORY) is
			-- Set tuple_maker to `f'.
		require
			not_void: f /= Void
		do
			tuple_maker := f
		ensure
			set: tuple_maker = f and f /= Void
		end

	set_trading_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set trading_period_type to `arg'.
		require
			arg /= Void
		do
			trading_period_type := arg
		ensure
			trading_period_type_set: trading_period_type = arg and
				trading_period_type /= Void
		end

	set_start_date (arg: DATE_TIME) is
			-- Set start_date to `arg'.
		require
			arg /= Void
		do
			start_date := arg
		ensure
			start_date_set: start_date = arg and
									start_date /= Void
		end

feature -- Basic operations

	do_process is
			-- Make a list of COMPOSITE_TUPLE
		local
			src_sublist: ARRAYED_LIST [BASIC_MARKET_TUPLE]
			current_date: DATE_TIME
		do
			from
				check
					output_empty: output /= Void and output.empty
				end
				!!src_sublist.make (0)
				source_list.start
				current_date := start_date
				check output.count = 0 end
			invariant
				output.count > 1 implies ((output.last.date_time -
					output.i_th (
					output.count - 1).date_time).duration.is_equal (duration))
			until
				source_list.after
			loop
				from
					-- Remove all previously inserted items.
					src_sublist.wipe_out
					check not source_list.after end
					src_sublist.extend (source_list.item)
					source_list.forth
				invariant
					(src_sublist.last.date_time < current_date + duration)
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
				current_date := current_date + duration
				output.extend (tuple_maker.product)
			end
		ensure then
			output.count > 0 implies times_correct and
				output.first.date_time.is_equal (start_date)
		end

feature {NONE}

	input: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]

invariant

	input_equals_source_list: input = source_list
	process_parameters_set: source_list /= Void and tuple_maker /= Void
	start_date_not_void: start_date /= Void
	input_duration_lt_duration: input.trading_period_type.duration < duration

end -- COMPOSITE_TUPLE_BUILDER
