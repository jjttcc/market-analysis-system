indexing
	description: "Sum of n vector elements.";
	date: "$Date$";
	revision: "$Revision$"

class VECTOR_SUM inherit

	NUMERIC_COMMAND
		redefine
			initialize
		end

	VECTOR_ANALYZER
		redefine
			test, action, forth, invariant_value
		end

	N_RECORD_STRUCTURE

creation

	make

feature -- Initialization

	make is
		do
			init_n
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			internal_index := 0
			value := 0
			until_continue
		ensure then
			-- target.index = old target.index + n
			-- value = sum(target[old target.index .. old target.index + n - 1])
			int_index_eq_n: internal_index = n
		end

feature

	invariant_value: BOOLEAN is
		do
			--!!!Result := 0 <= internal_index and internal_index <= n and
			--!!!			(target.valid_index (target.index) or exhausted)
			Result := true -- !!!Remove this when above is uncommented OR
			               -- !!!delete the entire routine.
		end

feature {MARKET_FUNCTION} -- export to??

	set_input (in: LINEAR [MARKET_TUPLE]) is
		do
			target := in
		ensure then
			target = in and target /= Void
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

feature {NONE}

	internal_index: INTEGER

invariant

	--!!!valid_target_index: target /= Void and not target.before implies
	--!!!						invariant_value

end -- class VECTOR_SUM
