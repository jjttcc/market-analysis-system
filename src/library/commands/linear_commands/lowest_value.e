class LOWEST_LOW inherit

	N_RECORD_COMMAND
		redefine
			start_init, sub_action
		end

creation

	make

feature {NONE} -- Basic operations

	sub_action (current_index: INTEGER) is
		do
			if (input @ current_index).low.value < value then
				value := (input @ current_index).low.value
			end
		end

	start_init is
		do
			value := 999999999
		end

end -- class LOWEST_LOW
