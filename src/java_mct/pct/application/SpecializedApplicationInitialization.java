package pct.application;

import pct.ApplicationInitialization;

// ApplicationInitialization class specialed for the MAS Control Terminal
public class SpecializedApplicationInitialization
		extends ApplicationInitialization {
	public SpecializedApplicationInitialization() {
		_context = new MCT_ApplicationContext();
	}
}
