indexing
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

	volume: REAL

feature {COMPOSITE_TUPLE_FACTORY}

	set_volume (arg: REAL) is
		require
			arg /= Void
		do
			volume := arg
		ensure
			volume_set: volume = arg and volume /= Void
		end

feature {NONE}

	adjust_volume_for_split (r: REAL) is
		do
			volume := (volume * r)
		end

end -- class COMPOSITE_VOLUME_TUPLE
