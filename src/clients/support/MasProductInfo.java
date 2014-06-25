/**
   author: "Jim Cochrane"
   date: "$Date$";
   revision: "$Revision$"
   copyright: "Copyright (c) 1998-2014, Jim Cochrane"
   license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
*/

package support;

import java_library.support.*;

/**
* Information about the current version of the GUI client application
**/
public class MasProductInfo extends ProductInfo {

	public String name() {
		return "Market Analysis Charting Client";
	}

	/**
	* The components of the version number
	* Components are strings to allow mixed numbers and letters.
	**/
	public String[] number_components() {
		String[] result = {"1", "6", "1a"};
		return result;
	}

	/**
	* The last date that `number' was updated
	**/
	public String date() {
		return "2005-02-08";
	}

	/**
	* Short description of the current release
	**/
	public String release_description() {
		return number() + " - (development release)";
	}

	public String copyright() {
		return "Copyright 1998 - 2005: Jim Cochrane";
	}

	public String license_information() {
		return "License: GPL version 2";
	}
}
