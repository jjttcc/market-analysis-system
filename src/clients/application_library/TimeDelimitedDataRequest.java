package application_library;

import java.util.*;
import graph_library.DataSet;

// Data requests to the server delimited by a start and an end date-time,
// supplied by a TimeDelimitedDataRequestClient
class TimeDelimitedDataRequest extends TimerTask {

// Initialization

	TimeDelimitedDataRequest(TimeDelimitedDataRequestClient the_client) {
		client = the_client;
System.out.println("time del DR - client: " + client);
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
			IndicatorDataSpecification i;
System.out.println("[RUN]\nbuilder: " + builder);
System.out.println("spec: " + spec);
			try {
System.out.println("A");
				builder.send_time_delimited_market_data_request(spec.symbol(), 
					spec.period_type(), client.start_date(), client.end_date());
				if (builder.request_succeeded() &&
						builder.last_market_data().count() > 0) {

System.out.println("B");
					spec.main_data().append(builder.last_market_data());
					indicators = spec.selected_indicators().iterator();
System.out.println("# of indicators: " +
spec.indicator_specifications().size());
System.out.println("# of selected indicators: " +
spec.selected_indicators().size());
					while (indicators.hasNext()) {
System.out.println("C");
						i = (IndicatorDataSpecification) indicators.next();
						if (i.selected()) {
System.out.println("D");
							DataSet data = i.data();
							builder.send_time_delimited_indicator_data_request(
								i.identifier(), spec.symbol(),
								spec.period_type(), client.start_date(),
								client.end_date());
System.out.println("i was selected: " + i);
System.out.println("i.data: " + i.data());
							i.data().append(builder.last_market_data());
						}
else {
System.out.println("i was NOT selected: " + i); }
					}
	//Need to update and store the new start date somewhere!!!
	//!!!!Change: If no data was received from the server, don't notify.
					client.notify_of_update();
				} else {
					if (! builder.request_succeeded()) {
						client.notify_of_error(builder.request_result_id(),
							null);
					} else {
						// assert(builder.last_market_data().count() == 0);
						// assert(builder.request_succeeded());
						// Successful request with no data: Assume no new
						// data is available from the server.
if ((builder.last_market_data().count() == 0) && builder.request_succeeded()) {
System.out.println("succeeded and empty");
} else {
System.out.println("FAULT: not succeeded or not empty");
}
					}
				}
			} catch (Exception e) {
System.out.println("data retrieval failed with error: " + e);
				client.notify_of_failure(e);
			}
		}
System.out.println("[end RUN]");
	}

// Implementation

	private TimeDelimitedDataRequestClient client;
}
