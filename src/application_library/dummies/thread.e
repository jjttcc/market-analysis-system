note
	description:
		"Dummy/fake thread class - For non-multi-threaded version"
	author: "Jim Cochrane"
	date: "$Date: 2006-04-09 16:12:50 -0600 (Sun, 09 Apr 2006) $";
	revision: "$Revision: 4345 $"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class THREAD inherit

feature

	launch
		do
			execute
		end

	execute
		deferred
		end

end
