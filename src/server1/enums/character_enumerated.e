note
	description: "Enumerated types whose `item' type is CHARACTER"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
