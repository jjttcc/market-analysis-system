indexing
	description: "Composite tuple with volume";
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_VOLUME_TUPLE inherit

	COMPOSITE_TUPLE

	VOLUME_TUPLE
		undefine
			make, end_date
		end

creation

	make

feature -- Access

	volume: INTEGER

feature {COMPOSITE_TUPLE_FACTORY}

	set_volume (arg: INTEGER) is
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
			volume := (volume * r).floor
		end

end -- class COMPOSITE_VOLUME_TUPLE
