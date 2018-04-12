note
    description: "Builder of FILE_TRADABLE_LISTs"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class FILE_LIST_BUILDER inherit

    FILE_LIST_BUILDER_FACILITIES
        redefine
            new_tradable_list
        end

creation

    make

feature -- Access

    new_tradable_list (fnames: DYNAMIC_LIST [STRING];
                factory: TRADABLE_FACTORY):
            EXTENDED_FILE_TRADABLE_LIST
        do
            create Result.make (fnames, factory)
        end

end
