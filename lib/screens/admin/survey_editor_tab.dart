import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class SurveyEditorTab extends StatefulWidget {
  const SurveyEditorTab({super.key});

  @override
  State<SurveyEditorTab> createState() => _SurveyEditorTabState();
}

class _SurveyEditorTabState extends State<SurveyEditorTab> {
  final List<SurveyQuestion> _questions = [
    SurveyQuestion(
      id: 'cc1',
      section: 'Citizen\'s Charter',
      question: 'Which of the following best describes your awareness of a CC?',
      type: QuestionType.radio,
      options: [
        'I know what a CC is and I saw this office\'s CC',
        'I know what a CC is but I did NOT see this office\'s CC',
        'I learned of the CC only when I saw this office\'s CC',
        'I do not know what a CC is and I did not see one in this office',
      ],
    ),
    SurveyQuestion(
      id: 'cc2',
      section: 'Citizen\'s Charter',
      question: 'If aware of CC, would you say that the CC of this office was...?',
      type: QuestionType.radio,
      options: [
        'Easy to see',
        'Somewhat easy to see',
        'Difficult to see',
        'Not visible at all',
        'Not Applicable',
      ],
    ),
    SurveyQuestion(
      id: 'cc3',
      section: 'Citizen\'s Charter',
      question: 'If aware of CC, how much did the CC help you in your transaction?',
      type: QuestionType.radio,
      options: [
        'Helped very much',
        'Somewhat helped',
        'Did not help',
        'Not Applicable',
      ],
    ),
    SurveyQuestion(
      id: 'sqd0',
      section: 'Service Quality',
      question: 'I am satisfied with the service that I availed.',
      type: QuestionType.scale,
      options: [],
    ),
    SurveyQuestion(
      id: 'sqd1',
      section: 'Service Quality',
      question: 'I spent a reasonable amount of time for my transaction.',
      type: QuestionType.scale,
      options: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Survey Editor',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _previewSurvey,
                    icon: const Icon(Icons.preview),
                    label: Text('Preview', style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: Text('Add Question', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Survey Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _questions.removeAt(oldIndex);
                        _questions.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _buildQuestionCard(question, index, key: ValueKey(question.id));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(SurveyQuestion question, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              question.section,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              question.type.name,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (question.options.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: question.options.take(3).map((option) {
                            return Chip(
                              label: Text(
                                option.length > 30 ? '${option.substring(0, 30)}...' : option,
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                              backgroundColor: Colors.grey.shade100,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                        if (question.options.length > 3)
                          Text(
                            '+${question.options.length - 3} more options',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editQuestion(question, index),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteQuestion(index),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _QuestionEditorDialog(
        onSave: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _editQuestion(SurveyQuestion question, int index) {
    showDialog(
      context: context,
      builder: (context) => _QuestionEditorDialog(
        question: question,
        onSave: (updatedQuestion) {
          setState(() {
            _questions[index] = updatedQuestion;
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Question', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this question?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _questions.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Question deleted', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _previewSurvey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Survey Preview', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _questions.map((q) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.question,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        if (q.type == QuestionType.radio)
                          ...q.options.map((option) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.radio_button_unchecked, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(option, style: GoogleFonts.poppins(fontSize: 13))),
                                  ],
                                ),
                              ))
                        else if (q.type == QuestionType.scale)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(5, (i) {
                              final emojis = ['😠', '😕', '😐', '🙂', '😄'];
                              return Text(emojis[i], style: const TextStyle(fontSize: 24));
                            }),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  final SurveyQuestion? question;
  final Function(SurveyQuestion) onSave;

  const _QuestionEditorDialog({
    this.question,
    required this.onSave,
  });

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  late TextEditingController _questionController;
  late TextEditingController _sectionController;
  late QuestionType _selectedType;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.question ?? '');
    _sectionController = TextEditingController(text: widget.question?.section ?? '');
    _selectedType = widget.question?.type ?? QuestionType.radio;
    
    if (widget.question != null) {
      for (var option in widget.question!.options) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else {
      _optionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _sectionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.question == null ? 'Add Question' : 'Edit Question',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: QuestionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              if (_selectedType == QuestionType.radio) ...[
                const SizedBox(height: 16),
                Text(
                  'Options',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._optionControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Option ${entry.key + 1}',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            if (_optionControllers.length > 1) {
                              setState(() {
                                _optionControllers[entry.key].dispose();
                                _optionControllers.removeAt(entry.key);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _optionControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add Option', style: GoogleFonts.poppins()),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.isEmpty || _sectionController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill all required fields', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final options = _selectedType == QuestionType.radio
                ? _optionControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList()
                : <String>[];

            final question = SurveyQuestion(
              id: widget.question?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              section: _sectionController.text,
              question: _questionController.text,
              type: _selectedType,
              options: options,
            );

            widget.onSave(question);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Question saved', style: GoogleFonts.poppins()),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    );
  }
}

enum QuestionType {
  radio,
  checkbox,
  text,
  scale,
}

class SurveyQuestion {
  final String id;
  final String section;
  final String question;
  final QuestionType type;
  final List<String> options;

  SurveyQuestion({
    required this.id,
    required this.section,
    required this.question,
    required this.type,
    required this.options,
  });
}
