indexing
	description: "Date setter that uses daily data";
	date: "$Date$";
	revision: "$Revision$"

class DAY_DATE_SETTER inherit

	VALUE_SETTER

creation

	make

feature -- Initialization

	make is
		do
			!!date.make_now
		end

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: MARKET_TUPLE) is
			-- Expected format for date:  yyyymmdd
			-- Redefine in descendant for different formats.
		local
			date_time: DATE_TIME
			y, m, d, value: INTEGER
		do
			-- Tuples must always have a date.
			check not is_dummy end
			stream.read_integer
			value := stream.last_integer
			y := value // 10000
			m := value \\ 10000 // 100
			d := value \\ 100
			if
				y < 0 or m < 1 or m > date.months_in_year or
				d < 1 or d > date.days_in_i_th_month (m, y)
			then
				!!last_error.make (128)
				last_error.append ("Date input value is invalid: ")
				last_error.append (value.out)
				!!date_time.make_now -- !!!What date to use?
				tuple.set_date_time (date_time)
				error_occurred := true
				--!!!Should the data scanning be aborted?
				--!!!Perhaps need a fatal error category, of which
				--!!!this would be one.
			else
				--!!!When the flyweight pattern is implemented for dates,
				--!!!will need to reference the global date (probably a
				--!!!singleton) that matches this one instead of making
				--!!!a new date.
				!!date_time.make (y, m, d, 0, 0, 0)
				tuple.set_date_time (date_time)
			end
		end

feature {NONE}

	date: DATE
			-- Used for validation checking on input.

end -- class DAY_DATE_SETTER
