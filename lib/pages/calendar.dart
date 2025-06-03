import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<DateTime> _selectedDay;
  late final CalendarFormat _calendarFormat;
  late final Map<DateTime, String> _dayOrders;
  late final Set<DateTime> _userLeaves;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _selectedDay = ValueNotifier(DateTime.now());
    _calendarFormat = CalendarFormat.month;
    _dayOrders = _initializeDayOrders();
    _userLeaves = {};
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _loadUserLeaves();
  }

  Map<DateTime, String> _initializeDayOrders() {
    return {
      DateTime.utc(2024, 12, 1): '-',
      DateTime.utc(2024, 12, 2): 'A 1',
      // Add the rest of your day orders here
    };
  }

  Future<void> _loadUserLeaves() async {
    if (_userId.isEmpty) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('leaves')
        .get();
    final leaves = snapshot.docs.map((doc) => (doc.data()['date'] as Timestamp).toDate()).toSet();
    setState(() {
      _userLeaves = leaves;
    });
  }

  Future<void> _toggleLeave(DateTime date) async {
    if (_userId.isEmpty) return;
    final dateString = date.toIso8601String();
    final leaveRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('leaves')
        .doc(dateString);

    if (_userLeaves.contains(date)) {
      await leaveRef.delete();
      setState(() {
        _userLeaves.remove(date);
      });
    } else {
      await leaveRef.set({'date': date});
      setState(() {
        _userLeaves.add(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 12, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDay.value,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay.value = selectedDay;
              });
              _showDayDetails(selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final isPublicHoliday = _dayOrders[date]?.contains(RegExp(r'[-abcdef]')) ?? false;
                final isUserLeave = _userLeaves.contains(date);
                if (isPublicHoliday) {
                  return _buildDayContainer(date, Colors.yellow, Colors.black);
                } else if (isUserLeave) {
                  return _buildDayContainer(date, Colors.red, Colors.black);
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<DateTime>(
              valueListenable: _selectedDay,
              builder: (context, selectedDay, _) {
                final dayOrder = _dayOrders[selectedDay] ?? 'No Day Order';
                final isUserLeave = _userLeaves.contains(selectedDay);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Date: ${selectedDay.toLocal()}'),
                    Text('Day Order: $dayOrder'),
                    ElevatedButton(
                      onPressed: () => _toggleLeave(selectedDay),
                      child: Text(isUserLeave ? 'Unmark as Leave' : 'Mark as Leave'),
                    ),
                    Text('Total Days Marked as Leave: ${_userLeaves.length}'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContainer(DateTime date, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(color: textColor),
      ),
    );
  }

  void _showDayDetails(DateTime date) {
    final dayOrder = _dayOrders[date] ?? 'No Day Order';
    final isUserLeave = _userLeaves.contains(date);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details for ${date.toLocal()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Day Order: $dayOrder'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleLeave(date);
              },
              child: Text(isUserLeave ? 'Unmark as Leave' : 'Mark as Leave'),
            ),
          ],
        ),
      ),
    );
  }
}
