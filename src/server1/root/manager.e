note
	description: "Summary description for {MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MANAGER

create
	make


feature -- Access

	object: PARENT

feature -- Basic operations

	execute
		local
			report: STRING
		do
			report := "I, a " + generating_type + ", triggered a %N" +
				object.report
			print(report)
		end

feature {NONE} -- Initialization

	make(obj: PARENT)
			-- Initialization for `Current'.
		do
			object := obj
		end

end
