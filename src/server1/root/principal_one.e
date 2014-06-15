note
	description: "Summary description for {PRINCIPAL_ONE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class

	PRINCIPAL_ONE

inherit

	PARENT
		redefine
			accessory
		end

create

	make

feature -- Access

	accessory: SIDEMAN_ONE [TYPEA]

feature {NONE} -- Initialization

	make(a: SIDEMAN_ONE [TYPEA])
			-- Initialization for `Current'.
		do
			accessory := a
		end

end
