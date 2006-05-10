indexing
	description: "Additional MAS_PRODUCT_INFO information for the extended %
		%version of the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class EXTENDED_PRODUCT_INFO inherit

	MAS_PRODUCT_INFO
		redefine
			name, number_components, date, release_description,
			license_information
		end

feature -- Access

	name: STRING is
		indexing
			once_status: global
		once
			Result := Precursor + " (Extended version)"
		end

	number_components: ARRAY [STRING] is
			-- The components of the version number
			-- Components are strings to allow mixed numbers and letters.
		indexing
			once_status: global
		once
			Result := Precursor
		end

	date: DATE is
			-- The last date that `number' was updated
		indexing
			once_status: global
		once
			Result := Precursor
		end

	release_description: STRING is
			-- Short description of the current release
		indexing
			once_status: global
		once
			Result := Precursor
		end

	license_information: STRING is
		indexing
			once_status: global
		once
			Result := "To be determined%
%%N%N%
%THIS PACKAGE IS PROVIDED %"AS IS%" AND WITHOUT WARRANTY. ANY EXPRESS%N%
%OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED%N%
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE%N%
%DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE TO ANY PARTY FOR%N%
%ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL%N%
%DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THIS PACKAGE."
		end

end
