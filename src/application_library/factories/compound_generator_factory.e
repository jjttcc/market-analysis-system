indexing
	description:
		"Factory class that manufactures COMPOUND_EVENT_GENERATORs"
	note: "Features left_generator, right_generator, and event_type should %
		%all be non-Void when execute is called."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOUND_GENERATOR_FACTORY inherit

	EVENT_GENERATOR_FACTORY
		redefine
			product
		end

feature -- Access

	product: COMPOUND_EVENT_GENERATOR

	left_generator, right_generator: MARKET_EVENT_GENERATOR
			-- The left and right generators to be contained by the new CEG
			xxxx

feature -- Status setting

	set_generators (left, right: MARKET_EVENT_GENERATOR) is
			-- Set left and right generators to `left' and `right'.
		require
			not_void: left /= Void and right /= Void
		do
			left_generator := left
			right_generator := right
		ensure
			set: left_generator = left and right_generator = right
		end

feature -- Basic operations

	execute is
		do
			!!product.make (left_generator, right_generator, event_type)
		end

end -- COMPOUND_GENERATOR_FACTORY
