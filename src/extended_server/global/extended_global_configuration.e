indexing
	description: "General, global application configuration settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class

	EXTENDED_GLOBAL_CONFIGURATION

inherit

	GLOBAL_CONFIGURATION

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	product_info: EXTENDED_PRODUCT_INFO is
		do
			create Result
		end

	tradable_cache_size: INTEGER is
		indexing
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

	auto_data_update_on: BOOLEAN is True

feature {NONE} -- Implementation

	tradable_cache_size_variable: STRING is "MAS_TRADABLE_CACHE_SIZE"
			-- Name of environment variable for the tradable_cache_size
			-- setting

end
