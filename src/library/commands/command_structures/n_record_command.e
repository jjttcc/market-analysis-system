indexing
	description:
		"An abstraction for a linear analyzer that functions as a command %
		%and that processes the last n trading periods from the current %
		%period"
	instructions:
		"To use an instance of this class or any of its descendants, %
		%set the input to be processed by calling set_input, set n to the %
		%number of items to be processed, call execute to process it, and %
		%retrieve the result from value.  A subset of the input from the %
		%current item - n + 1 to the current item will be processed."
	date: "$Date$";
	revision: "$Revision$"

deferred class N_RECORD_COMMAND inherit

	NUMERIC_COMMAND
		redefine
			initialize
		end

	N_RECORD_STRUCTURE

	LINEAR_ANALYZER
		redefine
			forth, action, start, exhausted, invariant_value, target
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			do_all
		end

feature -- Status report

	arg_used: BOOLEAN is
		do
			Result := false
		ensure then
			not_used: Result = false
		end

	execute_precondition: BOOLEAN is
		do
			Result := n_set and input_set
		ensure then
			n_input_set: Result = (n_set and input_set)
		end

	execute_postcondition: BOOLEAN is
		do
			Result := true
		ensure then
			is_true: Result = true
		end

feature {FACTORY} --!!!??

feature {NONE} -- Implementation

	forth is
		do
			offset := offset - 1
		end

	start is
		do
			if owner /= Void then
				set_n (owner.n)
			end
			offset := n - 1
			start_init
		end

	action is
		do
			sub_action (target.index - offset)
		end

	exhausted: BOOLEAN is
		do
			Result := offset = -1
		end

	invariant_value: BOOLEAN is
		do
			Result := target /= Void and not exhausted implies
						target.valid_index (target.index - offset)
		end

feature {NONE} -- Implementation

	owner: N_RECORD_STRUCTURE

	offset: INTEGER
			-- Offset from current cursor/index

	target: ARRAYED_LIST [MARKET_TUPLE]

feature {MARKET_FUNCTION}

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
			set_owner (arg)
		ensure then
			n_set_to_argn: n = arg.n
			n_set: n_set
		end

feature {NONE}

	set_owner (o: N_RECORD_STRUCTURE) is
			-- Set owner to o.
		require
			o /= Void
		do
			owner := o
		ensure
			owner = o and owner /= Void
		end

	start_init is
			-- Extra initialization required by start
			-- Defaults to do nothing.
		do
		end

	sub_action (current_index: INTEGER) is
			-- Action taken by descendant class
		deferred
		end

invariant

	loop_inv_valid: target /= Void and then not target.off implies
					invariant_value

end -- class N_RECORD_COMMAND
