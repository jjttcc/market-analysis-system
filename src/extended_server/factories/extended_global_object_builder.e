indexing
	description: "Builder of objects used more or less globally throughout %
		%the system, of which there is usually only one instance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class EXTENDED_GLOBAL_OBJECT_BUILDER inherit

	GLOBAL_OBJECT_BUILDER
		redefine
			new_non_persistent_conn_if
		end

creation

	make

feature {NONE} -- Hook routine implementations

	new_non_persistent_conn_if: NON_PERSISTENT_CONNECTION_INTERFACE is
		do
			create {EXTENDED_MAIN_GUI_INTERFACE} Result.make (Current)
		end

end
