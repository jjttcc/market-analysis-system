indexing
	description:
		"A linear offset command whose offset is a settable attribute"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SETTABLE_OFFSET_COMMAND inherit

	LINEAR_OFFSET_COMMAND

	OPERATOR_COMMAND

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operator) is
		require
			not_void: tgt /= Void and op /= Void
		do
			target := tgt
			operator := op
		ensure
			set: target = tgt and operator = op
		end

feature -- Access

	offset: INTEGER

feature -- Status setting

	set_offset (arg: INTEGER) is
			-- Set offset to `arg'.
		require
			arg /= Void
		do
			offset := arg
		ensure
			offset_set: offset = arg and offset /= Void
		end

feature -- Basic operations

	perform_execution (arg: ANY) is
		do
			operator.execute (target.item)
			value := operator.value
		end

end -- class SETTABLE_OFFSET_COMMAND
