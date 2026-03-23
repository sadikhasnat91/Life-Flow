import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/note_controller.dart';
import '../../models/note_model.dart';
import '../../utils/constants.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  int _colorValue = 0xFFFFFFFF;
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.note!.title;
      _contentCtrl.text = widget.note!.content;
      _categoryCtrl.text = widget.note!.category ?? '';
      _colorValue = widget.note!.colorValue;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                Get.find<NoteController>().deleteNote(widget.note!.id);
                Get.back();
              },
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color picker
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.noteColors.map((c) {
                  final selected = _colorValue == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _colorValue = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Color(c).withValues(alpha: 0.3) : Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 16, color: AppTheme.primaryColor)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Note title',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _categoryCtrl,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
              ),
              decoration: InputDecoration(
                hintText: 'Category (optional)',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.label_outline,
                      size: 16,
                      color:
                          isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ),
            const Divider(height: 24),
            TextField(
              controller: _contentCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              minLines: 15,
              style: const TextStyle(fontSize: 16, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Start writing...',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final ctrl = Get.find<NoteController>();
    if (_isEditing) {
      final note = widget.note!;
      note.title = _titleCtrl.text.trim();
      note.content = _contentCtrl.text.trim();
      note.category =
          _categoryCtrl.text.trim().isNotEmpty ? _categoryCtrl.text.trim() : null;
      note.colorValue = _colorValue;
      ctrl.updateNote(note);
    } else {
      ctrl.addNote(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isNotEmpty
            ? _categoryCtrl.text.trim()
            : null,
        colorValue: _colorValue,
      );
    }
    Get.back();
  }
}
