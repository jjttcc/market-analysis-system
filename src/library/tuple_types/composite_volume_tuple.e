note
	description: "Composite tuple with volume";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMPOSITE_VOLUME_TUPLE inherit

	COMPOSITE_TUPLE

	VOLUME_TUPLE
		undefine
			make, end_date
		end

creation

	make

feature -- Access

	volume: DOUBLE

feature {COMPOSITE_TUPLE_FACTORY}

	set_volume (arg: DOUBLE)
		do
			volume := arg
		ensure
			volume_set: volume = arg
		end

feature {NONE}

	adjust_volume_for_split (r: DOUBLE)
		do
			volume := (volume * r)
		end

end -- class COMPOSITE_VOLUME_TUPLE
