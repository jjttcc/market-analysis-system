note
	description: "Summary description for {SIDEMAN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class

	SIDEMAN [G]

feature -- Access

	attr: attached G

	report: STRING
		do
			Result := generating_type + ",%Nwhich holds a "
			if attached attr then
				Result := Result + extra_report
			end
		end

feature {NONE} -- Implementation

	extra_report: STRING
		deferred
		end

invariant
	invariant_clause: True -- Your invariant here

end
