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
			file_name /= void
	do
		!!pf.make(file_name)
	end

feature

	exhausted : BOOLEAN

	item      : STRING

	contents: STRING is
	do
		if file_contents = void then
			if pf.exists then
				pf.open_read
				pf.read_stream(pf.count)
				file_contents := clone(pf.last_string)
			end
		end
		Result:= clone(file_contents)
	end

	forth is
	do
		tokens.forth
		if not tokens.exhausted then
			item := tokens.item
		else
			exhausted := true
			item := void
		end
	end

	tokenize(field_separator: STRING) is
		-- tokenize based on field_separator
	do
		!!su.make(contents)
		tokens := su.tokens(field_separator)
		tokens.start
		item   := tokens.item
	end

feature {NONE}

	pf : PLAIN_TEXT_FILE

	su : STRING_UTILITIES
	
	tokens : LIST[STRING]

	file_contents : STRING

end
