note
	description: "Builder of objects used more or less globally throughout %
		%the system, of which there is usually only one instance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_GLOBAL_OBJECT_BUILDER inherit

	GLOBAL_OBJECT_BUILDER
		redefine
			new_non_persistent_conn_if
		end

creation

	make

feature {NONE} -- Hook routine implementations

	new_non_persistent_conn_if: NON_PERSISTENT_CONNECTION_INTERFACE
		do
			create {EXTENDED_MAIN_GUI_INTERFACE} Result.make (Current)
		end

end
