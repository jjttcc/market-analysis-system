indexing
	description: "Sum of n sequential elements";
	note: "If target.count < n, all of target's elements will be summed and %
		%target.exhausted will be true."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class LINEAR_SUM inherit

	N_RECORD_LINEAR_COMMAND
		rename
			index_offset as internal_index, make as nrlc_make_unused
		redefine
			execute, target_cursor_not_affected, exhausted, action,
			forth, invariant_value, start, index
		end

creation

	make

feature {FACTORY} -- Initialization

	make (t: like target; op: like operand; i: like n) is
		require
			args_not_void: t /= Void and op /= Void
			i_gt_0: i > 0
		do
			set_target (t)
			set_operand (op)
			set_n (i)
		ensure
			op_n_set: operand = op and n = i
			target_set: target = t
		end

feature -- Access

	index: INTEGER is
		do
			Result := internal_index + 1
		end

feature -- Basic operations

	execute (arg: ANY) is
			-- Operate on the next n elements of the input, beginning
			-- at the current cursor position.
		do
			internal_index := 0
			value := 0
print ("ls.exe - index: ") print (index) print("%N")
print ("ls.exe - target.index: ") print (target.index) print("%N")
			if target.count >= n then
				until_continue
			else
				low_count_action
			end
		ensure then
			new_index: target.count >= n implies
				target.index = old target.index + n
			-- target.count >= n implies 
			--   value = sum (target[old target.index .. old target.index+n-1])
			int_index_eq_n: target.count >= n implies internal_index = n
			state_if_count_lt_n: target.count < n implies
				internal_index = target.index - 1 and target.exhausted
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is false
			-- False

feature {NONE}

	invariant_value: BOOLEAN is
		do
			Result := 0 <= internal_index and internal_index <= n
		end

feature {NONE}

	forth is
		do
			internal_index := internal_index + 1
			target.forth
		end

	action is
		do
print ("ls.action - index: ") print (index) print("%N")
print ("ls.action - target.index: ") print (target.index) print("%N")
			operand.execute (target.item)
			value := value + operand.value
		ensure then
			-- value = sum (
			-- target [original_index .. original_index + internal_index - 1])
			--   where original_index is the value of target.index when
			--   execute is called.
		end

	exhausted: BOOLEAN is
		do
			Result := internal_index = n
		end

	start is
			-- Should never be called.
		do
			check false end
		end

	low_count_action is
			-- Action to take if target.count < n
		require
			count_lt_n: target.count < n
		do
			from
			until
				target.exhausted
			loop
				action
				forth
			end
		end

invariant

	operator_not_void: operand /= Void

end -- class LINEAR_SUM
