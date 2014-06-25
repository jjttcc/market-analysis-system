note
	description: "Commands with a settable 'is_editable' feature"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class CONFIGURABLE_EDITABLE_COMMAND

feature -- Status report

	is_editable: BOOLEAN
			-- Is Current editable?

feature -- Status setting

	set_is_editable (arg: BOOLEAN)
			-- Set `is_editable' to `arg'.
		do
			is_editable := arg
		ensure
			is_editable_set: is_editable = arg
		end

end
