indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_SETTER inherit

	VALUE_SETTER

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
			stream.read_integer
			-- Only set the field if it is not flagged as a dummy.
			if not is_dummy then
				if stream.last_integer < 0 then
					!!last_error.make (128)
					last_error.append ("Numeric input value is < 0: ")
					last_error.append (stream.last_integer.out)
					-- conform to the precondition:
					tuple.set_volume (0)
					error_occurred := true
				else
					tuple.set_volume (stream.last_integer * multiplier)
				end
			end
		ensure then
			volume_set_to_last_integer_times_multiplier:
				stream.last_integer = tuple.volume*multiplier
		end

invariant

	multiplier_gt_0: multiplier > 0

end -- class VOLUME_SETTER
