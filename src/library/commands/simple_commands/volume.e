indexing
	description:
		"A basic numeric command that produces the volume for the current %
		%trading period."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
