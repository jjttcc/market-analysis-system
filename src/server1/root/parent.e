note
	description: "Summary description for {PARENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class

	PARENT

feature -- Access

	accessory: SIDEMAN [TYPE_PARENT]

	report: STRING
		do
			Result := generating_type + ",%Nwhich holds a " +
				accessory.report + "%N"
		end

end
