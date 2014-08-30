note
	description:
		"Function parameter place-holders - valid for a MAS_SESSION"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SESSION_FUNCTION_PARAMETER inherit
	FUNCTION_PARAMETER
		redefine
			unique_name
		end

creation {MAS_SESSION}

	make

feature {NONE} -- Initialization

	make (param: FUNCTION_PARAMETER)
		require
			valid_args: param /= Void
		do
			current_value := param.current_value
			name := param.name
			unique_name := param.unique_name
			description := param.description
			value_type_description := param.value_type_description
		ensure
			set: current_value = param.current_value and name = param.name and
				unique_name = param.unique_name and description =
				param.description and value_type_description =
				param.value_type_description
		end

feature -- Access

	current_value: STRING

	name: STRING

	unique_name: STRING

	description: STRING

	value_type_description: STRING

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := v ~ current_value
		end

feature -- Element change

	change_value (new_value: STRING)
		do
			current_value := new_value
		end

feature -- Basic operations

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void
		end

end
