indexing
	description: "Global constant values used by the database layer"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	DATABASE_CONSTANTS

feature -- Access

	Data_source_specifier: STRING is "data_source_name"

	User_id_specifier: STRING is "user id"

	Password_specifier: STRING is "password"

	Symbol_select_specifier: STRING is "stock symbol select"

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

end -- DATABASE_CONSTANTS
