indexing
	description: 
		"An abstraction that provides services for processing an array%
		%of market tuples.%
		%{Note to self:  This class may inherit from linear_iterator, thus%
		%providing template methods for iteration that call hook methods.%
		%For example, highest_high may use this facility to iterate from%
		%current index - n - 1 to current index, using continue_while: redefine%
		%forth (actually forth should probably be redefined in vector_analyzer -%
		%to increment a counter), action (which will store the current highest%
		%value in an attribute), and test (to always returne true - unless that is%
		%the default implementation)."
	date: "$Date$";
	revision: "$Revision$"

class VECTOR_ANALYZER

inherit

	LINEAR_ITERATOR [MARKET_TUPLE]
		export
			{NONE} all
		redefine
			target
		end

feature {NONE}

	target: ARRAYED_LIST [MARKET_TUPLE]

end -- class VECTOR_ANALYZER
