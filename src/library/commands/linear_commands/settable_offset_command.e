indexing
	description:
		"A linear offset command whose offset is a settable attribute"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SETTABLE_OFFSET_COMMAND inherit

	LINEAR_OFFSET_COMMAND
		undefine
			initialize
		end

	UNARY_OPERATOR [REAL]
		redefine
			arg_mandatory
		end

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operand) is
		require
			not_void: tgt /= Void and op /= Void
		do
			target := tgt
			operand := op
		ensure
			set: target = tgt and operand = op
		end

feature -- Access

	offset: INTEGER

feature -- Status report

	arg_mandatory: BOOLEAN is false

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

	operate (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

end -- class SETTABLE_OFFSET_COMMAND
