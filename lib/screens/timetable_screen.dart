import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../config/theme.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataProvider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Day Picker
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.bgDark : Colors.white,
              border: Border(
                  bottom: BorderSide(
                      color: isDark ? AppTheme.slate800 : AppTheme.slate100)),
            ),
            child: Row(
              children: [
                _dayTab('Mon', '12', true),
                _dayTab('Tue', '13', false),
                _dayTab('Wed', '14', false),
                _dayTab('Thu', '15', false),
                _dayTab('Fri', '16', false),
              ],
            ),
          ),

          // Timeline Content
          Expanded(
            child: dataProvider.isLoading && dataProvider.timetableList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => dataProvider.fetchTimetable(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: dataProvider.timetableList.length,
                      itemBuilder: (context, index) {
                        final item = dataProvider.timetableList[index];
                        final isLast = index == dataProvider.timetableList.length - 1;
                        // Determine if "now" or "next" (dummy logic for now)
                        final isNow = index == 0; 
                        
                        return _timelineItem(
                          time: item.time,
                          title: item.subject,
                          room: item.room ?? 'N/A',
                          faculty: item.faculty ?? 'N/A',
                          isNow: isNow,
                          isLast: isLast,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dayTab(String day, String date, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  width: 3)),
        ),
        child: Column(
          children: [
            Text(day.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.slate400,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(date,
                style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.slate700,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem({
    required String time,
    required String title,
    required String room,
    required String faculty,
    bool isNow = false,
    bool isNext = false,
    bool isLast = false,
    required bool isDark,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                  width: 1,
                  height: 16,
                  color: isNow ? Colors.transparent : AppTheme.slate100),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNow ? AppTheme.primaryBlue : Colors.transparent,
                  border: Border.all(
                      color: isNow
                          ? AppTheme.primaryBlue.withOpacity(0.2)
                          : AppTheme.slate300,
                      width: isNow ? 4 : 2),
                  boxShadow: isNow
                      ? [
                          BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              blurRadius: 4)
                        ]
                      : null,
                ),
              ),
              Expanded(
                  child: Container(
                      width: 1,
                      color: isLast ? Colors.transparent : AppTheme.slate100)),
            ],
          ),
          const SizedBox(width: 24),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(time,
                          style: TextStyle(
                              color: isNow ? AppTheme.primaryBlue : AppTheme.slate500,
                              fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13)),
                      if (isNow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text('NOW',
                              style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.slate900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isNow
                              ? AppTheme.primaryBlue
                              : (isDark ? AppTheme.slate800 : AppTheme.slate100),
                          width: isNow ? 2 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _infoLabel(Icons.meeting_room_outlined, room),
                            const SizedBox(width: 16),
                            _infoLabel(Icons.person_outline, faculty),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.slate400),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppTheme.slate500, fontSize: 12)),
      ],
    );
  }
}
