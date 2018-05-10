note
	description: "Unary operators that use their operand to process the %
		%current item of a linear structure of tradable tuples"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class UNARY_LINEAR_OPERATOR inherit

	LINEAR_COMMAND
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [DOUBLE, DOUBLE]
		rename
			operate as operate_unused, initialize as uo_initialize
		undefine
			execute
		redefine
			arg_mandatory
		end

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operand)
		require
			not_void: tgt /= Void and op /= Void
		do
			set (tgt)
			operand := op
			operand.initialize_from_parent(Current)
		ensure
			set: target = tgt and operand = op
			parent_set: operand.parent = Current
		end

	initialize (arg: LINEAR_ANALYZER)
		do
			Precursor {LINEAR_COMMAND} (arg)
			uo_initialize (arg)
		end

feature -- Basic operations

	execute (arg: ANY)
		local
			old_i: INTEGER
		do
			old_i := target.index
			operand.execute (target.item)
			value := operand.value
			if old_i /= target.index then
				target.go_i_th (old_i)
			end
		ensure then
			target_cursor_constraint: target_cursor_not_affected implies
				old target.index = target.index
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

	target_cursor_not_affected: BOOLEAN
		note
			once_status: global
		once
			Result := True
		end

end -- class UNARY_LINEAR_OPERATOR
