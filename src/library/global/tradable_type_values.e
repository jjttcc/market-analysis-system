note
	description: "Allowed values for the tradable type enumeration"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_TYPE_VALUES inherit

feature -- Access

	stock, derivative: INTEGER = unique

invariant

end
