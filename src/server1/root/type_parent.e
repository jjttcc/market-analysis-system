note
	description: "Summary description for {TYPE_PARENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class

	TYPE_PARENT


feature -- Basic operations

	report: STRING
		do
			Result := generating_type + " [I  hold nothing]%N"
		end

end
