note
	description: "Additional MAS_PRODUCT_INFO information for the extended %
		%version of the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_PRODUCT_INFO inherit

	MAS_PRODUCT_INFO
		redefine
			name, number_components, date, release_description,
			license_information
		end

feature -- Access

	name: STRING
		note
			once_status: global
		once
			Result := Precursor + " (Extended version)"
		end

	number_components: ARRAY [STRING]
			-- The components of the version number
			-- Components are strings to allow mixed numbers and letters.
		note
			once_status: global
		once
			Result := Precursor
		end

	date: DATE
			-- The last date that `number' was updated
		note
			once_status: global
		once
			Result := Precursor
		end

	release_description: STRING
			-- Short description of the current release
		note
			once_status: global
		once
			Result := Precursor
		end

	license_information: STRING
		note
			once_status: global
		once
			Result :=
"GNU General Public License, version 2%N%N%
%[http://www.gnu.org/licenses/gpl-2.0.html]"
		end

end
