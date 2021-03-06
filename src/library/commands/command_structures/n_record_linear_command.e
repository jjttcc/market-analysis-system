note
	description: "Linear commands that process n tradable tuples at a time"
	note1:
		"By default, the execute routine will process the last n trading %
		%periods from the current period (that is, from the current %
		%item - n + 1 to the current item).  Descendants may override this %
		%behavior"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class N_RECORD_LINEAR_COMMAND inherit

	N_RECORD_COMMAND
		rename
			make as nrc_make_unused
		export {NONE}
			nrc_make_unused
		undefine
			children
		redefine
			initialize, set_n
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
			forth, start, exhausted, invariant_value, target, action, index,
			index_is_target_based
		end

	UNARY_OPERATOR [DOUBLE, DOUBLE]
		rename
			initialize as uo_initialize
		export {NONE}
			uo_initialize
		undefine
			arg_mandatory, execute
		redefine
			operand
		end

feature {NONE} -- Initialization

	make (t: LIST [TRADABLE_TUPLE]; i: like n)
		require
			t_not_void: t /= Void
			i_gt_0: i > 0
		do
			set (t)
			set_n (i)
		ensure
			set: target = t and n = i
		end

feature -- Access

	index: INTEGER
			-- The index of the current item being processed - from 1 to `n'
		do
			Result := n - index_offset
		end

	operand: RESULT_COMMAND [DOUBLE]
			-- Operand that determines which field in each tuple to
			-- examine for the highest value

feature -- Status report

	index_is_target_based: BOOLEAN
		do
			Result := False
		end

	index_is_n_based: BOOLEAN
			-- Is `index' the current value in a numeric sequence
			-- based on the value of `n'?
		do
			Result := True
		end

	arg_mandatory: BOOLEAN
		note
			once_status: global
		once
			Result := False
		end

	target_cursor_not_affected: BOOLEAN
			-- True if `operand' does not change the cursor in its
			-- `execute' routine
		note
			once_status: global
		once
			Result := True
		end

feature {TRADABLE_FUNCTION} -- Initialization

	initialize (arg: N_RECORD_STRUCTURE)
		local
			l: LINEAR_ANALYZER
		do
			Precursor {N_RECORD_COMMAND} (arg)
			l ?= arg
			check
				arg_conforms_to_linear_analyzer: l /= Void
			end
			lc_initialize (l)
			uo_initialize (arg)
		end

feature {COMMAND_EDITOR} -- Initialization

	set_n (i: INTEGER)
		do
			Precursor (i)
			index_offset := initial_index_offset
		end

feature -- Basic operations

	execute (arg: ANY)
		do
			do_all
		end

feature {NONE} -- Implementation

	forth
		do
			index_offset := index_offset - 1
		ensure then
			index_incremented: index = old index + 1
		end

	start
		do
			index_offset := n - 1
			start_init
		end

	action
		do
			sub_action (target.index - index_offset)
		end

	exhausted: BOOLEAN
		do
			Result := index_offset = -1
		end

	invariant_value: BOOLEAN
		do
			Result := not exhausted implies
						target.valid_index (target.index - index_offset)
		end

feature {NONE} -- Implementation

	index_offset: INTEGER
			-- Offset from current cursor/index - used for iteration

	target: LIST [TRADABLE_TUPLE]

	initial_index_offset: INTEGER
		require
			n_set: n > 0
		do
			Result := -1
		end

feature {NONE}

	start_init
			-- Extra initialization required by start
			-- Defaults to do nothing.
		do
		end

	sub_action (current_index: INTEGER)
			-- Action taken by descendant class - null by default
		do
		end

invariant

	index_exhausted_relationship: index_is_n_based implies (
		index = n + 1 implies exhausted)
	index_constraint: index_is_n_based implies (
		index >= 1 and index <= n + 1)
	not_both_index_meanings: index_is_target_based xor index_is_n_based

end -- class N_RECORD_LINEAR_COMMAND
