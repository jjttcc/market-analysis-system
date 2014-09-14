note
	description:
		"Factory class that manufactures COMPOUND_EVENT_GENERATORs"
	note1: "Features left_generator, right_generator, and event_type should %
		%all be non-Void when execute is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMPOUND_GENERATOR_FACTORY inherit

	EVENT_GENERATOR_FACTORY
		rename
			initialize_signal_type as make
		redefine
			product
		end

creation

	make

feature -- Access

	product: COMPOUND_EVENT_GENERATOR

	left_generator, right_generator: TRADABLE_EVENT_GENERATOR
			-- The left and right generators to be contained by the new CEG

	left_target_type: EVENT_TYPE
			-- The event type to assign to the new CEG's left_target_type

	before_extension, after_extension: DATE_TIME_DURATION
			-- The values for the new CEG's before and after extensions

feature -- Status setting

	set_generators (left, right: TRADABLE_EVENT_GENERATOR)
			-- Set left and right generators to `left' and `right'.
		require
			not_void: left /= Void and right /= Void
		do
			left_generator := left
			right_generator := right
		ensure
			set: left_generator = left and right_generator = right
		end

	set_left_target_type (arg: EVENT_TYPE)
			-- Set left_target_type to `arg'.
		do
			left_target_type := arg
		ensure
			left_target_type_set: left_target_type = arg
		end

	set_before_extension (arg: DATE_TIME_DURATION)
			-- Set before_extension to `arg'.
		do
			before_extension := arg
		ensure
			before_extension_set: before_extension = arg
		end

	set_after_extension (arg: DATE_TIME_DURATION)
			-- Set after_extension to `arg'.
		do
			after_extension := arg
		ensure
			after_extension_set: after_extension = arg
		end

feature -- Basic operations

	execute
		do
			create product.make (left_generator, right_generator, event_type,
				signal_type)
			if before_extension /= Void then
				product.set_before_extension (before_extension)
			end
			if after_extension /= Void then
				product.set_after_extension (after_extension)
			end
			if left_target_type /= Void then
				product.set_left_target_type (left_target_type)
			end
		end

end -- COMPOUND_GENERATOR_FACTORY
