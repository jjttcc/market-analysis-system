indexing
	description:
		"A basic numeric command that produces the volume for the current %
		%trading period."
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_COMMAND inherit

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

end -- class VOLUME_COMMAND
