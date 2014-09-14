note
	description: "A single-value tuple."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SIMPLE_TUPLE inherit

	TRADABLE_TUPLE
		redefine
			end_date
		end

creation

	make

feature -- Initialization

	make (d: DATE_TIME; end_dt: DATE; v: DOUBLE)
		do
			date_time := d
			value := v
			end_date := end_dt
		ensure
			dates_set: date_time = d and end_date = end_dt
			-- value_set: dabs (value - v) < epsilon
		end

feature -- Access

	value: DOUBLE

	end_date: DATE

feature {TRADABLE_FUNCTION} -- Status setting

	set_value (v: DOUBLE)
			-- Set value to `v'.
		do
			value := v
		ensure
			-- value_set: dabs (value - v) < epsilon
		end

	set_end_date (arg: DATE)
			-- Set end_date to `arg'.
		require
			arg_not_void: arg /= Void
		do
			end_date := arg
		ensure
			end_date_set: end_date = arg and end_date /= Void
		end

end -- class SIMPLE_TUPLE
