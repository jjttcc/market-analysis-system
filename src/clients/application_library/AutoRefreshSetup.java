package application_library;

import java.util.Timer;

// Facilities for setting up the auto-data-refresh feature
public class AutoRefreshSetup {

// Initialization

	// Postcondition: data_request_client() == client
	public AutoRefreshSetup(TimeDelimitedDataRequestClient client) {

		data_request_client = client;
	}

// Access

	// The client to be scheduled for data refresh actions
	TimeDelimitedDataRequestClient data_request_client() {
		return data_request_client;
	}

// Basic operations

	// Unschedule `data_request_client' for data refresh actions
	public void unschedule() {
		timer.cancel();
		timer = null;
	}

	// Schedule `data_request_client' for data refresh actions - ignored
	// if `data_request_client' is already scheduled.
	public void schedule() {
		if (timer == null) {
			timer = new Timer(true);
			TimeDelimitedDataRequest timer_task =
				new TimeDelimitedDataRequest(data_request_client);
			timer.scheduleAtFixedRate(timer_task, refresh_delay, refresh_delay);
System.out.println("scheduled " + timer_task + " with delay: " +
refresh_delay);
		}
	}

// Implementation

	private TimeDelimitedDataRequestClient data_request_client;

	// Timer, shared by all data-refresh clients
	private Timer timer;

	// Timer delay in milliseconds (!!!Make configurable.)
	private static long refresh_delay = 100 * 60;
//private static long refresh_delay = 1000 * 60;
}
