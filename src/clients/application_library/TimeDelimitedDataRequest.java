package application_library;

import java.util.*;
import graph_library.DataSet;

// Data requests to the server delimited by a start and an end date-time,
// supplied by a TimeDelimitedDataRequestClient
class TimeDelimitedDataRequest extends TimerTask {

// Initialization

	TimeDelimitedDataRequest(TimeDelimitedDataRequestClient the_client) {
		client = the_client;
	}

// Element change

	// Set the data-request client to `c'.
	// To disable data requests and notification, set the client to null.
	public void set_client(TimeDelimitedDataRequestClient c) {
		client = c;
	}

// Basic operations

	public void run() {
		// Avoid requesting data if the last request is still active.
		if (! requesting_data) {
			synchronized (this) {
				requesting_data = true;
				perform_data_request();
				requesting_data = false;
			}
		}
	}

// Implementation

	private void perform_data_request() {
		Iterator indicators;
		if (client != null && client.ready_for_request()) {
			TradableSpecification spec = client.specification();
			AbstractDataSetBuilder builder = client.data_builder();
			IndicatorSpecification i;
			Calendar start_date, end_date;
			try {
				start_date = client.start_date();
				end_date = client.end_date();
				if (end_date == null || end_date.equals("")) {
					// Set the end date to the current time.  Leaving it
					// empty would cause the server to interpret the end
					// date as "now" for each query in the loop below,
					// resulting in different "now" values and, possibly,
					// data sets of different sizes.
					end_date = new GregorianCalendar();
				}
				builder.send_time_delimited_market_data_request(spec.symbol(), 
					spec.period_type(), start_date, end_date);
				if (builder.request_succeeded() &&
						builder.last_market_data().size() > 0) {

					spec.main_data().append(builder.last_market_data());
					indicators = spec.selected_indicators().iterator();
					while (indicators.hasNext()) {
						i = (IndicatorSpecification) indicators.next();
						if (i.selected()) {
							DataSet data = i.data();
							builder.send_time_delimited_indicator_data_request(
								i.identifier(), spec.symbol(),
								spec.period_type(), start_date,
								end_date);
							if (builder.request_succeeded()) {
								i.data().append(builder.last_indicator_data());
							} else {
								// Throw exception? Or call notify_of_update?
							}
						}
					}
					client.update_start_date(builder);
					client.notify_of_update();
				} else {
					if (! builder.request_succeeded()) {
						client.notify_of_error(builder.request_result_id(),
							null);
					} else {
						// assert(builder.last_market_data().size() == 0);
						// assert(builder.request_succeeded());
						// Successful request with no data - No new
						// data is available from the server.
					}
				}
			} catch (Exception e) {
				client.notify_of_failure(e);
			}
		}
	}

	private TimeDelimitedDataRequestClient client;

	// Is the `run' routine currently active?
	private boolean requesting_data = false;
}
