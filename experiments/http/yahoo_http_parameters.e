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
