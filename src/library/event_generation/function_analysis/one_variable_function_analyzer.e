indexing
	description:
		"Market analyzer that analyzes one market function"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_FUNCTION_ANALYZER inherit

	FUNCTION_ANALYZER

	LINEAR_ANALYZER
		redefine
			start, action
		end

creation

	make

feature -- Initialization

	make (in: like input; op: like operator; event_type_name: STRING;
			per_type: TIME_PERIOD_TYPE) is
		require
			not_void: in /= Void and op /= Void and event_type_name /= Void and
						per_type /= Void
		do
			set_input (in)
			!!start_date_time.make_now
			debug -- !!!Temporary - for testing
				!!start_date_time.make (1997, 10, 1, 0, 0, 0)
			end
			operator := op
			-- EVENT_TYPE instances have a one-to-one correspondence to
			-- FUNTION_ANALYZER instances.  Thus this is the appropriate
			-- place to create this new EVENT_TYPE instance.
			set_event_type (event_type_name)
			period_type := per_type
		ensure
			set: input = in and operator = op and start_date_time /= Void and
					event_type /= Void and
						event_type.name.is_equal (event_type_name)
			period_type_set: period_type = per_type
			offset_0: offset = 0
			-- start_date_set_to_now: start_date_time is set to current time
		end

feature -- Access

	input: MARKET_FUNCTION

	offset: INTEGER
			-- Offset (used by `start') to set start position.
			-- For example, if operator is binary and operand 1 processes
			-- the current item of target and operand 2 processes the previous
			-- item, the offset would need to be 1 so that after calling start
			-- operand 2 would have a valid cursor position to process.

feature -- Status setting

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Set the innermost function, which contains the basic
			-- data to be analyzed.
		do
			input.set_innermost_input (f)
		end

	set_input (in: like input) is
		require
			in_not_void: in /= Void and in.output /= Void
		do
			input := in
			set_target (input.output)
		ensure
			input_set_to_in: input = in
		end

	set_offset (arg: INTEGER) is
			-- Set offset to `arg'.
		require
			arg_not_void: arg /= Void
		do
			offset := arg
		ensure
			offset_set: offset = arg and offset /= Void
		end

feature -- Basic operations

	execute is
		do
			!LINKED_LIST [MARKET_EVENT]!product.make
			if not input.processed then
				input.process
			end
			if not target.empty then
				do_all
			end
		end

feature {NONE} -- Hook routine implementation

	start is
		local
			i: INTEGER
		do
			from
				target.start
			until
				target.exhausted or
				target.item.date_time >= start_date_time
			loop
				target.forth
			end
			if offset /= 0 then
				from
					i := 0
				until
					i = offset or target.exhausted
				loop
					target.forth
					i := i + 1
				end
			end
		ensure then
			date_not_earlier: not target.exhausted implies
							target.item.date_time >= start_date_time
			offset_constraint:
				not target.exhausted implies target.index >= offset
		end

	action is
		local
			ev_desc: STRING
		do
			operator.execute (target.item)
			if operator.value then
				ev_desc := concatenation (<<"Event for ", period_type.name,
					" trading period with indicator ",
					input.name, " (%N", input.full_description, ")%N",
					", value: ", target.item.value>>)
				generate_event (target.item.date_time,
								"Single-indicator event", ev_desc)
			end
		end

invariant

	operator_not_void: operator /= Void
	input_not_void: input /= Void
	event_type_not_void: event_type /= Void
	date_not_void: start_date_time /= Void
	offset_not_negative: offset >= 0

end -- class ONE_VARIABLE_FUNCTION_ANALYZER
