note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class

	SIDEMAN_ONE [G]

inherit

	SIDEMAN [G]

create

	make

feature {NONE} -- Implementation

	make(a: G)
		do
			attr := a
		end

	extra_report: STRING
		do
			Result := ""
			Result := attr.generating_type + "%N"
		end

invariant
	invariant_clause: True -- Your invariant here

end