indexing
	description: "Value setter that sets the volume of a tuple";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class VOLUME_SETTER inherit

	REAL_SETTER

	GENERAL_UTILITIES
		export {NONE}
			all
		end

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

	do_set (stream: INPUT_SEQUENCE; tuple: BASIC_VOLUME_TUPLE) is
		do
			if stream.last_real + epsilon < 0 then
				handle_input_error (concatenation (<<"Volume is < 0: ",
					stream.last_real.out, ", adjusting to 0.">>), Void)
				-- conform to the postondition:
				tuple.set_volume (0)
			else
				tuple.set_volume (stream.last_real * multiplier)
			end
		ensure then
			volume_set_to_last_real_times_multiplier_if_valid:
				stream.last_real >= 0 implies
					stream.last_real - tuple.volume * multiplier < Epsilon
			error_if_last_real_lt_0:
				stream.last_real < 0 implies error_occurred
			error_implies_tuple_set_to_0:
				error_occurred implies tuple.volume = 0
		end

invariant

	multiplier_gt_0: multiplier > 0

end -- class VOLUME_SETTER
