note
	description:
		"A storable list of MARKET_EVENT_GENERATORs that wipes out each %
		%generator before saving it to persistent store."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STORABLE_EVENT_GENERATOR_LIST inherit

	STORABLE_LIST [MARKET_EVENT_GENERATOR]
		redefine
			save
		end

	MARKET_FUNCTION_EDITOR
		undefine
			copy, is_equal
		end

creation

	make

feature -- Utility

	save
			-- Call wipe_out on each item to ensure that no extra data
			-- is stored to the file; then call precursor to save the
			-- remaining contents.
		do
			from
				start
			until
				exhausted
			loop
				item.wipe_out
				forth
			end
			Precursor
		end

end -- STORABLE_EVENT_GENERATOR_LIST
