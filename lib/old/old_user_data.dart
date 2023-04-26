enum EntryType {
  steps,
  mood
}

// A singular entry in the user data table
class OldDataEntry {
  final DateTime date;
  final int value;

  OldDataEntry.withDate(this.date, this.value);
  OldDataEntry(this.value) : date = DateTime.now();
}

class OldDataTable {
  Map<EntryType, List<OldDataEntry>> entryLists = {};

  OldDataTable() {
    for (EntryType type in EntryType.values) {
      entryLists[type] = [];
    }
  }

  void addEntry(OldDataEntry entry, EntryType type) {
    entryLists[type]!.add(entry);
  }

  List<OldDataEntry> getEntries(EntryType type) => entryLists[type] ?? [];
}

// Class to store all of a user's data
class OldUserData {
  // Add data for testing
  OldUserData() {
    DateTime startDate = DateTime.now();
    for (int i = -3; i <= 3; i++) {
      data.addEntry(OldDataEntry.withDate(startDate.add(Duration(days: i)), 100), EntryType.steps);
    }
    for (int i = -3; i <= 3; i++) {
      data.addEntry(OldDataEntry.withDate(startDate.add(Duration(days: i)), 5), EntryType.mood);
    }
  }

  // All data entries for this user
  OldDataTable data = OldDataTable();

  // Adds a user data entry
  void addEntry(int value, EntryType type) => data.addEntry(OldDataEntry(value), type);

  // Gets the total amount of steps on days that satisfy a given condition
  int getTotal(bool Function(DateTime, DateTime) dateCondition, DateTime comparisonDate) {
    int total = 0;
    for (OldDataEntry entry in data.getEntries(EntryType.steps)) {
      if (dateCondition(entry.date, comparisonDate)) {
        total += entry.value;
      }
    }
    return total;
  } 

  // Checks if two DateTimes are the same day
  bool isSameDay(DateTime date1, DateTime date2) =>
    date1.day == date2.day && isSameMonth(date1, date2);

  // Checks if two DateTimes are the same month
  bool isSameMonth(DateTime date1, DateTime date2) => 
    date1.month == date2.month && isSameYear(date1, date2);
  
  // Checks if two DateTimes are the same year
  bool isSameYear(DateTime date1, DateTime date2) => date1.year == date2.year;
  
  // Checks if two DateTimes are the same week
  bool isSameWeek(DateTime date1, DateTime date2) {
    DateTime weekStart = DateTime(date1.year, date1.month, date1.day - date1.weekday + 1);
    DateTime weekEnd = DateTime(date1.year, date1.month, date1.day + 7 - date1.weekday + 1);
    bool sameWeek = date2.compareTo(weekStart) >= 0 && date2.compareTo(weekEnd) < 0;
    return sameWeek;
  }

  // Functions to get totals for the above conditions
  int getDailyTotal() => getTotal(isSameDay, DateTime.now());
  int getWeeklyTotal() => getTotal(isSameWeek, DateTime.now());
  int getMonthlyTotal() => getTotal(isSameMonth, DateTime.now());
  int getYearlyTotal() => getTotal(isSameYear, DateTime.now());
}