indexing
	description: 
		"A binary operator that analyzes the sign of the result of its %
		%first operand as compared to that of its second operand. %
		%Specifications of sign changes to be detected (- to +, - to 0, etc.) %
		%are set by calling `add_sign_change_spec'."
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SIGN_ANALYZER inherit

	BINARY_OPERATOR [BOOLEAN, REAL]
		rename
			make as bo_make_unused
		export {NONE}
			bo_make_unused
				{MARKET_FUNCTION}
			initialize
		end

creation

	make

feature -- Initialization

	make (o1, o2: like operand1; init_sign_spec: BOOLEAN) is
			-- Initialize operands and, if `init_sign_spec' is true,
			-- initialize the contents of `sign_change_spec'.
		require
			not_void: o1 /= Void and o2 /= Void
		local
			a: ARRAY [INTEGER]
		do
			!!sign_change_spec.make
			if init_sign_spec then
				!!a.make (1, 2)
				a := <<1, -1>>
				sign_change_spec.extend (a)
				!!a.make (1, 2)
				a := <<-1, 1>>
				sign_change_spec.extend (a)
			end
			set_operands (o1, o2)
		ensure
			set: operand1 = o1 and operand2 = o2
			init_spec_values: init_sign_spec implies
				sign_change_spec.i_th (1).item (1) = 1 and
				sign_change_spec.i_th (1).item (2) = -1 and
				sign_change_spec.i_th (2).item (1) = -1 and
				sign_change_spec.i_th (2).item (2) = 1
			spec_empty_if_not_init:
				not init_sign_spec implies sign_change_spec.empty
		end

feature -- Access

	sign_change_spec: LINKED_LIST [ARRAY [INTEGER]]
			-- Specification for sign changes to check for.  Each 2-element
			-- array member of the list specifies a `valid' sign change:
			-- element 1 specifies a valid sign for the result of execution
			-- of operand1; element 2 specifies a valid sign for the
			-- result of execution of operand2.  The specifications are
			-- 'or'ed, so that a sign change that matches any elements of
			-- `sign_change_spec' will result in `value' set to true.
			-- Valid values for elements 1 and 2 of each array are -1
			-- (negative sign), 1 (positive sign), and 0.

feature -- Status setting

	add_sign_change_spec (a: ARRAY [INTEGER]) is
			-- Add a sign change specification.
		require
			valid_size: a /= Void and a.count = 2
			first_element_valid: a @ 1 = -1 or a @ 1 = 0 or a @ 1 = 1
			second_element_valid: a @ 2 = -1 or a @ 2 = 0 or a @ 2 = 1
			not_equal: a @ 1 /= a @ 2
		do
			sign_change_spec.extend (a)
		ensure
			sign_change_spec.has (a)
		end

feature {NONE} -- Hook routine implementation

	operate (v1, v2: REAL) is
		do
			value := false
			from
				sign_change_spec.start
			until
				value or sign_change_spec.exhausted
			loop
				value := sign_change_spec.item @ 1 = v1.sign and
							sign_change_spec.item @ 2 = v2.sign
				sign_change_spec.forth
			end
		end

end -- class SIGN_ANALYZER
