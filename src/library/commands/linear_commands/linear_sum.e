indexing
	description: "Sum of n vector elements.";
	date: "$Date$";
	revision: "$Revision$"

class VECTOR_SUM inherit

	NUMERIC_COMMAND
		redefine
			valid_state
		end

	VECTOR_ANALYZER
		export {ANY}
			set
		redefine
			test, action, forth
		end

	N_RECORD_STRUCTURE

feature -- Basic operations

	execute (arg: ANY) is
		do
			internal_index := 0
			value := 0
			until_continue
		ensure then
			-- target.index = old target.index + n
			-- value = sum (target [original_index .. original_index + n - 1])
			int_index_eq_n: internal_index = n
		end

feature {NONE}

	forth is
		do
			internal_index := internal_index + 1
			target.forth
		end

	action is
		do
			value := value + target.item.value
		ensure then
			-- value = sum (
			-- target [original_index .. original_index + internal_index - 1])
			--   where original_index is the value of target.index when
			--   execute is called.
		end

	test: BOOLEAN is
		do
			Result := internal_index = n
		end

	valid_state: BOOLEAN is
			-- Is Current in a valid state?
			-- Default to true - descendants redefine as necessary.
		do
			Result := target.valid_index(target.index)
		end

feature {NONE}

	internal_index: INTEGER

feature {NONE} -- !!REmove this soon

	reset_state is do end

end -- class VECTOR_SUM
