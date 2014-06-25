note
	description:
		"A abstraction that provides a concept of an n-lenth record"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	N_RECORD_STRUCTURE

feature -- Access

	n: INTEGER
			-- The length of the sub-list to be analyzed

feature {FACTORY} -- Status setting

	set_n (value: INTEGER)
			-- Set n to `value'.
		require
			value_gt_0: value > 0
		do
			n := value
		ensure
			n_set_to_value: n = value
			n_gt_0: n > 0
		end

invariant

	n_positive: n > 0

end -- class N_RECORD_STRUCTURE
