note
	description: "Enumerated 'tradable-function menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class FUNCTION_MENU_CHOICE inherit

	OBJECT_MENU_CHOICE

	FUNCTION_MENU_VALUES
		undefine
			out
		end

create

	make_description, make_another, make_choice

create {ENUMERATED}

	make

end
