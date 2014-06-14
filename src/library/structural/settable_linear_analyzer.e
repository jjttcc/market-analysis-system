note
	description: "LINEAR_ANALYZERs that have a settable `target' attribute"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
	licensing_addendum: "Part of this class was copied directly from the %
		%LINEAR_ITERATOR class from the EiffelBase 4.x library, which %
		%is released under the The ISE Free Eiffel Library License (IFELL).%
		%This license can be found online at:%
		%http://www.eiffel.com/products/base/license.html"

deferred class SETTABLE_LINEAR_ANALYZER inherit

	LINEAR_ANALYZER

feature {FACTORY, COMMAND}

	target: LIST [MARKET_TUPLE]

feature -- Initialization

	set (s: LIST [MARKET_TUPLE])
			-- Make `s' the new target of iterations.
		require
			target_exists: s /= Void
		do
--!!!!Check if this "cast" works and look into the possible alternative of
--!!!!changing the type of 'target', above!!!!:
			if attached {MARKET_TUPLE_LIST [BASIC_MARKET_TUPLE]} s as mtl then
				target := mtl
			end
		ensure
			target = s
			target /= Void
		end

end
