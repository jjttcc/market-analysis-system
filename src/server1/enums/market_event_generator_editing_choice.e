note
	description: "Enumerated 'market-event-generator editing' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MARKET_EVENT_GENERATOR_EDITING_CHOICE inherit

	OBJECT_EDITING_CHOICE

	OBJECT_EDITING_VALUES
		undefine
			out
		end

create

	make_creat, make_remove, make_edit, make_view, make_save, make_previous

create {ENUMERATED}

	make

feature -- Access

	type_name: STRING = "market analyzer"

end
