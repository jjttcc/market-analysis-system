indexing
	description:
		"A linear command that processes n market tuples"
	note:
		"By default, the execute routine will process the last n trading %
		%periods from the current period (that is, from the current %
		%item - n + 1 to the current item).  Descendants may override this %
		%behavior"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_LINEAR_COMMAND inherit

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		export {NONE}
			nrc_make_unused
		redefine
			initialize
		select
			initialize
		end

	LINEAR_COMMAND
		rename
			initialize as lc_initialize
		redefine
			forth, action, start, exhausted, invariant_value, target
		end

feature -- Initialization

	make (t: CHAIN [MARKET_TUPLE]; i: like n) is
		require
			t_not_void: t /= Void
			i_gt_0: i > 0
		do
			set_target (t)
			set_n (i)
		ensure
			set: target = t and n = i
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		local
			l: LINEAR_ANALYZER
		do
			Precursor (arg)
			l ?= arg
			check
				arg_conforms_to_linear_analyzer: l /= Void
			end
			lc_initialize (l)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			do_all
		end

feature -- Status report

	arg_mandatory: BOOLEAN is
		once
			Result := false
		end

	target_cursor_not_affected: BOOLEAN is
		once
			Result := true
		end

feature {NONE} -- Implementation

	forth is
		do
			index_offset := index_offset - 1
		end

	start is
		do
			index_offset := n - 1
			start_init
		end

	action is
		do
			sub_action (target.index - index_offset)
		end

	exhausted: BOOLEAN is
		do
			Result := index_offset = -1
		end

	invariant_value: BOOLEAN is
		do
			Result := not exhausted implies
						target.valid_index (target.index - index_offset)
		end

feature {NONE} -- Implementation

	index_offset: INTEGER
			-- Offset from current cursor/index - used for iteration

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
