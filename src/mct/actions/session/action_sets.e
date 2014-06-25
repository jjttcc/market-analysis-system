note
	description: "All ACTION_SETs used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

    ACTION_SETS

feature -- Access

	start_session_set: ACTION_SET
			-- ACTION_SET for starting a MAS session
		require
			actions_set: main_actions /= Void
		do
			create Result.make ("Start a MAS session", start_session_token,
				<<agent main_actions.start_server>>)
		ensure
			result_exists: Result /= Void
		end

	start_chart_set: ACTION_SET
			-- ACTION_SET for starting a MAS charting application
		require
			actions_set: mas_session_actions /= Void
		do
			create Result.make ("Start charts", start_session_token,
				<<agent mas_session_actions.start_charting_app>>)
		ensure
			result_exists: Result /= Void
		end

	start_command_line_set: ACTION_SET
			-- ACTION_SET for starting a MAS command_line
		require
			actions_set: mas_session_actions /= Void
		do
			create Result.make ("Start command-line client",
				start_session_token,
				<<agent mas_session_actions.start_command_line>>)
		ensure
			result_exists: Result /= Void
		end

	connect_to_session_set: ACTION_SET
			-- ACTION_SET for connecting to a MAS session
		require
			actions_set: main_actions /= Void
		do
			create Result.make ("Connect to a running MAS session",
				connect_to_session_token,
				<<agent main_actions.connect_to_session>>)
		ensure
			result_exists: Result /= Void
		end

	terminate_session_set: ACTION_SET
			-- ACTION_SET for terminating a MAS session
		require
			actions_set: mas_session_actions /= Void
		do
			create Result.make ("Terminate session",
				terminate_session_token,
				<<agent mas_session_actions.terminate_session,
				agent mas_session_actions.close_window>>)
		ensure
			result_exists: Result /= Void
		end

	terminate_arbitrary_session_set: ACTION_SET
			-- ACTION_SET for terminating an arbitrary MAS session
		require
			actions_set: main_actions /= Void
		do
			create Result.make ("Terminate a MAS session",
				terminate_arbitrary_session_token,
					<<agent main_actions.terminate_arbitrary_session>>)
		ensure
			result_exists: Result /= Void
		end

	close_window_set: ACTION_SET
			-- ACTION_SET for closing an application window
		require
			actions_set: main_actions /= Void or mas_session_actions /= Void
		local
			actions: ACTIONS
		do
			actions := main_actions
			if actions = Void then
				actions := mas_session_actions
			end
			create Result.make ("Close", close_window_token,
				<<agent actions.close_window>>)
		ensure
			result_exists: Result /= Void
		end

	exit_set: ACTION_SET
			-- ACTION_SET for terminating all sessions and exiting
			-- the application
		require
			actions_set: main_actions /= Void
		do
			create Result.make ("Quit", exit_token,
				<<agent main_actions.exit>>)
		ensure
			result_exists: Result /= Void
		end

feature -- Access

	main_actions: MAIN_ACTIONS

	mas_session_actions: MAS_SESSION_ACTIONS

feature -- Element change

	set_main_actions (arg: MAIN_ACTIONS)
			-- Set `main_actions' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			main_actions := arg
		ensure
			main_actions_set: main_actions = arg and main_actions /= Void
		end

	set_mas_session_actions (arg: MAS_SESSION_ACTIONS)
			-- Set `mas_session_actions' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			mas_session_actions := arg
		ensure
			mas_session_actions_set: mas_session_actions = arg and
				mas_session_actions /= Void
		end

feature -- Constants

	Start_session_token: STRING = "start-session"
			-- Token for the actions to start a MAS session

	Connect_to_session_token: STRING = "connect-to-session"
			-- Token for the actions to connect to a MAS session

	Terminate_session_token: STRING = "terminate-session"
			-- Token for the actions to terminate a MAS session

	Terminate_arbitrary_session_token: STRING = "terminate-arbitrary-session"
			-- Token for the actions to terminate an arbitrary MAS session

	Close_window_token: STRING = "close-window"
			-- Token for the actions to close an application window

	Exit_token: STRING = "exit"
			-- Token for the actions to close an application window

end
