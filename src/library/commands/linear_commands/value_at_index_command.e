indexing
	description: "Linear commands that obtain, via an operator, a %
		%value from `target' at a specified index position - The index %
		%value is index_operator.value.floor"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class VALUE_AT_INDEX inherit

	UNARY_LINEAR_OPERATOR
		rename
			make as ulo_make_unused, operand as main_operator
		export
			{NONE} ulo_make_unused
		redefine
			execute
		end

creation

	make

feature -- Initialization

	make (tgt: like target; main_op: like main_operator;
			index_op: like index_operator) is
		require
			not_void: tgt /= Void and main_op /= Void
		do
			set (tgt)
			main_operator := main_op
			index_operator := index_op
		ensure
			set: target = tgt and main_operator = main_op and
				index_operator = index_op
		end

feature -- Access

	index_operator: NUMERIC_VALUE_COMMAND

feature -- Basic operations

	execute (arg: ANY) is
		local
			i, old_i: INTEGER
		do
			old_i := target.index
			i := index_operator.value.floor
			if i >= 1 and i <= target.count then
				target.go_i_th (i)
				check
					target_not_off: not target.off
					target_index_value: target.index = i
				end
			else
				target.go_i_th (1)
			end
			check
				target_not_off: not target.off
			end
			main_operator.execute (target.item)
			value := main_operator.value
			target.go_i_th (old_i) -- Restore cursor.
		end

end
