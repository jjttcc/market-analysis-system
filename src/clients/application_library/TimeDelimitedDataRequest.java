package application_library;

import java.util.*;

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
		Iterator indicators;
		if (client != null) {
			TradableDataSpecification spec = client.specification();
			AbstractDataSetBuilder builder = client.data_builder();
			try {
				builder.send_time_delimited_market_data_request(spec.symbol(), 
					spec.period_type(), client.start_date(), client.end_date());
				spec.main_data().append(builder.last_market_data());
				indicators = spec.indicator_specifications().iterator();
				while (indicators.hasNext()) {
					IndicatorDataSpecification i =
						(IndicatorDataSpecification) indicators.next();
					builder.send_time_delimited_indicator_data_request(
						i.indicator_id(), spec.symbol(), spec.period_type(),
						client.start_date(), client.end_date());
					i.data().append(builder.last_market_data());
				}
	//Need to update and store the new start date somewhere!!!
				client.notify_of_update();
			} catch (Exception e) {
				client.notify_of_failure(e);
			}
		}
	}

// Implementation

	private TimeDelimitedDataRequestClient client;
}
