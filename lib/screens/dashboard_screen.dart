import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/models.dart';
import '../config/theme.dart';
import 'attendance_screen.dart';
import 'marks_screen.dart';
import 'timetable_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const AttendanceScreen(),
    const TimetableScreen(),
    const MarksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initial fetch of data when dashboard is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.bgDark : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? AppTheme.slate800 : AppTheme.slate200),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Home'),
            _navItem(1, Icons.checklist_rounded, 'Attendance'),
            _navItem(2, Icons.calendar_today_rounded, 'Timetable'),
            _navItem(3, Icons.grade_rounded, 'Marks'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : AppTheme.slate400;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();

    // Calculate overall attendance
    double overallAttendance = 0;
    if (data.attendanceList.isNotEmpty) {
      overallAttendance = data.attendanceList
              .map((e) => e.percentage)
              .reduce((a, b) => a + b) /
          data.attendanceList.length;
    }

    return RefreshIndicator(
      onRefresh: () => data.refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.2),
                            width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAxJ9dAgQPffyW1UlxUUeI_AbTwNkfLQOslLDzSPoIae6VNrypn2Y9lMZuXyhQYcOJVmejkeR9_FC_B0EaQqUExhciQqey3Sn8iem6JuksfH2cNv8TDifTdS7E3KJD-ZxvNJuB-u0T8GSw2EBtRbDpoTl1osFoIGIpQUqhIlnlvfhouvdI5t04WX3-XnYrWq25PXXy4kYuOIJilvlsBXAqNKGEKK_4Lqw7dBFKdnzahTRAN0tzkHtaj2MMepgoiP0rCuWVzzccAh5A'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.slate500,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Hello, ${auth.user?.name ?? auth.user?.netID ?? "Student"}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attendance Hero
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Attendance',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              overallAttendance >= 75
                                  ? 'You are maintaining a great academic standing. Keep up the consistency!'
                                  : 'Your attendance is below 75%. Consider attending more classes to stay on track!',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Switch to attendance tab if needed, 
                                // but here just dummy or jump to detail
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                elevation: 0,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text('View Detailed Report',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: overallAttendance / 100,
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                color: Colors.white,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${overallAttendance.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Text('PRESENT',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                _statCard(
                    data.attendanceList.length.toString(), 'TOTAL SUBJECTS'),
                const SizedBox(width: 12),
                _statCard(
                    data.timetableList.length.toString(), 'CLASSES TODAY'),
                const SizedBox(width: 12),
                _statCard('2', 'PENDING TASKS'), // Dummy for now
              ],
            ),
            const SizedBox(height: 32),

            // Academic Services
            const Text(
              'ACADEMIC SERVICES',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.slate500),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _serviceCard(
                  icon: Icons.checklist_rounded,
                  title: 'Attendance',
                  subtitle: 'View All Subjects',
                  color: Colors.blue,
                  progress: overallAttendance / 100,
                  isDark: isDark,
                ),
                _serviceCard(
                  icon: Icons.grade_rounded,
                  title: 'Marks',
                  subtitle: 'Internal + External',
                  color: Colors.orange,
                  cgpa: '9.2', // Dummy for now
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timetable Card
            _timetablePreview(data.timetableList, isDark),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate100.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.slate500,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    double? progress,
    String? cgpa,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppTheme.slate800 : AppTheme.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.slate300, size: 20),
            ],
          ),
          const Spacer(),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle,
              style: const TextStyle(color: AppTheme.slate500, fontSize: 12)),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.slate100.withOpacity(0.5),
                color: AppTheme.primaryBlue,
                minHeight: 6,
              ),
            ),
          ] else if (cgpa != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('CGPA: $cgpa',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(width: 4),
                const Text('Current Sem',
                    style: TextStyle(color: AppTheme.slate500, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timetablePreview(List<TimetableModel> timetable, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppTheme.slate800 : AppTheme.slate100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: Colors.teal, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Timetable',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Today's Classes",
                          style: TextStyle(
                              color: AppTheme.slate500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.slate300, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          if (timetable.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No classes scheduled for today.',
                  style: TextStyle(color: AppTheme.slate400, fontStyle: FontStyle.italic)),
            )
          else
            ...timetable.take(2).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _timetableItem(
                    item.time, item.subject, AppTheme.primaryBlue, isDark),
              );
            }),
        ],
      ),
    );
  }

  Widget _timetableItem(
      String time, String title, Color indicatorColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark.withOpacity(0.5) : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? AppTheme.slate800 : AppTheme.slate100),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(time,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500)),
          ),
          Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
