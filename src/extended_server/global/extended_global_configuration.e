note
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	EXTENDED_GLOBAL_CONFIGURATION

inherit

	GLOBAL_CONFIGURATION

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	product_info: EXTENDED_PRODUCT_INFO
		do
			create Result
		end

	tradable_cache_size: INTEGER
		note
			once_status: global
		local
			value: STRING
		once
			value := get (tradable_cache_size_variable)
			if value /= Void and then value.is_integer then
				Result := value.to_integer
			end
			if Result < 1 then
				Result := default_tradable_cache_size
			end
		end

feature -- Status report

	auto_data_update_on: BOOLEAN = True

feature {NONE} -- Implementation

	tradable_cache_size_variable: STRING = "MAS_TRADABLE_CACHE_SIZE"
			-- Name of environment variable for the tradable_cache_size
			-- setting

end
