indexing
	description: "Abstraction that provides services for building a list %
	%of COMPOSITE_TUPLE instances"
	detailed_description:
		"This class builds a list of composite tuples from a list of %
		%market tuples, using a duration to determine how many source %
		%tuples to use to create a composite tuple."
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_TUPLE_BUILDER inherit

	ONE_VARIABLE_FUNCTION
		rename
			target as source_list, make as ovf_make
		redefine
			process, output, source_list, operator_used, input
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in: like input; ctf: COMPOSITE_TUPLE_FACTORY;
			dur: DATE_TIME_DURATION) is
		do
			ovf_make (in, Void)
			set_tuple_maker (ctf)
			set_duration (dur)
		end

feature -- Basic operations

	process (start_date: DATE_TIME) is
			-- Make a list of COMPOSITE_TUPLE
		local
			src_sublist: ARRAYED_LIST [BASIC_MARKET_TUPLE]
			current_date: DATE_TIME
		do
			from
				check output /= Void and output.empty end
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
					(src_sublist.last.date_time <
						current_date + duration)
					-- src_sublist is sorted by date_time
				until
					source_list.after or
						source_list.item.date_time >=
							current_date + duration
				loop
					src_sublist.extend (source_list.item)
					source_list.forth
				end
				tuple_maker.execute (src_sublist)
				tuple_maker.product.set_date_time (current_date)
				--!!!When implemented, use the flyweight date_time table.
				current_date := current_date + duration
				output.extend (tuple_maker.product)
			end
		ensure then
			output.count > 0 implies times_correct and
				output.first.date_time.is_equal (start_date)
		end

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
				output.after or not Result
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
					output.after or not Result
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

feature -- Access

	output: MARKET_TUPLE_LIST [COMPOSITE_TUPLE]
			-- Resulting list of tuples

	duration: DATE_TIME_DURATION
			-- Duration of the composite tuples to be created

	source_list: MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]
			-- Tuples used to manufacture output

	tuple_maker: COMPOSITE_TUPLE_FACTORY
			-- Factory used to create tuples

feature -- Element change

	set_tuple_maker (f: COMPOSITE_TUPLE_FACTORY) is
			-- Set tuple_maker to `f'.
		require
			not_void: f /= Void
			ready_to_execute: f.execute_precondition
		do
			tuple_maker := f
		ensure
			set: tuple_maker = f and f /= Void
			ready_to_execute: tuple_maker.execute_precondition
		end

	set_duration (d: DATE_TIME_DURATION) is
		require
			d /= Void
		do
			duration := d
		ensure
			duration_set: duration = d and duration /= Void
		end

feature {NONE}

	input: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]

invariant

	input_equals_source_list: input = source_list
	process_parameters_set: source_list /= Void and tuple_maker /= Void and
		duration /= Void and
						tuple_maker.execute_precondition --!!!??
		--!!!Note: If a MARKET_TUPLE_LIST (the type of source_list) is
		--refined to further support the concept of lists with time
		--period types, such as daily or weekly, including comparison
		--based on the length of the period (e.g., weekly > daily),
		--then it would make sense to extend this predicate to include:
		--source_list.time_period.duration < duration [or something
		--equivalent] - the concept being that it only makes sense to
		--make a composite tuple from a set of tuples whose time period
		--duration is less than that of the time period duration.
		--(For example, make weekly from daily, but daily from weekly
		--of weekly from weekly doesn't make sense.)

end -- COMPOSITE_TUPLE_BUILDER
