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

	make (in: like input; op: like operator; event_type_name: STRING) is
		require
			not_void: in /= Void and op /= Void and event_type_name /= Void
		do
			set_input (in)
			!!start_date_time.make_now
			debug -- Temporary - for testing
				!!start_date_time.make (1997, 10, 1, 0, 0, 0)
			end
			operator := op
			-- EVENT_TYPE instances have a one-to-one correspondence to
			-- FUNTION_ANALYZER instances.  Thus this is the appropriate
			-- place to create this new EVENT_TYPE instance.
			set_event_type (event_type_name)
		ensure
			set: input = in and operator = op and start_date_time /= Void and
					event_type /= Void and
						event_type.name.is_equal (event_type_name)
			start_date_set_to_now: -- start_date_time is set to current time
		end

feature -- Access

	input: MARKET_FUNCTION

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

feature -- Basic operations

	execute is
		do
			!LINKED_LIST [EVENT]!product.make
			if not input.processed then
				input.process
			end
			if not target.empty then
				do_all
			end
		end

feature {NONE} -- Hook routine implementation

	start is
		do
			from
				target.start
			until
				target.exhausted or
				target.item.date_time >= start_date_time
			loop
				target.forth
			end
		ensure then
			date_not_earlier: not target.exhausted implies
							target.item.date_time >= start_date_time
		end

	action is
		local
			ev_desc: STRING
		do
			operator.execute (target.item)
			if operator.value then
				ev_desc := concatenation (<<"Event with indicator ",
					input.name, ", value: ", target.item.value>>)
				generate_event (target.item.date_time,
								"Single-indicator event", ev_desc)
			end
		end

invariant

	operator_not_void: operator /= Void
	input_not_void: input /= Void
	event_type_not_void: event_type /= Void
	date_not_void: start_date_time /= Void

end -- class ONE_VARIABLE_FUNCTION_ANALYZER
