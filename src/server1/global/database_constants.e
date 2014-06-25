note
	description: "Global constant values used by the database layer"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	DATABASE_CONSTANTS

inherit

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

feature -- Access

	Data_source_specifier: STRING = "data_source_name"

	User_id_specifier: STRING = "user id"

	Password_specifier: STRING = "password"

	Stock_symbol_query_specifier: STRING = "stock symbol query"

	Stock_split_query_specifier: STRING = "stock split query"

	Stock_name_query_specifier: STRING = "stock name query"

	Daily_stock_data_command_specifier: STRING = "daily stock data command"

	Daily_stock_symbol_field_specifier: STRING = "daily stock symbol field"

	Daily_stock_date_field_specifier: STRING = "daily stock date field"

	Daily_stock_open_field_specifier: STRING = "daily stock open field"

	Daily_stock_high_field_specifier: STRING = "daily stock high field"

	Daily_stock_low_field_specifier: STRING = "daily stock low field"

	Daily_stock_close_field_specifier: STRING = "daily stock close field"

	Daily_stock_volume_field_specifier: STRING = "daily stock volume field"

	Intraday_stock_data_command_specifier: STRING =
		"intraday stock data command"

	Intraday_stock_symbol_field_specifier: STRING =
		"intraday stock symbol field"

	Intraday_stock_date_field_specifier: STRING = "intraday stock date field"

	Intraday_stock_time_field_specifier: STRING = "intraday stock time field"

	Intraday_stock_open_field_specifier: STRING = "intraday stock open field"

	Intraday_stock_high_field_specifier: STRING = "intraday stock high field"

	Intraday_stock_low_field_specifier: STRING = "intraday stock low field"

	Intraday_stock_close_field_specifier: STRING = "intraday stock close field"

	Intraday_stock_volume_field_specifier: STRING =
		"intraday stock volume field"

	Daily_stock_table_specifier: STRING = "daily stock table"

	Intraday_stock_table_specifier: STRING = "intraday stock table"

	Daily_stock_query_tail_specifier: STRING = "daily stock query tail"

	Intraday_stock_query_tail_specifier: STRING = "intraday stock query tail"

	Derivative_symbol_query_specifier: STRING = "derivative symbol query"

	Derivative_split_query_specifier: STRING = "derivative split query"

	Derivative_name_query_specifier: STRING = "derivative name query"

	Daily_derivative_data_command_specifier: STRING =
		"daily derivative data command"

	Daily_derivative_symbol_field_specifier: STRING =
		"daily derivative symbol field"

	Daily_derivative_date_field_specifier: STRING =
		"daily derivative date field"

	Daily_derivative_open_field_specifier: STRING =
		"daily derivative open field"

	Daily_derivative_high_field_specifier: STRING =
		"daily derivative high field"

	Daily_derivative_low_field_specifier: STRING =
		"daily derivative low field"

	Daily_derivative_close_field_specifier: STRING =
		"daily derivative close field"

	Daily_derivative_volume_field_specifier: STRING =
		"daily derivative volume field"

	Daily_derivative_open_interest_field_specifier: STRING =
		"daily derivative open_interest field"

	Intraday_derivative_data_command_specifier: STRING =
		"intraday derivative data command"

	Intraday_derivative_symbol_field_specifier: STRING =
		"intraday derivative symbol field"

	Intraday_derivative_date_field_specifier: STRING =
		"intraday derivative date field"

	Intraday_derivative_time_field_specifier: STRING =
		"intraday derivative time field"

	Intraday_derivative_open_field_specifier: STRING =
		"intraday derivative open field"

	Intraday_derivative_high_field_specifier: STRING =
		"intraday derivative high field"

	Intraday_derivative_low_field_specifier: STRING =
		"intraday derivative low field"

	Intraday_derivative_close_field_specifier: STRING =
		"intraday derivative close field"

	Intraday_derivative_volume_field_specifier: STRING =
		"intraday derivative volume field"

	Intraday_derivative_open_interest_field_specifier: STRING =
		"intraday derivative open_interest field"

	Daily_derivative_table_specifier: STRING = "daily derivative table"

	Intraday_derivative_table_specifier: STRING = "intraday derivative table"

	Daily_derivative_query_tail_specifier: STRING =
		"daily derivative query tail"

	Intraday_derivative_query_tail_specifier: STRING =
		"intraday derivative query tail"

end
