note
	description: "Builder of HTTP_LOADING_FILE_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class HTTP_FILE_LIST_BUILDER inherit

	HTTP_FILE_LIST_BUILDER_FACILITIES
		redefine
			new_tradable_list
		end

creation

	make

feature -- Access

	new_tradable_list (factory: TRADABLE_FACTORY; extension: STRING):
		EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST
			-- A new HTTP_LOADING_FILE_TRADABLE_LIST
		do
			create Result.make (factory, extension)
		end

end
