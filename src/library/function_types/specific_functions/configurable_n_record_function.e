indexing
	description:
		"N-period function that can be configured by choosing the %
		%operators it will use.  (Usually used for complex moving averages.)"
	note:
		"`previous_operator' has some special constraints - See note in %
		%parent, FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class CONFIGURABLE_N_RECORD_FUNCTION inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		rename
			make as nrovf_make_unused
		export
			{NONE} nrovf_make_unused
		undefine
			forth, do_process
		redefine
			set_n, short_description, start, initialize_operators, target
		end

	FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS
		export
			{NONE} set_operator
		undefine
			immediate_parameters, set_operator
		redefine
			short_description, start, initialize_operators, target
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

target: ARRAYED_LIST [MARKET_TUPLE]

	short_description: STRING is
		do
			create Result.make (33)
			Result.append (n.out)
			Result.append ("-Period function that can be configured %
				%by choosing its operators")
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator;
				first_op: like first_element_operator; i: INTEGER) is
		require
			input_ops_not_void: in /= Void and op /= Void and
				first_op /= Void
		do
			check operator_used end
			create output.make (in.output.count)
			set_input (in)
			set_operator (op)
			first_element_operator := first_op
			set_n (i)
		end

feature {NONE} -- Basic operations

	start is
		local
			t: SIMPLE_TUPLE
			tuple: MARKET_TUPLE
		do
			check
				output_empty: output.empty
			end
			if target.count < effective_n then
				-- There are not enough elements in target to process;
				-- ensure that exhausted is true:
				target.finish
			else
				check target.count >= effective_n end
				-- Operate on the first element of `target' (with
				-- `first_element_operator'), put the result into `output'
				-- as its first element, and increment `target' to the
				-- 2nd element.
				target.start
				if not target.empty then
					first_element_operator.execute (target.item)
					if target.index /= 1 then
						-- first_element_operator incremented target's
						-- cursor, so the date needs to be obtained from
						-- the last item processed by first_element_operator.
						tuple := target.i_th (target.index - 1)
					else
						tuple := target.item
					end
					create t.make (tuple.date_time, tuple.end_date,
								first_element_operator.value)
					output.extend (t)
				end
				if previous_operator /= Void then
					-- Prepare output for use by previous_operator - set to
					-- first item that was inserted above or `after' if
					-- target is empty.
					output.start
					-- Important - previous operator will operate on the
					-- current item of `output', which will always be the
					-- last inserted item.
					previous_operator.set_target (output)
				end
			end
		ensure then
			empty_if_empty: target.empty = output.empty
			output_at_last: not output.empty and previous_operator /= Void
				implies output.islast
		end

feature {MARKET_FUNCTION_EDITOR}

	set_n (value: INTEGER) is
		do
			Precursor (value)
			check n = value end
			if previous_operator /= Void then
				previous_operator.initialize (Current)
			end
			first_element_operator.initialize (Current)
		end

feature {NONE} -- Implementation

	initialize_operators is
		do
			if operator /= Void then
				operator.initialize (Current)
			end
			if previous_operator /= Void then
				previous_operator.initialize (Current)
			end
			if first_element_operator /= Void then
				first_element_operator.initialize (Current)
			end
		end

invariant

end -- class CONFIGURABLE_N_RECORD_FUNCTION
