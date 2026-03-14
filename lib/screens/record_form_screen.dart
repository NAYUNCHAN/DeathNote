import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/incident_record.dart';
import '../models/person.dart';

class RecordFormScreen extends StatefulWidget {
  final Person person;
  final IncidentRecord? record;

  const RecordFormScreen({super.key, required this.person, this.record});

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _whatController = TextEditingController();
  final _howController = TextEditingController();
  final _memoController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _saving = false;

  bool get _isEdit => widget.record != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final record = widget.record!;
      _selectedDateTime = DateTime.tryParse(record.occurredAt);
      _locationController.text = record.location;
      _whatController.text = record.whatHappened;
      _howController.text = record.howHappened;
      _memoController.text = record.memo ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _whatController.dispose();
    _howController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _selectedDateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _dateText() {
    if (_selectedDateTime == null) return '날짜/시간을 선택하세요 *';
    return DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!);
  }

  Future<void> _save() async {
    final validForm = _formKey.currentState!.validate();
    if (!validForm) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜/시간은 필수 입력값입니다.')),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now().toIso8601String();

    if (_isEdit) {
      final updated = widget.record!.copyWith(
        occurredAt: _selectedDateTime!.toIso8601String(),
        location: _locationController.text.trim(),
        whatHappened: _whatController.text.trim(),
        howHappened: _howController.text.trim(),
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
        updatedAt: now,
      );
      await DatabaseHelper.instance.updateRecord(updated);
    } else {
      final record = IncidentRecord(
        personId: widget.person.id!,
        occurredAt: _selectedDateTime!.toIso8601String(),
        location: _locationController.text.trim(),
        whatHappened: _whatController.text.trim(),
        howHappened: _howController.text.trim(),
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await DatabaseHelper.instance.insertRecord(record);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '기록 수정' : '기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('대상 사람: ${widget.person.name}'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.schedule),
                label: Text(_dateText()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '어디서 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '장소는 필수 입력값입니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatController,
                decoration: const InputDecoration(
                  labelText: '무엇을 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '무엇을 항목은 필수 입력값입니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _howController,
                decoration: const InputDecoration(
                  labelText: '어떻게 *',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '어떻게 항목은 필수 입력값입니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '추가 메모 (선택)',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? '저장 중...' : '저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
