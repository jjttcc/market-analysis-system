indexing
	description: "A volume tuple with volume redefined as an attribute";
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

	VOLUME_TUPLE

creation

	make

feature -- Access

	volume: INTEGER

feature {VALUE_SETTER, FACTORY}

	set_volume (v: INTEGER) is
			-- Set volume to `v'.
		require
			v >= 0
		do
			volume := v
		ensure
			volume = v
		end

feature {NONE}

	adjust_volume_for_split (r: REAL) is
		do
			volume := (volume * r).floor
		end

end -- class BASIC_VOLUME_TUPLE
