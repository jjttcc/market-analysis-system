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

deferred class VECTOR_ANALYZER

inherit

	LINEAR_ITERATOR [MARKET_TUPLE]
		rename
			target as input
		export
			{NONE} all
		redefine
			input
		end

feature -- Element change -- For now, export to test class.

	set_input (the_input: ARRAYED_LIST [MARKET_TUPLE]) is
			-- Set input vector to `the_input'.
		require
			not_void: the_input /= Void
		do
			input := the_input
			reset_state
		ensure
			input = the_input
		end

feature {NONE}

	input: ARRAYED_LIST [MARKET_TUPLE]

feature {NONE}

	reset_state is
			-- Reset to initial state.
			-- Intended to be redefined as needed.
		deferred
		end

end -- class VECTOR_ANALYZER
