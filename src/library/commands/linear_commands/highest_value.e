indexing
	description: 
		"An abstraction for a market vector analyzer that finds%
		%the highest high value in the last n trading periods.%
		%[Will have to redefine input to be an array of standard%
		%market tuple - ditto for LL and CLOSING_PRICE.]%
		%{Note to self:  Will need to have some mechanism for the%
		%concept of sub-cursor incrementing - that is, the highest%
		%high will be calculated according to a primary cursor%
		%(perhaps going back n - 1 items from the current cursor)%
		%and this calculation will need to use a sub-cursor for%
		%iterating over the n items to find the high.  Possible solution:%
		%don't redefine forth in n_record_analyzer so that it will call forth%
		%on the input array (and make sure this forth is used in the main%
		%function that iterates over the array); then redefine forth in HH%
		%to keep its own internal cursor so that it doesn't change the input%
		%array's cursor - OR: use the input array's cursor and restore it to%
		%its original value when finished.  (2nd solution will disallow%
		%concurrency during highest high processing, but that is probably OK.)}"
	date: "$Date$";
	revision: "$Revision$"

class HIGHEST_HIGH inherit

	N_RECORD_COMMAND
		redefine
			start_init, sub_action
		end

creation

	make

feature {NONE} -- Implementation

	start_init is
		do
			value := 0
		end

	sub_action (current_index: INTEGER) is
		do
			if (input @ current_index).high.value > value then
				value := (input @ current_index).high.value
			end
		end

end -- class HIGHEST_HIGH
