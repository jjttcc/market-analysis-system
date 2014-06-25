note
	description: "Composite tuple with volume";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
