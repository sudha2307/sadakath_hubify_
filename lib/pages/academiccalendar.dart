import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AcademicCal extends StatefulWidget {
  const AcademicCal({Key? key}) : super(key: key);

  @override
  State<AcademicCal> createState() => _AcademicCalState();
}

class _AcademicCalState extends State<AcademicCal> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? selectedDayOrder;

  final Map<String, String> dayOrders = {
    '2024-12-01': '-',
    '2024-12-02': 'A 1',
    '2024-12-03': 'B',
    '2024-12-04': 'C',
    '2024-12-05': 'D',
    '2024-12-06': 'E',
    '2024-12-07': '-',
    '2024-12-02': '-',
    '2024-12-09': 'F',
    '2024-12-10': 'A 2',
    '2024-12-11': 'B',
    '2024-12-12': 'C',
    '2024-12-13': 'D',
    '2024-12-14': '-',
    '2024-12-15': '-',
    '2024-12-16': 'E',
    '2024-12-17': 'F',
    '2024-12-18': 'A 3',
    '2024-12-19': 'B LSQ-I',
    '2024-12-20': 'C',
    '2024-12-21': '-',
    '2024-12-22': '-',
    '2024-12-23': 'D',
    '2024-12-24': 'E',
    '2024-12-25': 'Christmas',
    '2024-12-26': '-',
    '2024-12-27': 'F',
    '2024-12-28': 'A 4',
    '2024-12-29': '-',
    '2024-12-30': 'B',
    '2024-12-31': 'C',

    // January 2025
    '2025-01-01': 'New Year',
    '2025-01-02': 'D CIA-I Begins',
    '2025-01-03': 'E',
    '2025-01-04': 'F',
    '2025-01-05': '-',
    '2025-01-06': 'A 5',
    '2025-01-07': 'B',
    '2025-01-08': 'C',
    '2025-01-09': 'D',
    '2025-01-10': 'E CIA-I Ends',
    '2025-01-11': 'F',
    '2025-01-12': '-',
    '2025-01-13': '-',
    '2025-01-14': 'Pongal',
    '2025-01-15': 'Thiruvalluvar Day',
    '2025-01-16': 'Uzhavar Thirunal',
    '2025-01-17': '-',
    '2025-01-18': '-',
    '2025-01-19': '-',
    '2025-01-20': 'A 6',
    '2025-01-21': 'B',
    '2025-01-22': 'C',
    '2025-01-23': 'D LSM-I',
    '2025-01-24': 'E',
    '2025-01-25': '-',
    '2025-01-26': 'Republic Day',
    '2025-01-27': 'F CIA-I-P. Begins',
    '2025-01-28': 'A 7 Mihraj',
    '2025-01-29': 'B',
    '2025-01-30': 'C',
    '2025-01-31': 'D CIA-I-P. Ends',

    '2025-02-01': 'E LSQ-II',
    '2025-02-02': '-',
    '2025-02-03': 'F',
    '2025-02-04': 'A 8',
    '2025-02-05': 'B',
    '2025-02-06': 'C',
    '2025-02-07': 'D',
    '2025-02-08': '-',
    '2025-02-09': '-',
    '2025-02-10': 'E',
    '2025-02-11': 'Thaipoosam',
    '2025-02-12': 'F',
    '2025-02-13': 'A 9 CIA-II-Begins',
    '2025-02-14': 'B',
    '2025-02-15': 'Bara\'th, Ayya Vaikundar',
    '2025-02-16': '-',
    '2025-02-17': 'C',
    '2025-02-18': 'D',
    '2025-02-19': 'E',
    '2025-02-20': 'F',
    '2025-02-21': 'A 10',
    '2025-02-22': 'B CIA-II Ends',
    '2025-02-23': '-',
    '2025-02-24': 'C Ph.D. C.W-I',
    '2025-02-25': 'D Ph.D. C.W-I',
    '2025-02-26': 'E Ph.D.C.W-I',
    '2025-02-27': 'F',
    '2025-02-28': 'A 11 LSM-II',

    '2025-03-01': '-',
    '2025-03-02': 'Ramazhan',
    '2025-03-03': '-',
    '2025-03-04': 'B CIA-II-Prac. Begins',
    '2025-03-05': 'C',
    '2025-03-06': 'D',
    '2025-03-07': 'E',
    '2025-03-08': '-',
    '2025-03-09': '-',
    '2025-03-10': 'F CIA-II P. Ends - LSO-III',
    '2025-03-11': 'A 12th Circle Starts',
    '2025-03-12': 'B',
    '2025-03-13': 'C',
    '2025-03-14': 'D',
    '2025-03-15': '-',
    '2025-03-16': '-',
    '2025-03-17': 'E CIA-III Begins',
    '2025-03-18': 'F',
    '2025-03-19': 'A 13',
    '2025-03-20': 'B',
    '2025-03-21': 'C',
    '2025-03-22': '-',
    '2025-03-23': '-',
    '2025-03-24': 'D',
    '2025-03-25': 'E',
    '2025-03-26': 'F CIA-III Ends',
    '2025-03-27': '-',
    '2025-03-28': 'Lailatul Qadr',
    '2025-03-29': '-',
    '2025-03-30': 'Telugu New Year',
    '2025-03-31': 'Eid-al-Fitr',

    '2025-04-01': '-',
    '2025-04-02': '-',
    '2025-04-03': 'A 14',
    '2025-04-04': 'B ExtP- Begins Ph.D. C.W-II',
    '2025-04-05': 'C Ph.D. C.W-II',
    '2025-04-07': 'D Ph.D. C.W-II',
    '2025-04-06': '-',
    '2025-04-08': 'E',
    '2025-04-09': 'F LSM-III',
    '2025-04-10': 'Mahaveer Jeyanthi',
    '2025-04-11': 'A 15',
    '2025-04-12': 'B',
    '2025-04-13': '-',
    '2025-04-14': 'Tamil New Year',
    '2025-04-15': 'C',
    '2025-04-16': 'D Pro.Sub.',
    '2025-04-17': 'E',
    '2025-04-18': '-',
    '2025-04-19': '-',
    '2025-04-20': 'Easter',
    '2025-04-21': 'F LWD-Ext.Prac-End',
    '2025-04-22': '-',
    '2025-04-23': '-',
    '2025-04-24': '-',
    '2025-04-25': '-',
    '2025-04-26': '-',
    '2025-04-27': '-',
    '2025-04-28': 'Sem. Exam. Begins',
    '2025-04-29': '-',
    '2025-04-30': '-',
  };

  String getTodayOrder() {
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final value = dayOrders[key] ?? '-';
    final first = value.split(' ').first;
    return ['A', 'B', 'C', 'D', 'E', 'F'].contains(first) ? first : '-';
  }

  String getTodayEvent() {
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final value = dayOrders[key] ?? '-';
    final first = value.split(' ').first;
    if (['A', 'B', 'C', 'D', 'E', 'F'].contains(first)) {
      return value.substring(first.length).trim().isNotEmpty
          ? value.substring(first.length).trim()
          : '-';
    }
    return value != '-' ? value : '-';
  }

  @override
  Widget build(BuildContext context) {
    final String todayOrder = getTodayOrder();
    final String eventToday = getTodayEvent();
    final bool hasEvent = eventToday != '-';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 🔝 Header
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60.0),
                        bottomRight: Radius.circular(60.0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Image.asset("assets/images/logo.png", height: 120),
                      ],
                    ),
                  ),


                  const SizedBox(height: 20),

                  Text('Day Order',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      )),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                    decoration: BoxDecoration(
                      color: Colors.yellow[800],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      todayOrder,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (hasEvent) ...[
                    const Text(
                      'Event Today:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.yellow[800],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        eventToday,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // 📅 TableCalendar
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(formatButtonVisible: false),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                        final key = DateFormat('yyyy-MM-dd').format(selected);
                        selectedDayOrder = dayOrders[key] ?? '-';
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) {
                        final key = DateFormat('yyyy-MM-dd').format(date);
                        final value = dayOrders[key];
                        if (value != null) {
                          final first = value.split(' ').first;
                          if (!['A', 'B', 'C', 'D', 'E', 'F'].contains(first)) {
                            return Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.yellow[600],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return null;
                      },
                      todayBuilder: (context, date, _) {
                        return Center(
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (selectedDayOrder != null) ...[
                    Text(
                      'Day Order:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                      decoration: BoxDecoration(
                        color: Colors.yellow[600],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        selectedDayOrder ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
