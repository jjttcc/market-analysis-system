indexing
	description: "Facilities for reading and tokenizing a text file"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_FILE_READER inherit

creation
	make

feature

	make (file_name: STRING) is
		require
			file_name /= Void
		do
			create pf.make (file_name)
		end

feature

	exhausted: BOOLEAN
			-- Has structure been completely explored?

	item: STRING
			-- Current tokenized field

	contents: STRING is
			-- Contents of the entire file
		do
			if file_contents = Void then
				if pf.exists then
					pf.open_read
					pf.read_stream (pf.count)
					file_contents := clone (pf.last_string)
				end
			end
			Result := clone (file_contents)
		end

	forth is
			-- Move to next field; if no next field,
			-- ensure that exhausted will be true.
		do
			tokens.forth
			if not tokens.exhausted then
				item := tokens.item
			else
				exhausted := true
				item := Void
			end
		ensure
			item_void_if_exhausted: exhausted implies item = Void
		end

	tokenize (field_separator: STRING) is
			-- Tokenize based on field_separator.
		do
			create su.make (contents)
			tokens := su.tokens (field_separator)
			tokens.start
			item := tokens.item
		end

feature {NONE}

	pf: PLAIN_TEXT_FILE

	su: STRING_UTILITIES

	tokens: LIST[STRING]

	file_contents: STRING

end
