indexing
	description:
		"An iterable list of tradables"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_LIST inherit

	LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]

feature -- Access

	file_names: LINEAR [STRING] is
			-- Names of tradable data files
		deferred
		end

	search_by_file_name (name: STRING) is
			-- Tradable whose associated file name matches `name'.
		deferred
		ensure
			index_match: file_names.index = index
		end

end -- class TRADABLE_LIST
