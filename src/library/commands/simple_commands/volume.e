indexing
	description:
		"A basic numeric command that produces the volume for the current %
		%trading period."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VOLUME inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute
		end

feature -- Basic operations

	execute (arg: VOLUME_TUPLE) is
			-- Can be redefined by ancestors.
		do
			value := arg.volume
		ensure then
			value = arg.volume
		end

end -- class VOLUME
