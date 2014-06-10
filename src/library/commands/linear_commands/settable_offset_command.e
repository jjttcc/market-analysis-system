note
	description: "Linear offset commands whose offset is a settable attribute"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SETTABLE_OFFSET_COMMAND inherit

	LINEAR_OFFSET_COMMAND
		export {NONE}
			offset
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL, REAL]
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
		ensure
			set: target = tgt and operand = op
		end

	initialize (arg: LINEAR_ANALYZER)
		do
			Precursor {LINEAR_OFFSET_COMMAND} (arg)
			uo_initialize (arg)
		end

feature -- Access

	external_offset: INTEGER
		do
			Result := offset
		ensure then
			offset: Result = offset
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

feature -- Status setting

	set_offset (arg: INTEGER)
			-- Set offset to `arg'.
		do
			offset := arg
		ensure
			offset_set: offset = arg
			external_offset_set: external_offset = arg
		end

feature -- Basic operations

	operate (arg: ANY)
		do
			operand.execute (target.item)
			value := operand.value
		end

feature {NONE} -- Implementation

	offset: INTEGER

end -- class SETTABLE_OFFSET_COMMAND
