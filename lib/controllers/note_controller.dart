import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';

class NoteController extends GetxController {
  final notes = <NoteModel>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void loadNotes() {
    notes.value = DatabaseService.getAllNotes();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<NoteModel> get filteredNotes {
    var list = notes.toList();
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((n) =>
              n.title
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              n.content
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    if (selectedCategory.value.isNotEmpty) {
      list = list
          .where((n) => n.category == selectedCategory.value)
          .toList();
    }
    return list;
  }

  List<String> get categories {
    final cats = notes
        .where((n) => n.category != null && n.category!.isNotEmpty)
        .map((n) => n.category!)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  Future<void> addNote({
    required String title,
    String content = '',
    String? category,
    int colorValue = 0xFFFFFFFF,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      category: category,
      colorValue: colorValue,
    );
    await DatabaseService.addNote(note);
    loadNotes();
  }

  Future<void> updateNote(NoteModel note) async {
    note.updatedAt = DateTime.now();
    await DatabaseService.updateNote(note);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await DatabaseService.deleteNote(id);
    loadNotes();
  }
}
