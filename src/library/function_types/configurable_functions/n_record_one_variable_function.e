indexing
	description:
		"A market function that provides a concept of an n-length %
		%sub-list of the main input list."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_ONE_VARIABLE_FUNCTION inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		redefine
			do_process, target, processed, short_description
		end

	N_RECORD_STRUCTURE
		redefine
			set_n
		end

creation {FACTORY}

	make

feature -- Access

	short_description: STRING is
		do
			!!Result.make (60)
			Result.append (n.out)
			Result.append ("-Period ")
			Result.append (Precursor)
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := (input.processed and target.count < n) or Precursor
		end

feature {NONE}

	make (in: like input; op: like operator; i: INTEGER) is
		require
			in_not_void: in /= Void
			op_not_void_if_used: operator_used implies op /= Void
			i_gt_0: i > 0
		do
			ovf_make (in, op)
			set_n (i)
		ensure
			set: input = in and operator = op and n = i
			target_set: target = in.output
		end

feature {NONE} -- Basic operations

	do_process is
			-- Execute the function.
		do
			check
				output_empty: output.empty
			end
			if target.count < n then
				-- null statement
			else
				target.go_i_th (n)
				continue_until
			end
		ensure then
			when_tgcount_lt_n: target.count < n implies output.empty
			when_tgcount_ge_n:
				target.count >= n implies output.count = target.count - n + 1
			first_date_set: not output.empty implies
				output.first.date_time.is_equal (target.i_th (n).date_time)
			last_date_set: not output.empty implies
				output.last.date_time.is_equal (target.last.date_time)
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY}

	set_n (value: INTEGER) is
		do
			Precursor (value)
			if operator /= Void then
				operator.initialize (Current)
			end
		end

invariant

	processed_when_target_lt_n:
		processed implies (target.count < n implies output.empty)
	processed_when_target_ge_n:
		processed implies
			(target.count >= n implies output.count = target.count - n + 1)

end -- class N_RECORD_ONE_VARIABLE_FUNCTION
