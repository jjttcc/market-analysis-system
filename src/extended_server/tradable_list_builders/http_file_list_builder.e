indexing
	description: "Builder of HTTP_LOADING_FILE_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HTTP_FILE_LIST_BUILDER inherit

	HTTP_FILE_LIST_BUILDER_FACILITIES
		redefine
			new_tradable_list
		end

creation

	make

feature -- Access

	new_tradable_list (factory: TRADABLE_FACTORY; extension: STRING):
		EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST is
			-- A new HTTP_LOADING_FILE_TRADABLE_LIST
		do
			create Result.make (factory, extension)
		end

end
