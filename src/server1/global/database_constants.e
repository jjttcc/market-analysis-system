indexing
	description: "Global constant values used by the database layer"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	DATABASE_CONSTANTS

feature -- Access

	Data_source_specifier: STRING is "data_source_name"

	User_id_specifier: STRING is "user id"

	Password_specifier: STRING is "password"

	Stock_symbol_query_specifier: STRING is "stock symbol query"

	Stock_split_query_specifier: STRING is "stock split query"

	Stock_name_query_specifier: STRING is "stock name query"

	Daily_stock_symbol_field_specifier: STRING is "daily stock symbol field"

	Daily_stock_date_field_specifier: STRING is "daily stock date field"

	Daily_stock_open_field_specifier: STRING is "daily stock open field"

	Daily_stock_high_field_specifier: STRING is "daily stock high field"

	Daily_stock_low_field_specifier: STRING is "daily stock low field"

	Daily_stock_close_field_specifier: STRING is "daily stock close field"

	Daily_stock_volume_field_specifier: STRING is "daily stock volume field"

	Intraday_stock_symbol_field_specifier: STRING is
		"intraday stock symbol field"

	Intraday_stock_date_field_specifier: STRING is "intraday stock date field"

	Intraday_stock_time_field_specifier: STRING is "intraday stock time field"

	Intraday_stock_open_field_specifier: STRING is "intraday stock open field"

	Intraday_stock_high_field_specifier: STRING is "intraday stock high field"

	Intraday_stock_low_field_specifier: STRING is "intraday stock low field"

	Intraday_stock_close_field_specifier: STRING is "intraday stock close field"

	Intraday_stock_volume_field_specifier: STRING is
		"intraday stock volume field"

	Daily_stock_table_specifier: STRING is "daily stock table"

	Intraday_stock_table_specifier: STRING is "intraday stock table"

	Daily_stock_query_tail_specifier: STRING is "daily stock query tail"

	Intraday_stock_query_tail_specifier: STRING is "intraday stock query tail"

	Derivative_symbol_query_specifier: STRING is "derivative symbol query"

	Derivative_split_query_specifier: STRING is "derivative split query"

	Derivative_name_query_specifier: STRING is "derivative name query"

	Daily_derivative_symbol_field_specifier: STRING is
		"daily derivative symbol field"

	Daily_derivative_date_field_specifier: STRING is
		"daily derivative date field"

	Daily_derivative_open_field_specifier: STRING is
		"daily derivative open field"

	Daily_derivative_high_field_specifier: STRING is
		"daily derivative high field"

	Daily_derivative_low_field_specifier: STRING is
		"daily derivative low field"

	Daily_derivative_close_field_specifier: STRING is
		"daily derivative close field"

	Daily_derivative_volume_field_specifier: STRING is
		"daily derivative volume field"

	Daily_derivative_open_interest_field_specifier: STRING is
		"daily derivative open_interest field"

	Intraday_derivative_symbol_field_specifier: STRING is
		"intraday derivative symbol field"

	Intraday_derivative_date_field_specifier: STRING is
		"intraday derivative date field"

	Intraday_derivative_time_field_specifier: STRING is
		"intraday derivative time field"

	Intraday_derivative_open_field_specifier: STRING is
		"intraday derivative open field"

	Intraday_derivative_high_field_specifier: STRING is
		"intraday derivative high field"

	Intraday_derivative_low_field_specifier: STRING is
		"intraday derivative low field"

	Intraday_derivative_close_field_specifier: STRING is
		"intraday derivative close field"

	Intraday_derivative_volume_field_specifier: STRING is
		"intraday derivative volume field"

	Intraday_derivative_open_interest_field_specifier: STRING is
		"intraday derivative open_interest field"

	Daily_derivative_table_specifier: STRING is "daily derivative table"

	Intraday_derivative_table_specifier: STRING is "intraday derivative table"

	Daily_derivative_query_tail_specifier: STRING is
		"daily derivative query tail"

	Intraday_derivative_query_tail_specifier: STRING is
		"intraday derivative query tail"

end -- DATABASE_CONSTANTS
