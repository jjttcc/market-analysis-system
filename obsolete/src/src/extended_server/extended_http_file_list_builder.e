note
	description: "Builder of HTTP_LOADING_FILE_TRADABLE_LISTs used by MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

-- !!!OBSOLETE - mv to obsolete directory.
class EXTENDED_HTTP_FILE_LIST_BUILDER inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

	LIST_BUILDER

creation

	make

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

	daily_list: EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST

	intraday_list: EXTENDED_HTTP_LOADING_FILE_TRADABLE_LIST

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
			create daily_list.make (tradable_factory, daily_extension)
			if use_intraday then
				check
					intraday: intraday_tradable_factory.intraday
				end
				create intraday_list.make (intraday_tradable_factory,
					intraday_extension)
			end
		end

invariant

end
