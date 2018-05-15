note
	description:
		"N-period function that can be configured by choosing the %
		%operators it will use.  (Usually used for complex moving averages.)"
	note1:
		"`previous_operator' has some special constraints - See note in %
		%parent, FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONFIGURABLE_N_RECORD_FUNCTION inherit

	N_RECORD_ONE_VARIABLE_FUNCTION
		rename
			make as nrovf_make_unused
		export
			{NONE} nrovf_make_unused
		undefine
			forth, do_process, direct_operators 
		redefine
			set_n, short_description, start, initialize_operators, target,
			strict_n_count, action
		end

	FUNCTION_WITH_FIRST_AND_PREVIOUS_OPERATORS
		export
			{NONE} set_operator
		undefine
			immediate_direct_parameters, set_operator
		redefine
			short_description, start, initialize_operators, target, action
		end

creation {FACTORY, TRADABLE_FUNCTION_EDITOR}

	make

feature -- Access

	target: ARRAYED_LIST [TRADABLE_TUPLE]

	short_description: STRING
		do
			create Result.make (33)
			Result.append (n.out)
			Result.append ("-Period function that can be configured %
				%by choosing its operators")
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator;
				first_op: like first_element_operator; i: INTEGER)
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

	start
		local
			t: SIMPLE_TUPLE
			tuple: TRADABLE_TUPLE
		do
			check
				output_empty: output.is_empty
			end
			initialize_previous_operator_attached
			if target.count < effective_n then
				-- There are not enough elements in target to process;
				-- ensure that exhausted is True:
				target.finish
				if not target.off then target.forth end
				check
					target_exhausted: target.exhausted
				end
			else
				check target.count >= effective_n end
				-- Operate on the first element of `target' (with
				-- `first_element_operator'), put the result into `output'
				-- as its first element, and increment `target' to the
				-- 2nd element.
				target.start
				if not target.is_empty then
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
					previous_operator.set (output)
				end
			end
			if debugging then
				print_status_report
			end
		ensure then
			output_at_last: not output.is_empty and previous_operator /= Void
				implies output.islast
		end

	action
		do
			if not previous_operator_attached then
				-- Because `previous_operator' is not a component of
				-- `operator's command tree, it will not be executed when
				-- `operator.execute' is called.  Therefore,
				-- `previous_operator' must be executed explicitly.
				previous_operator.execute (target.item)
			end
			Precursor
		end

feature {TRADABLE_FUNCTION_EDITOR}

	set_n (value: INTEGER)
		do
			Precursor (value)
			check n = value end
			if previous_operator /= Void then
				previous_operator.initialize (Current)
			end
			first_element_operator.initialize (Current)
		end

feature {NONE} -- Implementation

	initialize_operators
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

	strict_n_count: BOOLEAN = False

	previous_operator_attached: BOOLEAN
			-- Is `previous_operator' a component of `operator's tree?

	initialize_previous_operator_attached
		local
			l: LIST [COMMAND]
		do
			previous_operator_attached := previous_operator = operator
			if not previous_operator_attached then
				l := operator.descendants
				from
					l.start
				until
					previous_operator_attached or l.exhausted
				loop
					previous_operator_attached := previous_operator = l.item
					l.forth
				end
			end
		end

invariant

end -- class CONFIGURABLE_N_RECORD_FUNCTION
