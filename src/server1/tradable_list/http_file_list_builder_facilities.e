indexing
	description: "Facilities for building HTTP_LOADING_FILE_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class HTTP_FILE_LIST_BUILDER_FACILITIES inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

	LIST_BUILDER

feature -- Initialization

	make (factory: TRADABLE_FACTORY; daily_ext, intra_ext: STRING) is
			-- Initialize file-name lists and tradable factories.  A separate
			-- tradable factory for intraday data is used for efficiency.
			-- If `daily_ext' and `intra_ext' are both void, initialization
			-- is performed for daily data only.
		require
			not_void: factory /= Void
		do
			intraday_extension := intra_ext
			daily_extension := daily_ext
			make_factories (factory)
		ensure
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
		end

feature -- Access

	daily_list: HTTP_LOADING_FILE_TRADABLE_LIST

	intraday_list: HTTP_LOADING_FILE_TRADABLE_LIST

	intraday_extension: STRING
			-- File-name extension for intraday-data files

	daily_extension: STRING
			-- File-name extension for daily-data files

feature -- Status report

	use_intraday: BOOLEAN
			-- Is intraday data to be used, in addition to daily data?

feature -- Basic operations

	execute is
		require
			input_items_set: tradable_factory /= Void
		do
			daily_list := new_tradable_list (tradable_factory, daily_extension)
			if use_intraday then
				check
					intraday: intraday_tradable_factory.intraday
				end
				intraday_list := new_tradable_list (intraday_tradable_factory,
					intraday_extension)
			end
		end

feature {NONE} -- Implementation

	new_tradable_list (factory: TRADABLE_FACTORY; extension: STRING):
		HTTP_LOADING_FILE_TRADABLE_LIST is
			-- A new HTTP_LOADING_FILE_TRADABLE_LIST
		do
			create Result.make (factory, extension)
		end

end
