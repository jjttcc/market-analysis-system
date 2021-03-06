note
	description: "A tradable event factory that makes a TRADABLE_EVENT_PAIR"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EVENT_PAIR_FACTORY inherit

	TRADABLE_EVENT_FACTORY
		redefine
			product
		end

creation

	make

feature -- Initialization

	make (infile: like input; p: like parser;
			fsep: like field_separator)
		require
			not_void: infile /= Void and p /= Void
		do
			input := infile
			parser := p
			field_separator := fsep
		ensure
			set: input = infile and parser = p and field_separator = fsep
		end

feature -- Access

	parser: TRADABLE_EVENT_PARSER
			-- Parser used to create the appropriate event type according
			-- to the input

	product: TRADABLE_EVENT_PAIR

feature -- Basic operations

	execute
			-- Scan input and create an TRADABLE_EVENT_PAIR from it.
			-- If a fatal error is encountered while scanning, an exception
			-- is thrown and error_occurred is set to True.
		local
			left, right: TRADABLE_EVENT
			st: SIGNAL_TYPES
		do
			create st.initialize_signal_type
			error_init
			scan_event_type
			skip_field_separator
			left := next_event
			skip_field_separator
			right := next_event
			create product.make (left, right, concatenation (<<left.name, ", ",
				right.name>>), current_event_type, st.Buy_signal)
		end

	next_event: TRADABLE_EVENT
		do
			-- Execute parser to make the appropriate kind of factory
			-- according to the type spec. in the input.
			parser.execute
			-- Execute the factory created by executing parser.
			parser.product.execute
			-- Add the factory product to the product list.
			Result := parser.product.product
		rescue
			error_occurred := True
			if parser.error_occurred then
				last_error := parser.last_error
			elseif parser.product.error_occurred then
				last_error := parser.product.last_error
			end
			raise (last_error)
		end

end -- class EVENT_PAIR_FACTORY
