class YAHOO_HTTP_PARAMETERS inherit
--!!!Note: See if this class can be generalized - generic http parameters for
--stock/tradable data sites; or use it as the basis of a generalized class.

	HTTP_CONFIGURATION
		export
			{NONE} all
		end

create

	make

feature -- Access

	host: STRING

	main_path_component: STRING is "table.csv?s="

	symbol: STRING

	start_date: DATE

	end_date: DATE

feature -- Access

	path_date_component: STRING is
		do
			Result := start_date_month_prefix + start_date.month.out +
			start_date_day_prefix + start_date.day.out +
			start_date_year_prefix + start_date.year.out +
			end_date_month_prefix + end_date.month.out +
			end_date_day_prefix + end_date.day.out +
			end_date_year_prefix + end_date.year.out
		end

	path: STRING is
		do
			Result := main_path_component + symbol + path_date_component +
				other_path_components + symbol_prefix + symbol + path_suffix
--&a=01&b=01&c=1996&d=07&e=10&f=2002&g=d&q=q&y=0&z=rhat&x=.csv
		end

feature -- Element change

	set_host (arg: STRING) is
			-- Set `host' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			host := arg
		ensure
			host_set: host = arg and host /= Void
		end

	set_symbol (arg: STRING) is
			-- Set `symbol' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_start_date (arg: DATE) is
			-- Set `start_date' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			start_date := arg
		ensure
			start_date_set: start_date = arg and start_date /= Void
		end

	set_end_date (arg: DATE) is
			-- Set `end_date' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			end_date := arg
		ensure
			end_date_set: end_date = arg and end_date /= Void
		end

	set_end_date_to_now is
			-- Set `end_date' to the current date.
		do
			create end_date.make_now
		end

feature {NONE} -- Implementation

	start_date_month_prefix: STRING is "&a="

	start_date_day_prefix: STRING is "&b="

	start_date_year_prefix: STRING is "&c="

	end_date_month_prefix: STRING is "&d="

	end_date_day_prefix: STRING is "&e="

	end_date_year_prefix: STRING is "&f="

	other_path_components: STRING is "&g=d&q=q&y=0"

	symbol_prefix: STRING is "&z="

	path_suffix: STRING is "&x=.csv"

end
