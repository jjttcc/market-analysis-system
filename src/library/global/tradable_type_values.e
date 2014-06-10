note
	description: "Allowed values for the tradable type enumeration"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_TYPE_VALUES inherit

feature -- Access

	stock, derivative: INTEGER = unique

invariant

end
