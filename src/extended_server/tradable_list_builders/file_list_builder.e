indexing
	description: "Builder of FILE_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class FILE_LIST_BUILDER inherit

	FILE_LIST_BUILDER_FACILITIES
		redefine
			new_tradable_list
		end

creation

	make

feature -- Access

	new_tradable_list (fnames: LIST [STRING]; factory: TRADABLE_FACTORY):
		EXTENDED_FILE_TRADABLE_LIST is
			-- A new HTTP_LOADING_FILE_TRADABLE_LIST
		do
			create Result.make (fnames, factory)
		end

end