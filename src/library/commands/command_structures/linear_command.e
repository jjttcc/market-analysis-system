indexing
	description: "A numeric command that is also a linear analyzer"
	date: "$Date$";
	revision: "$Revision$"

deferred class LINEAR_COMMAND inherit

	NUMERIC_COMMAND

	LINEAR_ANALYZER
		export {NONE}
			all
				{FACTORY}
			set_target
		end

feature -- Initialization

	make (t: like target) is
		require
			t_not_void: t /= Void
		do
			set_target (t)
		ensure
			target_set: target = t
		end

end -- class LINEAR_COMMAND
