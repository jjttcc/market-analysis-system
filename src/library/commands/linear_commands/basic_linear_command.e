indexing
	description:
		"A command that retrieves the value of the current item of %
		%a linear structure of market tuples"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND

creation

	make

feature -- Initialization

	make (tgt: like target) is
		require
			not_void: tgt /= Void
		do
			target := tgt
		ensure
			target = tgt
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			value := target.item.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is true

end -- class BASIC_LINEAR_COMMAND
