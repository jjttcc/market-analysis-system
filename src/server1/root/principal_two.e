note
	description: "Summary description for {PRINCIPAL_TWO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PRINCIPAL_TWO

inherit

	PARENT
		redefine
			accessory
		end

create

	make


feature -- Access

	accessory: SIDEMAN_TWO [TYPEB]

feature {NONE} -- Initialization

	make(a: SIDEMAN_TWO [TYPEB])
			-- Initialization for `Current'.
		do
			accessory := a
		end

end
