note
	description: "Abstraction of tradable tuple manufacturer";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class TUPLE_FACTORY inherit

	GENERIC_FACTORY [TRADABLE_TUPLE]

feature -- Access

	product: TRADABLE_TUPLE

feature -- Basic operations

	execute
			-- Manufacture a tuple
		deferred
		end

end -- class TUPLE_FACTORY
