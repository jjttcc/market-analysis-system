note
	description: "Information about the current version of the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2014: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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
			t: TIME
		once
			Result := <<"1", "8", "1" + "[es14.05">>
			s := Result @ Result.upper
			debug ("multi_threaded_version")
				s.append ("MT")
			end
			debug ("non_multi_threaded_version")
				s.append ("ST")
			end
--!!!s.append ((create {TIME} make_now).out)
			s.append ("]")
		end

	date: DATE
			-- The last date that `number' was updated
		note
			once_status: global
		once
--!!!!!![14.05]!!!For debugging purposes [for now], use current date.
			create Result.make_now
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
			Result :=
"Eiffel Forum License, version 1%N%N%
%Permission is hereby granted to use, copy, modify and/or distribute%N%
%this package, provided that:%N%N%
%  - copyright notices are retained unchanged.%N%N%
%  - any distribution of this package, whether modified or not,%N%
%    includes this file.%N%N%
%Permission is hereby also granted to distribute binary programs which%N%
%depend on this package, provided that:%N%N%
%  - if the binary program depends on a modified version of this%N%
%    package, you must publicly release the modified version of this%N%
%    package.%N%N%
%THIS PACKAGE IS PROVIDED %"AS IS%" AND WITHOUT WARRANTY. ANY EXPRESS%N%
%OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED%N%
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE%N%
%DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE TO ANY PARTY FOR%N%
%ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL%N%
%DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THIS PACKAGE.%N%N%
%This software is OSI Certified Open Source Software.  OSI Certified is%N%
%a certification mark of the Open Source Initiative."
		end

end -- class MAS_PRODUCT_INFO
