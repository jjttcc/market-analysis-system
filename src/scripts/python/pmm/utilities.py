# contents of list l, as a string
def contents(l, space = 0):
	result = ""
	for s in l:
		result = result + s
		if space: result = result + " "
	if space: result = result[:-1]
	return result

# Simple date
class Date:
	def __init__ (self, year, month, day):
		self.year = year
		self.month = month
		self.day = day

	def __cmp__ (self, other):
		if self.year < other.year:
			result = -1
		elif self.year > other.year:
			result = 1
		else:
			if self.month < other.month:
				result = -1
			elif self.month > other.month:
				result = 1
			else:
				if self.day < other.day:
					result = -1
				elif self.day > other.day:
					result = 1
				else:
					result = 0
		return result

	def __str__ (self):
		return "%d/%d/%d" % (self.month, self.day, self.year)

	def as_string(self):
		return self.__str__()
