indexing
	description: "A numeric command that is also a linear analyzer"
	date: "$Date$";
	revision: "$Revision$"

deferred class LINEAR_COMMAND inherit

	NUMERIC_COMMAND
		redefine
			execute
		end

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

feature -- Basic operations

	execute (arg: ANY) is
		deferred
		ensure then
			target_cursor_internal_contract:
			target_cursor_not_affected = (target.index = old target.index)
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is
			-- Will target.index change when execute is called?
		deferred
		end

end -- class LINEAR_COMMAND
