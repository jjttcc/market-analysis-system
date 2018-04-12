note
	description: "Facilities for building FILE_TRADABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class FILE_LIST_BUILDER_FACILITIES inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

	LIST_BUILDER
		redefine
			descendant_build_lists_precondition
		end

feature -- Initialization

	make (file_names: DYNAMIC_LIST [STRING]; factory: TRADABLE_FACTORY;
		daily_ext, intra_ext: STRING)
			-- Initialize file-name lists and tradable factories.  A separate
			-- tradable factory for intraday data is used for efficiency.
			-- If `daily_ext' and `intra_ext' are both void, initialization
			-- is performed for daily data only.
		require
			not_void: file_names /= Void and factory /= Void
		do
			intraday_extension := intra_ext
			daily_extension := daily_ext
			if daily_ext /= Void or intra_ext /= Void then
				make_file_name_lists (file_names)
			else
				daily_file_names := file_names
			end
			make_factories (factory)
		ensure
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
			fnames_set: daily_file_names /= Void or intraday_file_names /= Void
		end

feature -- Access

	daily_list: FILE_TRADABLE_LIST

	intraday_list: FILE_TRADABLE_LIST

	daily_file_names: DYNAMIC_LIST [STRING]
			-- File names for daily data

	intraday_file_names: DYNAMIC_LIST [STRING]
			-- File names for intraday data

	intraday_extension: STRING
			-- File-name extension for intraday-data files

	daily_extension: STRING
			-- File-name extension for daily-data files

feature -- Basic operations

	build_lists
		do
			if daily_file_names /= Void then
				check
					not_intraday: not tradable_factory.intraday
				end
				daily_list := new_tradable_list (daily_file_names,
					tradable_factory)
			end
			if intraday_file_names /= Void then
				check
					intraday: intraday_tradable_factory.intraday
				end
				intraday_list := new_tradable_list (intraday_file_names,
					intraday_tradable_factory)
			end
		end

feature -- Status report

	descendant_build_lists_precondition: BOOLEAN
		do
			Result := daily_file_names /= Void or intraday_file_names /= Void
		end

feature {NONE} -- Implementation

	new_tradable_list (fnames: DYNAMIC_LIST [STRING];
				factory: TRADABLE_FACTORY):
		FILE_TRADABLE_LIST
			-- A new FILE_TRADABLE_LIST
		do
			create Result.make (fnames, factory)
		end

	make_file_name_lists (file_names: DYNAMIC_LIST [STRING])
		local
			l: PART_SORTED_TWO_WAY_LIST [STRING]
			t: HASH_TABLE [BOOLEAN, STRING]
		do
			create l.make
			create t.make (file_names.count)
			-- Use `t' to create a list of file names with no duplicates.
			from
				file_names.start
			until
				file_names.exhausted
			loop
				t.put (True, name_without_extension (file_names.item))
				file_names.forth
			end
			l.fill (t.current_keys)
			check l_sorted: l.sorted end
			if daily_extension /= Void then
				create {ARRAYED_LIST [STRING]} daily_file_names.make (l.count)
			end
			if intraday_extension /= Void then
				create {ARRAYED_LIST [STRING]} intraday_file_names.make (
					l.count)
			end
			from
				l.start
			until
				l.exhausted
			loop
				if daily_extension /= Void then
					daily_file_names.extend (concatenation (<<l.item, ".",
						daily_extension>>))
				end
				if intraday_extension /= Void then
					intraday_file_names.extend (concatenation (<<l.item, ".",
						intraday_extension>>))
				end
				l.forth
			end
		end

	name_without_extension (fname: STRING): STRING
			-- `fname' without its extension ('.' and all characters that
			-- follow it)
		do
			strutil.set_target (fname.twin)
			if strutil.target.has ('.') then
				strutil.keep_head ('.')
			end
			Result := strutil.target
		end

	strutil: expanded STRING_UTILITIES

invariant

	same_counts:
		daily_file_names /= Void and intraday_file_names /= Void implies
		daily_file_names.count = intraday_file_names.count

end
