indexing
	description:
		"A abstraction that provides a concept of an n-lenth record"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class
	N_RECORD_STRUCTURE

feature

	n: INTEGER
			-- The length of the sub-list to be analyzed

feature {FACTORY} -- Status setting

	set_n (value: INTEGER) is
			-- Set n to `value'.
		require
			value_gt_0: value > 0
		do
			n := value
		ensure
			n_set_to_value: n = value
		end

invariant

	n_positive: n > 0

end -- class N_RECORD_STRUCTURE
