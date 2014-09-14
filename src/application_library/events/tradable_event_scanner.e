note
	description: "DATA_SCANNER that scans TRADABLE_EVENT fields"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_EVENT_SCANNER inherit

	DATA_SCANNER [TRADABLE_EVENT]
		rename
			make as data_scanner_make, tuple_maker as parser,
			tuple_maker_execute as parser_execute, tuple_maker_product as
			parser_product
		export {NONE}
			data_scanner_make
		redefine
			product, make_tuple, advance_to_next_record, input,
			value_setters_used, parser
		end

	EXCEPTIONS
		export
			{NONE} all
		end

creation

	make

feature

	make (in: like input)
		require
			args_not_void: in /= Void
			in_separators_not_void:
				in.field_separator /= Void and in.record_separator /= Void
		do
			create {TRADABLE_EVENT_PARSER} parser.make (in)
			input := in
			parser.set_field_separator (in.field_separator @ 1)
		ensure
			set: input = in and parser.input = input
		end

feature -- Access

	product: LINKED_LIST [TRADABLE_EVENT]

	input: INPUT_FILE

	parser: TRADABLE_EVENT_PARSER

	product_count: INTEGER do Result := product.count end

feature {NONE} -- Hook method implementations

	create_product
		do
			create {LINKED_LIST [TRADABLE_EVENT]} product.make
		end

	make_tuple
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

	advance_to_next_record
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

	value_setters_used: BOOLEAN = False

feature {NONE} -- Implementation

	Field_count: INTEGER = 4

feature -- Inapplicable

	parser_execute
		do
		end

	parser_product: TRADABLE_EVENT
		do
		end

end -- class TRADABLE_EVENT_SCANNER
