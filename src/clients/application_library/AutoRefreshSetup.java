package application_library;

import java.util.Timer;

// Facilities for setting up the auto-data-refresh feature
public class AutoRefreshSetup {
	public static void execute(
			TimeDelimitedDataRequestClient data_request_client) {

		TimeDelimitedDataRequest timer_task = new TimeDelimitedDataRequest(
			data_request_client);
		timer.scheduleAtFixedRate(timer_task, refresh_delay, refresh_delay);
	}

	// Timer, shared by all data-refresh clients
	private static Timer timer = new Timer(true);

	// Timer delay in milliseconds (!!!Make configurable.)
	private static long refresh_delay = 1000 * 60;
}
