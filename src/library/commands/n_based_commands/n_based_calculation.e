indexing
	description:
		"Calculation based on the n-value from an n-record structure";
	date: "$Date$";
	revision: "$Revision$"

deferred class N_BASED_CALCULATION inherit

	NUMERIC_COMMAND

feature -- Element change

	set_owner (o: N_RECORD_STRUCTURE) is
		require
			not_void:  o /= Void
		do
			owner := o
			value := calculate (owner.n)
		ensure
			owner_is_set: owner = o
			value = calculate (owner.n)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			-- Empty
		end

feature {NONE} -- Implmentation

	owner: N_RECORD_STRUCTURE

	calculate (n: REAL): REAL is
			-- Perform the calculation based on n.
		deferred
		end

end -- class N_BASED_CALCULATION
