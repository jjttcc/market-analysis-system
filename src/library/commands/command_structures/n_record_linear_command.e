indexing
	description:
		"A linear command that processes n market tuples at a time"
	note:
		"By default, the execute routine will process the last n trading %
		%periods from the current period (that is, from the current %
		%item - n + 1 to the current item).  Descendants may override this %
		%behavior"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class N_RECORD_LINEAR_COMMAND inherit

	INDEXED

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		export {NONE}
			nrc_make_unused
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	LINEAR_COMMAND
		rename
			initialize as lc_initialize
		export {NONE}
			lc_initialize
		undefine
			children
		redefine
			forth, action, start, exhausted, invariant_value, target
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			initialize as uo_initialize
		export {NONE}
			uo_initialize
		undefine
			arg_mandatory, execute
		redefine
			operand
		end

creation {NONE} -- Hidden creation routine to prevent instantiation

	make

feature {NONE} -- Initialization

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

feature -- Access

	index: INTEGER is
			-- The index of the current item being processed - from 1 to `n'
		do
			Result := n - index_offset
		end

	operand: RESULT_COMMAND [REAL]
			-- Operand that determines which field in each tuple to
			-- examine for the highest value


feature {MARKET_FUNCTION} -- Initialization

	initialize (arg: N_RECORD_STRUCTURE) is
		local
			l: LINEAR_ANALYZER
		do
			{N_RECORD_COMMAND} Precursor (arg)
			l ?= arg
			check
				arg_conforms_to_linear_analyzer: l /= Void
			end
			lc_initialize (l)
			uo_initialize (arg)
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
			-- True
		once
			Result := true
		end

feature {NONE} -- Implementation

	forth is
		do
			index_offset := index_offset - 1
		ensure then
			index_incremented: index = old index + 1
		end

	start is
		do
print ("in start - target index: ") print (target.index) print ("%N")
			index_offset := n - 1
			start_init
		end

	action is
		do
print ("in action - current index: ") print (index) print ("%N")
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

invariant

	exhausted_if_large_index: index = n + 1 implies exhausted
	index_constraint: index >= 1 and index <= n + 1

end -- class N_RECORD_LINEAR_COMMAND
