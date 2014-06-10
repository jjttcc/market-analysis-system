note
	description: "Enumerated types whose `item' type is CHARACTER"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class CHARACTER_ENUMERATED inherit

	ENUMERATED [CHARACTER]
		export
			{CHARACTER_ENUMERATED} make
		end

feature -- Access

	type_name: STRING
			-- Name of the type the enumeration represents
		deferred
		end

invariant

	name_exists: type_name /= Void and then not type_name.is_empty

end
