package application_library;

import java.util.Timer;

// Facilities for setting up the auto-data-refresh feature
public class AutoRefreshSetup {

// Initialization

	// Postcondition: data_request_client() == client &&
	//    refresh_delay == delay * 1000;
	public AutoRefreshSetup(TimeDelimitedDataRequestClient client, int delay) {

System.out.println("ARS");
		data_request_client = client;
		refresh_delay = delay * 1000;
System.out.println("ref delay: " + refresh_delay);
	}

// Access

	// The client to be scheduled for data refresh actions
	public TimeDelimitedDataRequestClient data_request_client() {
		return data_request_client;
	}

	public long refresh_delay() {
		return refresh_delay;
	}

// Basic operations

	// Unschedule `data_request_client' for data refresh actions
	public void unschedule() {
		if (timer != null) {
			timer.cancel();
			timer = null;
		}
	}

	// Schedule `data_request_client' for data refresh actions - ignored
	// if `data_request_client' is already scheduled.
	public void schedule() {
		if (timer == null) {
			timer = new Timer(true);
			TimeDelimitedDataRequest timer_task =
				new TimeDelimitedDataRequest(data_request_client);
			if (refresh_delay >= minimum_refresh_delay) {
				timer.scheduleAtFixedRate(timer_task, refresh_delay,
					refresh_delay);
System.out.println("scheduling timer for delay of " + refresh_delay);
			} else {
				timer.scheduleAtFixedRate(timer_task, default_refresh_delay,
					default_refresh_delay);
				System.err.println(default_schedule_msg);
System.out.println("scheduling timer for DEFAULT delay of " + default_refresh_delay);
			}
		}
	}

// Implementation

	private TimeDelimitedDataRequestClient data_request_client;

	// Timer, shared by all data-refresh clients
	private Timer timer;

	// Timer delay in milliseconds (@@Make configurable - check with Orest.)
	private long refresh_delay = 0;
	private static long default_refresh_delay = 1000 * 60;
//	private static long minimum_refresh_delay = 1000 * 10;
private static long minimum_refresh_delay = 100 * 9;
	private static String default_schedule_msg = "auto-refresh delay " +
		"setting is smaller than the minimum allowed value\n(" +
		minimum_refresh_delay / 1000 + " seconds) - scheduling timer for " +
		"DEFAULT delay of " + default_refresh_delay / 1000 + " seconds";
//private static long refresh_delay = 1000 * 60;
}
