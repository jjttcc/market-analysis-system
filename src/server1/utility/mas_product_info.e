indexing
	description: "Information about the current version of the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class PRODUCT_INFO inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	name: STRING is
		once
			Result := "Market Analysis Server"
		end

	number: STRING is
			-- The version number as a string
		local
			i: INTEGER
		once
			create Result.make(0)
			from
				i := 1
			until
				i = number_components.count
			loop
				Result.append (number_components @ i)
				Result.append (".")
				i := i + 1
			end
			Result.append (number_components @ i)
		end

	number_components: ARRAY [STRING] is
			-- The components of the version number
			-- Components are strings to allow mixed numbers and letters.
		once
			Result := <<"1", "6", "c">>
		end

	date: DATE is
			-- The last date that `number' was updated
		once
			create Result.make (2001, 8, 2)
		end

	informal_date: STRING is
			-- Date in the format 'month, dd, yyyy', where month is a
			-- month name in English - January, February, ...
		once
			Result := concatenation (<<months @ date.month, " ",
						date.day, ", ", date.year>>)
		end

	copyright: STRING is
		once
			Result := "Copyright 1998 - 2001: Jim Cochrane"
		end

	license_information: STRING is
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
%DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THIS PACKAGE."
		end

feature {NONE} -- Implementation

	months: TABLE [STRING, INTEGER] is
		local
			r: ARRAY [STRING]
		once
			r := <<"January", "February", "March", "April",
					"May", "June", "July", "August",
					"September", "October", "November", "December">>
			Result := r
		end

end -- class PRODUCT_INFO
