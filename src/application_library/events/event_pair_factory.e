indexing
	description: ""
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_PAIR_FACTORY inherit

	MARKET_EVENT_FACTORY
		redefine
			product
		end

creation

	make

feature -- Initialization

	make (infile: like input_file; p: like parser;
			fsep: like field_separator) is
		require
			not_void: infile /= Void and p /= Void
		do
			input_file := infile
			parser := p
			field_separator := fsep
		ensure
			set: input_file = infile and parser = p and field_separator = fsep
		end

feature -- Access

	input_file: FILE
			-- File containing input data from which to create MARKET_EVENTs

	parser: MARKET_EVENT_PARSER
			-- Parser used to create the appropriate event type according
			-- to the input

	product: MARKET_EVENT_PAIR

feature -- Basic operations

	execute is
			-- Scan input_file and create an MARKET_EVENT_PAIR from it.
			-- If a fatal error is encountered while scanning, an exception
			-- is thrown and error_occurred is set to true.
		local
			left, right: MARKET_EVENT
		do
			error_init
			scan_event_type
			skip_field_separator
			left := next_event
			skip_field_separator
			right := next_event
			!!product.make (left, right, "What name goes here?",
							current_event_type)
		end

	next_event: MARKET_EVENT is
		do
			-- Execute parser to make the appropriate kind of factory
			-- according to the type spec. in the input.
			parser.execute
			-- Execute the factory created by executing parser.
			parser.product.execute
			-- Add the factory product to the product list.
			Result := parser.product.product
		rescue
			error_occurred := true
			if parser.error_occurred then
				last_error := parser.last_error
			elseif parser.product.error_occurred then
				last_error := parser.product.last_error
			end
			raise (last_error)
		end

end -- class EVENT_PAIR_FACTORY
