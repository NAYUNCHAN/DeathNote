import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import 'person_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _personCount = 0;
  int _recordCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _loading = true);
    final personCount = await DatabaseHelper.instance.getPersonCount();
    final recordCount = await DatabaseHelper.instance.getTotalRecordCount();
    if (!mounted) return;
    setState(() {
      _personCount = personCount;
      _recordCount = recordCount;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록노트')),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '개인 기록 정리',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('등록된 사람: $_personCount명'),
                          const SizedBox(height: 8),
                          Text('전체 기록: $_recordCount건'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonListScreen(),
                  ),
                );
                _loadCounts();
              },
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('사람 관리로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
