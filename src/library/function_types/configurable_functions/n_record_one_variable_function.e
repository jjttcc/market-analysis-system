indexing
	description:
		"A market function that provides a concept of an n-length %
		%sub-list of the main input list."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_ONE_VARIABLE_FUNCTION inherit

	ONE_VARIABLE_FUNCTION
		rename
			make as ovf_make
		redefine
			do_process, target, short_description,
			immediate_parameters
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

	effective_n: INTEGER is
			-- Effective n value - required because some descendants will
			-- need to effectively change n by adding a constant value.
		do
			Result := n
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
			if target.count < effective_n then
				-- null statement
			else
				target.go_i_th (effective_n)
				continue_until
			end
		ensure then
			when_tgcount_lt_n: target.count < effective_n implies output.empty
			when_tgcount_ge_n:
				target.count >= effective_n implies
					output.count = target.count - effective_n + 1
			first_date_set: not output.empty implies
				output.first.date_time.is_equal (
					target.i_th (effective_n).date_time)
			last_date_set: not output.empty implies
				output.last.date_time.is_equal (target.last.date_time)
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

	immediate_parameters: LIST [FUNCTION_PARAMETER] is
		local
			fp: N_RECORD_FUNCTION_PARAMETER
		do
			!LINKED_LIST [FUNCTION_PARAMETER]!Result.make
			!!fp.make (Current)
			Result.extend (fp)
		end

feature {N_RECORD_FUNCTION_PARAMETER}

	set_n (value: INTEGER) is
		do
			Precursor (value)
			if operator /= Void then
				operator.initialize (Current)
			end
			output.wipe_out
			processed_date_time := Void
		ensure then
			output_empty: output.empty
			not_processed: not processed
		end

invariant

	processed_when_target_lt_n:
		processed implies (target.count < effective_n implies output.empty)
	processed_when_target_ge_n:
		processed implies
			(target.count >= effective_n implies
				output.count = target.count - effective_n + 1)
	effective_n_gt_0: effective_n > 0

end -- class N_RECORD_ONE_VARIABLE_FUNCTION
