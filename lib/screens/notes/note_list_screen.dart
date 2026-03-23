import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/note_controller.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';
import 'add_note_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NoteController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              onChanged: (v) => ctrl.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Obx(() => ctrl.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => ctrl.searchQuery.value = '',
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),

          // Category chips
          Obx(() {
            final cats = ctrl.categories;
            if (cats.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  _CatChip(
                    label: 'All',
                    selected: ctrl.selectedCategory.value.isEmpty,
                    onTap: () => ctrl.selectedCategory.value = '',
                  ),
                  ...cats.map((c) => _CatChip(
                        label: c,
                        selected: ctrl.selectedCategory.value == c,
                        onTap: () => ctrl.selectedCategory.value = c,
                      )),
                ],
              ),
            );
          }),

          Expanded(
            child: Obx(() {
              final notes = ctrl.filteredNotes;
              if (notes.isEmpty) {
                return const EmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No notes yet',
                  subtitle: 'Capture your thoughts and ideas',
                );
              }
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final noteColor = isDark
                      ? AppTheme.darkCard
                      : Color(note.colorValue);

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    duration: const Duration(milliseconds: 400),
                    child: GestureDetector(
                      onTap: () =>
                          Get.to(() => AddNoteScreen(note: note)),
                      onLongPress: () {
                        Get.dialog(AlertDialog(
                          title: const Text('Delete note?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                ctrl.deleteNote(note.id);
                                Get.back();
                              },
                              child: const Text('Delete',
                                  style:
                                      TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: noteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            width: 0.5,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.category != null &&
                                note.category!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note.category!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Text(
                              note.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? null : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                note.content,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.darkSubtext
                                      : AppTheme.lightSubtext,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Helpers.timeAgo(note.updatedAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppTheme.darkSubtext
                                    : AppTheme.lightSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNoteScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkBorder
                      : AppTheme.lightBorder),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.primaryColor : null,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
