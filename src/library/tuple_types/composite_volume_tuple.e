indexing
	description: "Composite tuple with volume";
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_VOLUME_TUPLE inherit

	COMPOSITE_TUPLE

creation

	make

feature -- Access

	volume: INTEGER
			-- Volume

feature {COMPOSITE_TUPLE_FACTORY}

	set_volume (arg: INTEGER) is
		require
			arg /= Void
		do
			volume := arg
		ensure
			volume_set: volume = arg and volume /= Void
		end

end -- class COMPOSITE_VOLUME_TUPLE
