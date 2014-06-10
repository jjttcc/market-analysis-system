note
	description:
		"Linear commands that change the cursor of the target according %
		%to an offset value, operate on the target at that cursor %
		%position, and restore the cursor to the original value."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class LINEAR_OFFSET_COMMAND inherit

	LINEAR_COMMAND

feature -- Access

	external_offset: INTEGER
			-- Offset to be used externally, for example, to set the
			-- `effective_n' value of an N_RECORD_ONE_VARIABLE_FUNCTION -
			-- Will probably either be 0 or the value of `offset'.
		deferred
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN
			-- True
		note
			once_status: global
		once
			Result := True
		end

feature -- Basic operations

	execute (arg: ANY)
		local
			old_i: INTEGER
		do
			old_i := target.index
			if old_i + offset >= 1 then
				target.move (offset)
				check
					target_not_off: not target.off
					target_index_value: target.index = old_i + offset
				end
			else
				target.go_i_th (1)
			end
			check
				target_not_off: not target.off
			end
			operate (arg)
			target.go_i_th (old_i) -- Restore cursor.
		end

feature {NONE}

	offset: INTEGER
			-- offset to current index specifying which relative
			-- position of target to access - may be positive or negative,
			-- but must never cause an out-of-bounds access on target -
			-- that is:  target.valid_index (target.index + offset)
		deferred
		end

feature {NONE} -- Hook methods

	operate (arg: ANY)
			-- Operate on `target' at the current cursor position.
		deferred
		end

end -- class LINEAR_OFFSET_COMMAND
