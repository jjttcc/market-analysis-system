package pct;

// Required initialazation of plug-in components - default: do nothing -
// subclass as needed
public class ApplicationInitialization {
	public ApplicationInitialization() { _context = new ApplicationContext(); }

	public ApplicationContext context() { return _context; }

	protected ApplicationContext _context;
}
