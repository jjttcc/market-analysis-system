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

feature -- Status report

	n_set: BOOLEAN is
			-- Has n been set?
		do
			Result := n > 0
		end

feature {FACTORY} -- Element change

	set_n (value: INTEGER) is
			-- Set n to `value'.
		require
			value_gt_0: value > 0
		do
			n := value
		ensure
			n_set_to_value: n = value
			n_set: n_set
		end

invariant

	n_positive_if_set: n_set = (n > 0)

end -- class N_RECORD_ANALYZER
