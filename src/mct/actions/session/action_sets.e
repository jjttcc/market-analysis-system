indexing
	description: "All ACTION_SETs used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class

    ACTION_SETS

feature -- Access

	start_session_set: ACTION_SET is
			-- ACTION_SET for starting a MAS session
		require
			actions_set: actions /= Void
		once
			create Result.make ("Start a MAS session", start_session_token,
				<<agent actions.start_charting_app>>)
		end

	connect_to_session_set: ACTION_SET is
			-- ACTION_SET for connecting to a MAS session
		require
			actions_set: actions /= Void
		once
			create Result.make ("Connect to a running MAS session",
				connect_to_session_token, <<agent actions.connect_to_session>>)
		end

	terminate_session_set: ACTION_SET is
			-- ACTION_SET for terminating a MAS session
		require
			actions_set: actions /= Void
		once
			create Result.make ("Terminate a MAS session",
				terminate_session_token, <<agent actions.terminate_session>>)
		end

	close_window_set: ACTION_SET is
			-- ACTION_SET for closing an application window
		require
			actions_set: actions /= Void
		once
			create Result.make ("Close", close_window_token,
				<<agent actions.close_window>>)
		end

feature -- Access

	actions: ACTIONS

feature -- Element change

	set_actions (arg: ACTIONS) is
			-- Set `actions' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			actions := arg
		ensure
			actions_set: actions = arg and actions /= Void
		end

feature -- Constants

	start_session_token: STRING is "start-session"
			-- Token for the actions to start a MAS session

	connect_to_session_token: STRING is "connect-to-session"
			-- Token for the actions to connect to a MAS session

	terminate_session_token: STRING is "terminate-session"
			-- Token for the actions to terminate a MAS session

	close_window_token: STRING is "close-window"
			-- Token for the actions to close an application window

end
