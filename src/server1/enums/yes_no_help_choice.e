indexing
	description: "Enumerated '<object> menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class YES_NO_HELP_CHOICE inherit

	CHARACTER_ENUMERATED

	YES_NO_HELP_VALUES
		undefine
			out
		end

create

	make_yes, make_no, make_help

create {YES_NO_HELP_CHOICE}

	make

feature -- Access

	abbreviation: STRING is "y/n/h"

feature {NONE} -- Initialization

	make_yes is
		do
			make ('y')
		end

	make_no is
		do
			make ('n')
		end

	make_help is
		do
			make ('h')
		end

	type_name: STRING is "yes/no/help"

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER] is
		do
			Result := <<yes, yes_u, no, no_u, help, help_u>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (6)
			Result.put ("yes choice from " + type_name, yes)
			Result.put ("yes choice from " + type_name, yes_u)
			Result.put ("no choice from " + type_name, no)
			Result.put ("no choice from " + type_name, no_u)
			Result.put ("help choice from " + type_name, help)
			Result.put ("help choice from " + type_name, help_u)
		end

end
