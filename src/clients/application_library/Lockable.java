package application_library;


/**
* Objects that can be locked and unlocked, with respect to thread
* synchronization, by another object
**/
class Lockable {

// Initialization

	public Lockable() {
		lock_holder = null;
	}

// Status report

	/**
	* Is 'this' locked?
	**/
	public synchronized boolean is_locked() {
		return lock_holder != null;
	}

	/**
	* Is 'this' locked by `o'?
	**/
	public synchronized boolean is_locked_by(Object o) {
		return lock_holder == o;
	}

// Status setting

	/**
	* Lock `this' by `o' if it's not already locked; otherwise, do nothing.
	**/
	public synchronized void lock(Object o) {
		if (lock_holder == null) {
			lock_holder = o;
		}
	}

	/**
	* If is_locked_by(o), unlock `this'; otherwise, do nothing.
	**/
	public synchronized void unlock(Object o) {
		if (lock_holder == o) {
			lock_holder = null;
		}
	}

// Implementation - Attributes

	private Object lock_holder;
}
