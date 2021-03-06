package application_library;

import java.util.*;
import common.*;
import graph_library.DataSet;

/**
* Data requests to the server delimited by a start and an end date-time,
* supplied by a TimeDelimitedDataRequestClient
**/
class TimeDelimitedDataRequest extends TimerTask {

// Initialization

	TimeDelimitedDataRequest(TimeDelimitedDataRequestClient the_client) {
		client = the_client;
	}

// Element change

	/**
	* Set the data-request client to `c'.
	* To disable data requests and notification, set the client to null.
	**/
	public void set_client(TimeDelimitedDataRequestClient c) {
		client = c;
	}

// Basic operations

	public void run() {
		// Avoid requesting data if the last request is still active.
		if (client != null && ! requesting_data && client.ready_for_request()) {
			AbstractDataSetBuilder builder = client.data_builder();
			// Try to lock the 'builder' only once.  If it fails, abandon
			// the data update - wait until next time.
			builder.lock(this);
			if (builder.is_locked_by(this)) {
				requesting_data = true;
				ChartableSpecification chartspec = client.specification();
				Iterator tradable_specs =
					chartspec.tradable_specifications().iterator();
				while (tradable_specs.hasNext()) {
					perform_data_request((TradableSpecification)
						tradable_specs.next(), chartspec.period_type(),
						builder);
				}
				requesting_data = false;
			}
		}
	}

// Implementation

	private void perform_data_request(TradableSpecification spec,
			String period_type, AbstractDataSetBuilder builder) {

		Iterator indicators;
		IndicatorSpecification ispec;
		Calendar start_date, end_date;
		assert client != null && builder.is_locked_by(this);
		try {
			start_date = client.start_date();
			end_date = client.end_date();
			builder.send_time_delimited_market_data_request(
				spec.symbol(), period_type, start_date, end_date);
			if (builder.request_succeeded() &&
				builder.last_market_data().size() > 0 &&
				(spec.current_data().size() == 0 ||
				spec.current_data().last_date_time_matches_first(
					builder.last_market_data()))) {

				// Adjust the end date to the latest date of the main data
				// to guarantee that the time range for indicator requests
				// is the same as for the main data.  (Otherwise, the server
				// could find and send fresh data, due to a slightly later
				// request, resulting in different ranges.)
				end_date = builder.last_latest_date_time();
				assert builder.last_market_data().size() > 0;
				spec.append_data(builder.last_market_data());
				if (spec.last_append_changed_state()) {
					indicators = spec.selected_indicators().iterator();
					while (indicators.hasNext()) {
						ispec = (IndicatorSpecification) indicators.next();
						if (ispec.selected()) {
							builder.send_time_delimited_indicator_data_request(
								ispec.identifier(), spec.symbol(),
								period_type, start_date, end_date);
							if (builder.request_succeeded()) {
								assert builder.last_indicator_data().size() > 0;
								ispec.append_data(
									builder.last_indicator_data());
							} else {
								// Throw exception? Or call notify_of_update?
							}
						}
					}
					client.update_start_date(builder);
					client.notify_of_update();
				}
			} else {
				// builder.send_time_delimited_market_data_request failed or
				// obtained an empty result, so indicator requests are skipped.
				if (! builder.request_succeeded()) {
					client.notify_of_error(builder.request_result_id(), null);
				} else {
					assert(builder.last_market_data().size() == 0);
					assert(builder.request_succeeded());
					// Successful request with no data - No new
					// data is available from the server.
				}
			}
		} catch (Exception e) {
			client.notify_of_failure(e);
		} finally {
			builder.unlock(this);
		}
	}

	private TimeDelimitedDataRequestClient client;

	// Is the `run' routine currently active?
	private boolean requesting_data = false;
}
