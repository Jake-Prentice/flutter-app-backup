import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/main.dart';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/user_data/activity_entry.dart';
import 'package:flutter_pi/user_data/single_value_entry.dart';
import 'package:flutter_pi/user_data/user_data.dart';

// Allows enums to be formatted with a starting capital letter for the table
extension on Enum {
  String get capitalised {
    return name[0].toUpperCase() + name.substring(1);
  }
}

// Allows date times to be formatted in DD/MM/YYYY for the table
extension on DateTime {
  String get formatted => "$day/$month/$year";
}

// Page to show the history of entries to the user's databases
class HistoryPage extends StatefulWidget {
  HistoryPage({super.key});

  // Creates streams for each of the possible tables
  final stepsStream = UserData.instance!.stepsRef.snapshots();
  final moodStream = UserData.instance!.moodRef.snapshots();
  final activitiesStream = UserData.instance!.activitiesRef.snapshots();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DatabaseTypes _currentDatabase = DatabaseTypes.steps;

  // Flags used for sorting the current data table
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Updates flags for the current data table's sorting
  void updateSort(int i, bool a) => setState(() {
    _sortAscending = a;
    _sortColumnIndex = i;
  });

  // Compares two elements in the specified order
  int compare(bool ascending, Comparable a, Comparable b) =>
    ascending ? b.compareTo(a) : a.compareTo(b);

  // Creates data columns with given headings
  List<DataColumn> createColumns(List<String> headings) => 
    headings.map((e) => DataColumn(label: Text(e), onSort: updateSort)).toList();
  
  // Creates data rows from a given list of entries, each mapped to a list of cells
  List<DataRow> createRows<T>(List<T> entries, List<DataCell> Function(T) cells) =>
    [for (T entry in entries) DataRow(cells: cells(entry))];

  // Creates data cells based on given cell contents 
  List<DataCell> createCells(List<String> cellContents) =>
    [for (String label in cellContents) DataCell(Text(label))];

  // Gets a table showing the steps entries
  Widget get _stepsTable => StreamBuilder<QuerySnapshot<StepsEntry>>(
    stream: widget.stepsStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Gets and sorts step entries according to current sort settings
      final stepEntries = snapshot.data!.docs.map((doc) => doc.data()).toList();
      if (_sortColumnIndex == 0) {
        stepEntries.sort((a, b) => compare(_sortAscending, a.date, b.date));
      } else if (_sortColumnIndex == 1) {
        stepEntries.sort((a, b) => compare(_sortAscending, a.value, b.value));
      }

      // Returns complete data table
      return DataTable(
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        columns: createColumns(["Date", "Steps"]),
        rows: createRows(stepEntries, (entry) => createCells([
          entry.date.formatted, entry.value.toString()
        ]))
      );
    }
  );

  // Gets a table showing the mood entries
  Widget get _moodTable => StreamBuilder<QuerySnapshot<MoodEntry>>(
    stream: widget.moodStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Gets and sorts mood entries according to current sort settings
      final moodEntries = snapshot.data!.docs.map((doc) => doc.data()).toList();
      if (_sortColumnIndex == 0) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.date, b.date));
      } else if (_sortColumnIndex == 1) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.value, b.value));
      }

      // Returns complete data table
      return DataTable(
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        columns: createColumns(["Date", "Mood"]),
        rows: createRows(moodEntries, (entry) => createCells([
          entry.date.formatted, entry.value.toString()
        ]))
      );
    }
  );

  // Gets a table showing the mood entries
  Widget get _activitiesTable => StreamBuilder<QuerySnapshot<ActivityEntry>>(
    stream: widget.activitiesStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Gets and sorts mood entries according to current sort settings
      final moodEntries = snapshot.data!.docs.map((doc) => doc.data()).toList();
      if (_sortColumnIndex == 0) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.date, b.date));
      } else if (_sortColumnIndex == 1) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.type.name, b.type.name));
      } else if (_sortColumnIndex == 2) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.intensity.index, b.intensity.index));
      } else if (_sortColumnIndex == 3) {
        moodEntries.sort((a, b) => compare(_sortAscending, a.duration, b.duration));
      }

      // Returns complete data table
      return DataTable(
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        columns: createColumns(["Date", "Type", "Intensity", "Duration"]),
        rows: createRows(moodEntries, (entry) => createCells([
          entry.date.formatted, 
          entry.type.capitalised,
          entry.intensity.capitalised,
          entry.duration.toString()
        ]))
      );
    }
  );

  // Gets the currently selected data table
  Widget get _currentTable {
    switch (_currentDatabase) {
      case DatabaseTypes.steps:
        return _stepsTable;
      case DatabaseTypes.mood:
        return _moodTable;
      case DatabaseTypes.activities:
        return _activitiesTable;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Text("History")
    ),
    drawer: AppNavigationDrawer(),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: 
          (context) => const MainPage()
        )
      ),
      backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
      child: const Icon(Icons.home_rounded)
    ),
    body: ListView(children: [
      Row(children: [
        // Text to tell the user to select a database
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Select Database: ", 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 16
            )
          )
        ),
        // Dropdown button to select table
        Expanded(child: Padding(
          padding: const EdgeInsets.all(16), 
          child: DropdownButton<DatabaseTypes>(  
            isExpanded: true,          
            borderRadius: BorderRadius.circular(8),
            value: _currentDatabase,
            items: DatabaseTypes.values.map((t) => DropdownMenuItem(
                value: t, child: Text("\t${t.capitalised}")
            )).toList(), 
            onChanged: (state) => setState(() {
              _sortColumnIndex = 0;
              _sortAscending = true;
              _currentDatabase = state!;
            })
          )
        ))
      ]),

      // Gets and displays the currently selected table
      _currentTable
    ]),
  );
}