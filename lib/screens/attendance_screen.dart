import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../config/theme.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataProvider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter subjects by name or code...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.slate400),
                filled: true,
                fillColor: isDark ? AppTheme.slate800 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search filtering
              },
            ),
          ),

          // Summary Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _chip('All Subjects', AppTheme.primaryBlue, Colors.white),
                const SizedBox(width: 8),
                _chip('Above 75%', Colors.green.withOpacity(0.1), Colors.green,
                    border: true),
                const SizedBox(width: 8),
                _chip('Low Attendance', Colors.orange.withOpacity(0.1),
                    Colors.orange,
                    border: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attendance List
          Expanded(
            child: dataProvider.isLoading && dataProvider.attendanceList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => dataProvider.fetchAttendance(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dataProvider.attendanceList.length,
                      itemBuilder: (context, index) {
                        final item = dataProvider.attendanceList[index];
                        return _attendanceCard(
                          subject: item.subjectName,
                          code: item.subjectCode,
                          percent: item.percentage.toInt(),
                          attended: item.attended,
                          total: item.total,
                          status: item.percentage >= 75 ? 'ON TRACK' : 'WARNING',
                          color: item.percentage >= 75
                              ? Colors.green
                              : (item.percentage >= 65
                                  ? Colors.orange
                                  : Colors.red),
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open calculator
        },
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculate',
            style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text, {bool border = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border ? Border.all(color: text.withOpacity(0.2)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _attendanceCard({
    required String subject,
    required String code,
    required int percent,
    required int attended,
    required int total,
    required String status,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.5)),
                    Text(code,
                        style: const TextStyle(
                            color: AppTheme.slate500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text('$percent%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: isDark ? AppTheme.slate800 : AppTheme.slate100,
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attended: $attended / Total: $total',
                style: const TextStyle(color: AppTheme.slate500, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
