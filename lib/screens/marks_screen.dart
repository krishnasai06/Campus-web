import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../config/theme.dart';

class MarksScreen extends StatelessWidget {
  const MarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataProvider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            padding: const EdgeInsets.all(8),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              foregroundColor: AppTheme.primaryBlue,
            ),
            onPressed: () {
              // TODO: Share as PDF
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dataProvider.fetchMarks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Semester Selector
              const Text('ACADEMIC PERIOD',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.slate500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.slate900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: 'Current Semester',
                    items: ['Current Semester', 'Previous Semester']
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child:
                                Text(s, style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (v) {},
                    icon: const Icon(Icons.unfold_more, color: AppTheme.slate400),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SGPA Card (Calculated or scraped)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.school,
                          size: 100, color: Colors.white.withOpacity(0.1)),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Academic Performance',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('SGPA: Scraped soon',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.trending_up,
                                color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text('Fetching data...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subject Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${dataProvider.marksList.length} Courses',
                        style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (dataProvider.isLoading && dataProvider.marksList.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (dataProvider.marksList.isEmpty)
                const Center(child: Text('No marks data available.'))
              else
                ...dataProvider.marksList.map((item) {
                  return _marksCard(
                    item.subjectName,
                    item.subjectCode,
                    item.grade ?? '-',
                    item.internal ?? '-',
                    item.external ?? '-',
                    item.total ?? '-',
                    _getGradeColor(item.grade),
                    isDark,
                  );
                }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.bgDark.withOpacity(0.8) : Colors.white.withOpacity(0.8),
          border: Border(
              top: BorderSide(
                  color: isDark ? AppTheme.slate800 : AppTheme.slate200)),
        ),
        child: FilledButton(
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 18),
              SizedBox(width: 8),
              Text('Share as PDF Report'),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String? grade) {
    switch (grade?.toUpperCase()) {
      case 'S':
      case 'O':
        return Colors.green;
      case 'A+':
      case 'A':
        return Colors.blue;
      case 'B+':
      case 'B':
        return Colors.orange;
      case 'F':
        return Colors.red;
      default:
        return AppTheme.primaryBlue;
    }
  }

  Widget _marksCard(
      String title,
      String code,
      String grade,
      String internal,
      String external,
      String total,
      Color gradeColor,
      bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: -0.5)),
                    Text(code,
                        style: const TextStyle(
                            color: AppTheme.slate500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradeColor.withOpacity(0.1),
                  border: Border.all(color: gradeColor.withOpacity(0.2), width: 2),
                ),
                child: Text(grade,
                    style: TextStyle(
                        color: gradeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.slate100),
          const SizedBox(height: 12),
          Row(
            children: [
              _marksColumn('INTERNAL', internal),
              _marksColumn('EXTERNAL', external, border: true),
              _marksColumn('TOTAL', total, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _marksColumn(String label, String value,
      {bool border = false, bool isPrimary = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: border
              ? const Border(
                  left: BorderSide(color: AppTheme.slate100),
                  right: BorderSide(color: AppTheme.slate100))
              : null,
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate400)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                color: isPrimary ? AppTheme.primaryBlue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
