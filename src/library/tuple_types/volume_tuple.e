indexing
	description: "A basic market tuple with a volume attribute";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE inherit

	BASIC_MARKET_TUPLE

creation

	make

feature -- Access

	volume: INTEGER
			-- Number of shares

feature {VALUE_SETTER}

	set_volume (v: INTEGER) is
			-- Set volume to `v'.
		require
			v >= 0
		do
			volume := v
		ensure
			volume = v
		end

invariant

	volume_ge_0: volume >= 0

end -- class VOLUME_TUPLE
