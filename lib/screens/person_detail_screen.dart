import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/incident_record.dart';
import '../models/person.dart';
import 'person_form_screen.dart';
import 'record_form_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final Person person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Person _person;
  List<IncidentRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final persons = await DatabaseHelper.instance.getPersons();
    final current = persons.where((e) => e.id == _person.id).firstOrNull;
    if (current == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    final records = await DatabaseHelper.instance.getRecordsByPerson(_person.id!);
    if (!mounted) return;
    setState(() {
      _person = current;
      _records = records;
      _loading = false;
    });
  }

  String _formatOccurredAt(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return isoString;
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Future<void> _deletePerson() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('사람 삭제'),
        content: const Text('이 사람과 연결된 기록도 함께 삭제됩니다. 계속할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deletePerson(_person.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _deleteRecord(int recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteRecord(recordId);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사람 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PersonFormScreen(person: _person)),
              );
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deletePerson,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(_person.name, style: Theme.of(context).textTheme.headlineSmall),
                  if ((_person.memo ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_person.memo!),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('기록 목록', style: Theme.of(context).textTheme.titleLarge),
                      FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordFormScreen(person: _person),
                            ),
                          );
                          _loadData();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('기록 추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_records.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('아직 기록이 없습니다.'),
                      ),
                    )
                  else
                    ..._records.map(
                      (record) => Card(
                        child: ListTile(
                          title: Text(record.whatHappened),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatOccurredAt(record.occurredAt)),
                              Text(record.location),
                              Text(
                                record.howHappened,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecordFormScreen(
                                  person: _person,
                                  record: record,
                                ),
                              ),
                            );
                            _loadData();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteRecord(record.id!),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
