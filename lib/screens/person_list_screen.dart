import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/person.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  List<Person> _persons = [];
  Map<int, int> _recordCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    setState(() => _loading = true);
    final persons = await DatabaseHelper.instance.getPersons();
    final counts = <int, int>{};
    for (final person in persons) {
      if (person.id == null) continue;
      counts[person.id!] =
          await DatabaseHelper.instance.getRecordCountByPerson(person.id!);
    }
    if (!mounted) return;
    setState(() {
      _persons = persons;
      _recordCounts = counts;
      _loading = false;
    });
  }

  Future<void> _openPersonForm({Person? person}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonFormScreen(person: person)),
    );
    _loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사람 목록')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _persons.isEmpty
              ? const Center(child: Text('등록된 사람이 없습니다.'))
              : RefreshIndicator(
                  onRefresh: _loadPersons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _persons.length,
                    itemBuilder: (context, index) {
                      final person = _persons[index];
                      final count = _recordCounts[person.id ?? -1] ?? 0;
                      return Card(
                        child: ListTile(
                          title: Text(person.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((person.memo ?? '').isNotEmpty)
                                Text(
                                  person.memo!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text('기록 $count건'),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonDetailScreen(person: person),
                              ),
                            );
                            _loadPersons();
                          },
                          onLongPress: () => _openPersonForm(person: person),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPersonForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
