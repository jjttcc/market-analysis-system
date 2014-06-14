note
	description: "A volume tuple with volume redefined as an attribute";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class BASIC_VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

	VOLUME_TUPLE

creation

	make

feature -- Access

	volume: DOUBLE

feature {VALUE_SETTER, FACTORY}

	set_volume (v: DOUBLE)
			-- Set volume to `v'.
		require
			v >= 0
		do
			volume := v
		ensure
			volume = v
		end

feature {NONE}

	adjust_volume_for_split (r: DOUBLE)
		do
			volume := (volume * r).floor
		end

end -- class BASIC_VOLUME_TUPLE
