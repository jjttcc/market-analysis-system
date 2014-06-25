note
	description: "LINEAR_ANALYZERs that have a settable `target' attribute"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
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

	set (s: like target)
			-- Make `s' the new target of iterations.
		require
			target_exists: s /= Void
		do
			target := s
		ensure
			target = s
			target /= Void
		end

end
