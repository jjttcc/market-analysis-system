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
System.out.println("A");
			try {
System.out.println("B");
				builder.send_time_delimited_market_data_request(spec.symbol(), 
					spec.period_type(), client.start_date(), client.end_date());
				spec.main_data().append(builder.last_market_data());
				indicators = spec.indicator_specifications().iterator();
System.out.println("C");
				while (indicators.hasNext()) {
System.out.println("D");
					IndicatorDataSpecification i =
						(IndicatorDataSpecification) indicators.next();
					builder.send_time_delimited_indicator_data_request(
						i.indicator_id(), spec.symbol(), spec.period_type(),
						client.start_date(), client.end_date());
					i.data().append(builder.last_market_data());
System.out.println("E");
				}
//Need to update and store the new start date somewhere!!!
System.out.println("F");
				client.notify_of_update();
System.out.println("G");
			} catch (Exception e) {
System.out.println("H");
				client.notify_of_failure(e);
System.out.println("I");
			}
		}
System.out.println("J");
	}

// Implementation

	private TimeDelimitedDataRequestClient client;
}
