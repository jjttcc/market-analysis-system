indexing
	description:
		"A linear command that processes the last n trading periods from %
		%the current period"
	note:
		"A subset of the input from the current item - n + 1 to the current %
		%item will be processed."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_LINEAR_COMMAND inherit

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		select
			initialize
		end

	LINEAR_COMMAND
		rename
			make as lc_make_unused, initialize as initialize_unused
		redefine
			forth, action, start, exhausted, invariant_value, target
		end

feature -- Initialization

	make (t: LINEAR [MARKET_TUPLE]; i: like n) is
		require
			t_not_void: t /= Void
			i_gt_0: i > 0
		do
			set_target (t)
			set_n (i)
		ensure
			set: target = t and n = i
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

	target_cursor_not_affected: BOOLEAN is
		once
			Result := true
		end

feature {NONE} -- Implementation

	forth is
		do
			offset := offset - 1
		end

	start is
		do
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
			Result := not exhausted implies
						target.valid_index (target.index - offset)
		end

feature {NONE} -- Implementation

	offset: INTEGER
			-- Offset from current cursor/index

	target: LIST [MARKET_TUPLE]

feature {NONE}

	start_init is
			-- Extra initialization required by start
			-- Defaults to do nothing.
		do
		end

	sub_action (current_index: INTEGER) is
			-- Action taken by descendant class - null by default
		do
		end

end -- class N_RECORD_LINEAR_COMMAND
