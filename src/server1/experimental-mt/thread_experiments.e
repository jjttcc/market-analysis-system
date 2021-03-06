note
	description: "Manager of multi-threading experiments"
		"Dummy thread class - stand-in until threads are actually used"
	author: "Jim Cochrane"
	date: "$Date: 2006-04-04 19:10:39 -0600 (Tue, 04 Apr 2006) $";
	revision: "$Revision: 4327 $"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class THREAD_EXPERIMENTS inherit

create

	make

feature

	make (run_test: BOOLEAN)
		do
			if run_test then
				create thread
				print ("launching thread" + "%N")
				thread.launch
				print ("after launch" + "%N")
--				thread.sleep (1500000000)
--				thread.join
--				print ("after join" + "%N")
			end
		end

feature {NONE} -- Implementation

	thread: THREAD_CHILD_1

end
