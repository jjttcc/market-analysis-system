indexing
	description: 
		"A abstraction that provides a concept of an n-lenth record"
	date: "$Date$";
	revision: "$Revision$"

class
	N_RECORD_STRUCTURE

feature

	n: INTEGER
			-- The length of the sub-list to be analyzed

feature {FACTORY} -- Element change

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

end -- class N_RECORD_ANALYZER
