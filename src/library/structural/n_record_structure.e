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

feature {NONE} -- Element change

	set_n (value: INTEGER) is
			-- Set n to `value'.
		require
			value >= 1
		do
			n := value
		ensure
			n = value
		end

feature {NONE} -- Implementation

	init_n is
		do
			n := 1
		ensure
			n = 1
		end

invariant

	n_positive: n >= 1

end -- class N_RECORD_ANALYZER
