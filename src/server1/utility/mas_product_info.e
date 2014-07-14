note
	description: "Information about the current version of the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_PRODUCT_INFO inherit

	PRODUCT_INFO

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	name: STRING
		note
			once_status: global
		once
			Result := "Market Analysis Server"
		end

	number_components: ARRAY [STRING]
			-- The components of the version number
			-- Components are strings to allow mixed numbers and letters.
		note
			once_status: global
		local
			s: STRING
		once
			Result := <<"1", "8", "2" + "[es14.05">>
			s := Result @ Result.upper
			debug ("multi_threaded_version")
				s.append ("MT")
			end
			debug ("non_multi_threaded_version")
				s.append ("ST")
			end
			s.append (" @" + formatted_compile_date_time)
			s.append ("]")
		end

	date: DATE
			-- The last date that `number' was updated
		note
			once_status: global
		once
			create Result.make(2014, 7, 6)
		end

	release_description: STRING
			-- Short description of the current release
		note
			once_status: global
		once
			Result := number + " - (Pre-beta release)"
		end

	copyright: STRING
		note
			once_status: global
		once
			Result := "Copyright 1998 - 2014: Jim Cochrane"
		end

	license_information: STRING
		note
			once_status: global
		once
			Result := "GNU General Public License, version 2%N%N%
				%[http://www.gnu.org/licenses/gpl-2.0.html]"
		end

feature {NONE} -- Implementation

	formatted_compile_date_time: STRING
		once
			Result :=
			-- start: compile-time
				"2014-07-14 03:43:56"
			-- end: compile-time
		end

end -- class MAS_PRODUCT_INFO
