indexing
	description: 
		"A abstraction that provides a concept of an n-lenth record"

class
	N_RECORD_STRUCTURE

feature

	n: INTEGER
			-- The length of the sub-vector to be analyzed

feature -- Element change

	set_n (value: INTEGER) is
			-- Set n to the specified value.
		require
			value >= 1
		do
			n := value
		ensure
			n = value
		end

end -- class N_RECORD_ANALYZER
