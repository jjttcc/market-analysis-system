note
	description: "Abstraction that provides services for building a list %
	%of COMPOSITE_TUPLE instances"
	detailed_description:
		"This class builds a list of composite tuples from a list of %
		%tradable tuples, using a duration to determine how many source %
		%tuples to use to create a composite tuple."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMPOSITE_TUPLE_BUILDER inherit

	ONE_VARIABLE_FUNCTION
		rename
			target as source_list, make as ovf_make
		redefine
			do_process, output, source_list, operator_used, input,
			trading_period_type, make_output, add_operator_result
		end

creation {FACTORY, TRADABLE_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (in: like input; ctf: COMPOSITE_TUPLE_FACTORY;
			time_period_type: TIME_PERIOD_TYPE; date: DATE_TIME)
		require
			not_void:
				in /= Void and ctf /= Void and time_period_type /= Void and
				date /= Void
			in_ptype_not_void: in.trading_period_type /= Void
			duration_gt_in_duration_if_regular:
				not time_period_type.irregular implies
				time_period_type.duration > in.trading_period_type.duration
		do
			set_trading_period_type (time_period_type)
			ovf_make (in, Void)
			set_tuple_maker (ctf)
			start_date := date
			duration := time_period_type.duration
		ensure
			set: tuple_maker = ctf and tuple_maker /= Void and
				trading_period_type = time_period_type and
				trading_period_type /= Void
			input_set: input = in and input /= Void
			start_date_set: start_date = date and start_date /= Void
			duration_set: duration = trading_period_type.duration
		end

feature -- Access

	output: SIMPLE_FUNCTION [COMPOSITE_TUPLE]
			-- Resulting list of tuples

	duration: DATE_TIME_DURATION
			-- Duration of the composite tuples to be created

	trading_period_type: TIME_PERIOD_TYPE

	source_list: TRADABLE_TUPLE_LIST [BASIC_TRADABLE_TUPLE]
			-- Tuples used to manufacture output

	tuple_maker: COMPOSITE_TUPLE_FACTORY
			-- Factory used to create tuples

	start_date: DATE_TIME
			-- Date/time that will be assigned to the first compostie tuple

feature -- Status report

	times_correct: BOOLEAN
			-- Are the date/time values of elements of `output' correct
			-- with respect to each other?
		require
			not output.is_empty
			-- output is sorted by date/time
		local
			previous: TRADABLE_TUPLE
			output_list: TRADABLE_TUPLE_LIST [TRADABLE_TUPLE]
		do
			Result := True
			output_list := output.data
			from
				output_list.start
				previous := output_list.item
				output_list.forth
			until
				output_list.exhausted or not Result
			loop
				Result := missing_data or time_diff_equals_duration (
					output_list.item.date_time, previous.date_time)
				previous := output_list.item
				output_list.forth
			end
			if Result then
				from
					output_list.start
				until
					output_list.exhausted or not Result
				loop
					Result :=
						output.i_th (output_list.index).last.date_time <
								output_list.item.date_time + duration
					output_list.forth
				end
			end
		ensure
			-- for_all p member_of output [2 .. output.count]
			--   it_holds not missing_data implies
			--      p.date_time - previous (p).date_time equals duration
			-- for_all p member_of output it_holds
			--   p.last.date_time < p.date_time + duration
		end

	operator_used: BOOLEAN = False

feature -- Status setting

	set_tuple_maker (f: COMPOSITE_TUPLE_FACTORY)
			-- Set tuple_maker to `f'.
		require
			not_void: f /= Void
		do
			tuple_maker := f
		ensure
			set: tuple_maker = f and f /= Void
		end

	set_trading_period_type (arg: TIME_PERIOD_TYPE)
			-- Set trading_period_type to `arg'.
		require
			arg /= Void
		do
			trading_period_type := arg
		ensure
			trading_period_type_set: trading_period_type = arg and
				trading_period_type /= Void
		end

	set_start_date (arg: DATE_TIME)
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

	do_process
			-- Make a list of COMPOSITE_TUPLE
		local
			src_sublist: ARRAYED_LIST [BASIC_TRADABLE_TUPLE]
			current_date: DATE_TIME
		do
			from
				check
					output_empty: output /= Void and output.is_empty
				end
				missing_data := False
				create src_sublist.make (0)
				source_list.start
				current_date := start_date
				check output.count = 0 end
			invariant
				outer_invariant:
					output.count > 1 and not missing_data implies
						time_diff_equals_duration (output.last.date_time,
							output.i_th (output.count - 1).date_time)
			until
				source_list.after
			loop
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
				else
					missing_data := True
				end
				current_date := current_date + duration
			end
			output.finish_loading
		ensure then
			times_correct: output.count > 0 implies times_correct and
				output.first.date_time.date.is_equal (start_date.date)
		end

feature {NONE}

	input: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]

	make_output
		do
			create output.make (trading_period_type)
		end

	time_diff_equals_duration (d1, d2: DATE_TIME): BOOLEAN
			-- Does the difference between `d1' and `d2' equal `duration'?
		local
			diff: DURATION
			dt_diff: DATE_TIME_DURATION
			max_qrtr_days, min_qrtr_days: INTEGER
		do
			max_qrtr_days := 92; min_qrtr_days := 88
			diff := (d1 - d2).duration
			if trading_period_type.irregular then
				dt_diff ?= diff
				check dt_diff /= Void end
				if
					trading_period_type.name.is_equal (
					trading_period_type.monthly_name)
				then
					Result := dt_diff.day =
						d2.days_in_i_th_month (d2.month, d2.year)
				elseif
					trading_period_type.name.is_equal (
					trading_period_type.yearly_name)
				then
					if d2.is_leap_year (d2.year) then
						Result := dt_diff.day = d2.Days_in_leap_year
					else
						Result := dt_diff.day = d2.Days_in_non_leap_year
					end
				elseif
					trading_period_type.name.is_equal (
					trading_period_type.quarterly_name)
				then
					Result := dt_diff.day <= max_qrtr_days and
						dt_diff.day >= min_qrtr_days
				end
			else
				Result := diff.is_equal (duration)
			end
		end

	missing_data: BOOLEAN
			-- Are there missing records in the input data?

--!!!!Note: This procedure will probably never be called - check!!!!
--!!!!If it is called, logic to set the new tuples attributes is probably
--!!!needed.
	add_operator_result
		local
			t: COMPOSITE_TUPLE
		do
			create t.make
			output.extend (t)
		end

invariant

	input_equals_source_list: input = source_list
	process_parameters_set: source_list /= Void and tuple_maker /= Void
	start_date_not_void: start_date /= Void
	regular_input_duration_lt_duration:
		not trading_period_type.irregular implies
		input.trading_period_type.duration < duration

end -- COMPOSITE_TUPLE_BUILDER
