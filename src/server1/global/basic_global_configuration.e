indexing
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	BASIC_GLOBAL_CONFIGURATION

inherit

	GLOBAL_CONFIGURATION

feature -- Access

	product_info: MAS_PRODUCT_INFO is
		do
			create Result
		end

	tradable_cache_size: INTEGER is
		once
			Result := default_tradable_cache_size
		end

feature -- Status report

	auto_data_update_on: BOOLEAN is False

end
