indexing
	description: "Value setter that sets the volume of a tuple";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_SETTER inherit

	INTEGER_SETTER

creation

	make

feature

	make is
		do
			multiplier := 1
		ensure
			multiplier = 1
		end

feature -- Access

	multiplier: INTEGER
			-- Value to multiply input value by to obtain the true
			-- value (e.g., 1000 when volume is thousands)

feature {FACTORY}

	set_multiplier (i: INTEGER) is
		require
			i > 0
		do
			multiplier := i
		ensure
			mult_set: multiplier = i
		end

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: VOLUME_TUPLE) is
		do
			if stream.last_integer < 0 then
				handle_input_error ("Numeric input value is < 0: ",
									stream.last_integer.out)
				-- conform to the precondition:
				tuple.set_volume (0)
			else
				tuple.set_volume (stream.last_integer * multiplier)
			end
		ensure then
			volume_set_to_last_integer_times_multiplier_if_valid:
				stream.last_integer >= 0 implies
					stream.last_integer = tuple.volume * multiplier
			error_if_last_integer_lt_0:
				stream.last_integer < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies tuple.volume = 0
		end

invariant

	multiplier_gt_0: multiplier > 0

end -- class VOLUME_SETTER
