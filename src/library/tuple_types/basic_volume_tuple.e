indexing
	description: "A volume tuple with volume redefined as an attribute";
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

	VOLUME_TUPLE

creation

	make

feature -- Access

	volume: REAL

feature {VALUE_SETTER, FACTORY}

	set_volume (v: REAL) is
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
