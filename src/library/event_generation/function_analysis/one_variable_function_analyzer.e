indexing
	description:
		"Market analyzer that analyzes one market function"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ONE_VARIABLE_FUNCTION_ANALYZER inherit

	FUNCTION_ANALYZER

	ONE_VARIABLE_LINEAR_ANALYZER
		redefine
			action
		end

creation

	make

feature -- Initialization

	make (in: like input; op: like operator; ev_type: EVENT_TYPE;
			per_type: TIME_PERIOD_TYPE) is
		require
			not_void: in /= Void and op /= Void and ev_type /= Void and
						per_type /= Void
		do
			set_input (in)
			!!start_date_time.make_now
			operator := op
			-- EVENT_TYPE instances have a one-to-one correspondence to
			-- FUNTION_ANALYZER instances.  Thus this is the appropriate
			-- place to create this new EVENT_TYPE instance.
			event_type := ev_type
			period_type := per_type
		ensure
			set: input = in and operator = op and start_date_time /= Void and
					event_type /= Void and event_type = ev_type
			period_type_set: period_type = per_type
			left_offset_0: left_offset = 0
			-- start_date_set_to_now: start_date_time is set to current time
		end

feature -- Access

	input: MARKET_FUNCTION

	indicators: LIST [MARKET_FUNCTION] is
		do
			!LINKED_LIST [MARKET_FUNCTION]!Result.make
			Result.extend (input)
		end

feature -- Status setting

	set_innermost_function (f: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Set the innermost function, which contains the basic
			-- data to be analyzed.
		do
			input.set_innermost_input (f)
			set_target (input.output)
			-- Operator may need to obtain `target' from Current.
			operator.initialize (Current)
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

	set_left_offset (arg: INTEGER) is
			-- Set left_offset to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			left_offset := arg
		ensure
			offset_set: left_offset = arg and left_offset >= 0
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

	action is
		local
			ev_desc: STRING
		do
			operator.execute (target.item)
			if operator.value then
				ev_desc := concatenation (<<period_type.name,
					" trading period with indicator ", input.name,
					"%Nvalue: ", target.item.value>>)
				generate_event (target.item, ev_desc)
			end
		end

feature {MARKET_FUNCTION_EDITOR}

	wipe_out is
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			if tradable /= Void then
				!STOCK!dummy_tradable.make ("dummy",
											tradable.trading_period_type, Void)
				-- Set innermost input to an empty tradable to force it
				-- to clear its contents.
				input.set_innermost_input (dummy_tradable)
			end
			product := Void
			tradable := Void
		end

feature -- Implementation

	event_name: STRING is "Single-indicator event"

invariant

	operator_not_void: operator /= Void
	input_not_void: input /= Void
	date_not_void: start_date_time /= Void
	offset_not_negative: left_offset >= 0

end -- class ONE_VARIABLE_FUNCTION_ANALYZER
