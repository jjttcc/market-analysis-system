note
	description: "Miscellaneous information about a tradable";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class TRADABLE_DATA

feature -- Access

	symbol: STRING

	name: STRING
			-- Name of stock associated with `symbol'
		deferred
		end

	description: STRING
			-- Description of stock associated with `symbol'
		deferred
		end

feature -- Status setting

	set_symbol (arg: STRING)
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

end -- class TRADABLE_DATA
