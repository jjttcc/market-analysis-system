indexing
	description: "DATA_SCANNER that scans MARKET_EVENT fields"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_EVENT_SCANNER inherit

	DATA_SCANNER
		rename
			make as data_scanner_make, tuple_maker as parser
		export {NONE}
			data_scanner_make
		redefine
			product, parser, make_tuple, advance_to_next_record, input
		end

	EXCEPTIONS

creation

	make

feature

	make (in: like input) is
		require
			args_not_void: in /= Void
			in_separators_not_void:
				in.field_separator /= Void and in.record_separator /= Void
		local
			dummy_value_setter: VALUE_SETTER
			vs: LINKED_LIST [VALUE_SETTER]
		do
			-- A dummy value setter is created and added to vs to
			-- satisfy the class invariant that `value_setters' is not
			-- empty, which will be true after the call to data_scanner_make.
			create {VOLUME_SETTER} dummy_value_setter.make
			create vs.make
			vs.extend (dummy_value_setter)
			create parser.make (in)
			data_scanner_make (in, parser, vs)
			parser.set_field_separator (in.field_separator @ 1)
		ensure
			set: input = in and parser.input = input
		end

feature -- Access

	product: LINKED_LIST [MARKET_EVENT]

	parser: MARKET_EVENT_PARSER

	input: INPUT_FILE

feature {NONE} -- Hook method implementations

	create_product is
		do
			create {LINKED_LIST [MARKET_EVENT]} product.make
		end

	make_tuple is
		local
			exception_raised: BOOLEAN
		do
			if exception_raised then
				error_in_current_tuple := True
				if parser.error_occurred then
					error_list.extend (parser.last_error)
				elseif parser.product.error_occurred then
					error_list.extend (parser.product.last_error)
				end
			else
				error_in_current_tuple := False
				-- Execute parser to make the appropriate kind of factory
				-- according to the type spec. in the input.
				parser.execute
				-- Execute the factory created by executing parser.
				parser.product.execute
				-- Add the factory product to the product list.
				product.extend (parser.product.product)
			end
		rescue
			exception_raised := True
			retry
		end

	advance_to_next_record is
		local
			i: INTEGER
		do
			from
				i := 1
			variant
				input.record_separator.count + 1 - i
			until
				i > input.record_separator.count
			loop
				input.read_character
				if
					input.last_character /= input.record_separator @ i
				then
					error_list.extend (
							"Incorrect record separator detected.")
				end
				i := i + 1
			end
			input.read_character
			if not input.after then
				input.back
			end
		end

end -- class MARKET_EVENT_SCANNER
