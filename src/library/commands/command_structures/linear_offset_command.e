indexing
	description:
		"A linear command that changes the cursor of the target according %
		%to an offset value, operates on the target at that cursor %
		%position, and restores the cursor to the original value."
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class LINEAR_OFFSET_COMMAND inherit

	LINEAR_COMMAND

feature -- Access

	offset: INTEGER is
			-- offset to current index specifying which relative
			-- position of target to access - may be positive or negative,
			-- but must never cause an out-of-bounds access on target -
			-- that is:  target.valid_index (target.index + offset)
		deferred
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is
		once
			Result := true
		end

feature -- Basic operations

	execute (arg: ANY) is
		local
			original_cursor: CURSOR
		do
			original_cursor := target.cursor
			target.move (offset)
			check
				target_not_off: not target.off
			end
			operate (arg)
			target.go_to (original_cursor) -- Restore cursor.
		end

feature {NONE} -- Hook methods

	operate (arg: ANY) is
			-- Operate on `target' at the current cursor position.
		deferred
		end

end -- class LINEAR_OFFSET_COMMAND
