import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class SurveyEditorTab extends StatefulWidget {
  const SurveyEditorTab({super.key});

  @override
  State<SurveyEditorTab> createState() => _SurveyEditorTabState();
}

class _SurveyEditorTabState extends State<SurveyEditorTab> {
  // Survey metadata
  String _surveyTitle = 'ARTA Client Satisfaction Survey';
  String _surveyDescription =
      'Help us improve government services by sharing your feedback.';

  // Survey sections with their questions
  final List<SurveySection> _sections = [
    SurveySection(
      id: 'demographics',
      title: 'Personal Information',
      description: 'Basic information about the respondent',
      isRequired: true,
      questions: [
        SurveyQuestion(
          id: 'client_type',
          question: 'Client Type',
          type: QuestionType.radio,
          isRequired: true,
          options: [
            'Citizen',
            'Business',
            'Government (Employee or another agency)',
          ],
        ),
        SurveyQuestion(
          id: 'sex',
          question: 'Sex',
          type: QuestionType.radio,
          isRequired: true,
          options: ['Male', 'Female'],
        ),
        SurveyQuestion(
          id: 'age',
          question: 'Age',
          type: QuestionType.number,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'region',
          question: 'Region',
          type: QuestionType.dropdown,
          isRequired: true,
          options: [
            'NCR',
            'Region I',
            'Region II',
            'Region III',
            'Region IV-A',
            'Region IV-B',
            'Region V',
            'Region VI',
            'Region VII',
            'Region VIII',
            'Region IX',
            'Region X',
            'Region XI',
            'Region XII',
            'CAR',
            'CARAGA',
            'BARMM',
          ],
        ),
        SurveyQuestion(
          id: 'service',
          question: 'Service Availed',
          type: QuestionType.dropdown,
          isRequired: true,
          options: [
            'Business Permit',
            'Building Permit',
            'Barangay Clearance',
            'Civil Registry',
            'Tax Payment',
            'Health Certificate',
            'Other',
          ],
        ),
      ],
    ),
    SurveySection(
      id: 'cc',
      title: "Citizen's Charter Awareness",
      description: 'Awareness of the Citizen\'s Charter',
      isRequired: true,
      questions: [
        SurveyQuestion(
          id: 'cc1',
          question:
              'Which of the following best describes your awareness of a CC?',
          type: QuestionType.radio,
          isRequired: true,
          options: [
            'I know what a CC is and I saw this office\'s CC',
            'I know what a CC is but I did NOT see this office\'s CC',
            'I learned of the CC only when I saw this office\'s CC',
            'I do not know what a CC is and I did not see one in this office',
          ],
        ),
        SurveyQuestion(
          id: 'cc2',
          question:
              'If aware of CC, would you say that the CC of this office was...?',
          type: QuestionType.radio,
          isRequired: false,
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
          question:
              'If aware of CC, how much did the CC help you in your transaction?',
          type: QuestionType.radio,
          isRequired: false,
          options: [
            'Helped very much',
            'Somewhat helped',
            'Did not help',
            'Not Applicable',
          ],
        ),
      ],
    ),
    SurveySection(
      id: 'sqd',
      title: 'Service Quality Dimensions',
      description: 'Rate your experience with the service (1-5 scale)',
      isRequired: true,
      questions: [
        SurveyQuestion(
          id: 'sqd0',
          question: 'I am satisfied with the service that I availed.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd1',
          question: 'I spent a reasonable amount of time for my transaction.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd2',
          question:
              'The office followed the transaction\'s requirements and steps based on the information provided.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd3',
          question:
              'The steps (including payment) I needed to do for my transaction were easy and simple.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd4',
          question:
              'I easily found information about my transaction from the office or its website.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd5',
          question: 'I paid a reasonable amount of fees for my transaction.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd6',
          question:
              'I feel the office was fair to everyone, or "walang palakasan," during my transaction.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd7',
          question:
              'I was treated courteously by the staff, and (if asked for help) the staff was helpful.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
        SurveyQuestion(
          id: 'sqd8',
          question:
              'I got what I needed from the government office, or (if denied) denial of request was sufficiently explained to me.',
          type: QuestionType.scale,
          isRequired: true,
          options: [],
        ),
      ],
    ),
    SurveySection(
      id: 'feedback',
      title: 'Additional Feedback',
      description: 'Optional comments and suggestions',
      isRequired: false,
      questions: [
        SurveyQuestion(
          id: 'suggestions',
          question:
              'Suggestions on how we can further improve our services (optional):',
          type: QuestionType.text,
          isRequired: false,
          options: [],
        ),
      ],
    ),
  ];

  int? _expandedSectionIndex;
  int? _editingQuestionIndex;
  String? _editingSectionId;
  bool _isEditingMetadata = false;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Survey Metadata Card
          _buildMetadataCard(),
          const SizedBox(height: 24),

          // Sections
          Text(
            'Survey Sections',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Section list
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sections.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _sections.removeAt(oldIndex);
                _sections.insert(newIndex, item);
                _hasChanges = true;
              });
            },
            itemBuilder: (context, index) {
              return _buildSectionCard(_sections[index], index);
            },
          ),

          const SizedBox(height: 16),

          // Add Section Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add_box_outlined),
              label: Text('Add New Section', style: GoogleFonts.poppins()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Survey Editor',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Customize your survey questions and structure',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (_hasChanges)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Unsaved changes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            OutlinedButton.icon(
              onPressed: _previewSurvey,
              icon: const Icon(Icons.preview),
              label: Text('Preview', style: GoogleFonts.poppins()),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _hasChanges ? _saveSurvey : null,
              icon: const Icon(Icons.save),
              label: Text('Save Changes', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Survey Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingMetadata ? Icons.check : Icons.edit,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingMetadata = !_isEditingMetadata;
                    });
                  },
                  tooltip: _isEditingMetadata ? 'Done' : 'Edit',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditingMetadata) ...[
              TextField(
                controller: TextEditingController(text: _surveyTitle),
                decoration: InputDecoration(
                  labelText: 'Survey Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _surveyTitle = value;
                  _hasChanges = true;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: _surveyDescription),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _surveyDescription = value;
                  _hasChanges = true;
                },
              ),
            ] else ...[
              Text(
                _surveyTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _surveyDescription,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetadataStat(
                  'Sections',
                  _sections.length.toString(),
                  Icons.folder_outlined,
                ),
                const SizedBox(width: 24),
                _buildMetadataStat(
                  'Questions',
                  _sections
                      .fold<int>(0, (sum, s) => sum + s.questions.length)
                      .toString(),
                  Icons.help_outline,
                ),
                const SizedBox(width: 24),
                _buildMetadataStat(
                  'Required',
                  _sections
                      .fold<int>(
                        0,
                        (sum, s) =>
                            sum + s.questions.where((q) => q.isRequired).length,
                      )
                      .toString(),
                  Icons.star_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSectionCard(SurveySection section, int sectionIndex) {
    final isExpanded = _expandedSectionIndex == sectionIndex;

    return Card(
      key: ValueKey(section.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isExpanded ? 3 : 1,
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSectionIndex = isExpanded ? null : sectionIndex;
                _editingQuestionIndex = null;
                _editingSectionId = null;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.drag_handle, color: Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${sectionIndex + 1}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                section.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (section.isRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Required',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${section.questions.length} questions',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editSection(section, sectionIndex),
                    tooltip: 'Edit Section',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _deleteSection(sectionIndex),
                    tooltip: 'Delete Section',
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Questions List
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: section.questions.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = section.questions.removeAt(oldIndex);
                        section.questions.insert(newIndex, item);
                        _hasChanges = true;
                      });
                    },
                    itemBuilder: (context, qIndex) {
                      final question = section.questions[qIndex];
                      final isEditing =
                          _editingSectionId == section.id &&
                          _editingQuestionIndex == qIndex;
                      return _buildQuestionItem(
                        question,
                        qIndex,
                        section,
                        isEditing,
                        key: ValueKey(question.id),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Add Question Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _addQuestion(section),
                      icon: const Icon(Icons.add),
                      label: Text('Add Question', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionItem(
    SurveyQuestion question,
    int qIndex,
    SurveySection section,
    bool isEditing, {
    required Key key,
  }) {
    if (isEditing) {
      return _buildQuestionEditor(question, qIndex, section, key: key);
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.drag_indicator, size: 20, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTypeColor(question.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                question.type.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: _getTypeColor(question.type),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.question,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (question.isRequired)
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (question.options.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      question.options.take(3).join(' • ') +
                          (question.options.length > 3
                              ? ' • +${question.options.length - 3} more'
                              : ''),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () {
                setState(() {
                  _editingSectionId = section.id;
                  _editingQuestionIndex = qIndex;
                });
              },
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade400,
              ),
              onPressed: () => _deleteQuestion(section, qIndex),
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionEditor(
    SurveyQuestion question,
    int qIndex,
    SurveySection section, {
    required Key key,
  }) {
    final questionController = TextEditingController(text: question.question);
    final optionControllers = question.options
        .map((o) => TextEditingController(text: o))
        .toList();
    var selectedType = question.type;
    var isRequired = question.isRequired;

    return StatefulBuilder(
      key: key,
      builder: (context, setLocalState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Editing Question',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingQuestionIndex = null;
                          _editingSectionId = null;
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final options = optionControllers
                            .map((c) => c.text)
                            .where((t) => t.isNotEmpty)
                            .toList();

                        setState(() {
                          section.questions[qIndex] = SurveyQuestion(
                            id: question.id,
                            question: questionController.text,
                            type: selectedType,
                            isRequired: isRequired,
                            options: options,
                          );
                          _editingQuestionIndex = null;
                          _editingSectionId = null;
                          _hasChanges = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question Text
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Type and Required Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<QuestionType>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: QuestionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.displayName,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setLocalState(() => selectedType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isRequired,
                          onChanged: (value) {
                            setLocalState(() => isRequired = value ?? false);
                          },
                          activeColor: AppColors.secondary,
                        ),
                        Text(
                          'Required',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),

                // Options (if applicable)
                if (selectedType == QuestionType.radio ||
                    selectedType == QuestionType.checkbox ||
                    selectedType == QuestionType.dropdown) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Options',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(optionControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: optionControllers[i],
                              decoration: InputDecoration(
                                hintText: 'Option ${i + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              size: 20,
                              color: Colors.red.shade400,
                            ),
                            onPressed: optionControllers.length > 1
                                ? () {
                                    setLocalState(() {
                                      optionControllers.removeAt(i);
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () {
                      setLocalState(() {
                        optionControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Add Option',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.radio:
        return Colors.blue;
      case QuestionType.checkbox:
        return Colors.purple;
      case QuestionType.text:
        return Colors.teal;
      case QuestionType.scale:
        return Colors.orange;
      case QuestionType.number:
        return Colors.green;
      case QuestionType.dropdown:
        return Colors.indigo;
    }
  }

  void _addSection() {
    showDialog(
      context: context,
      builder: (context) => _SectionEditorDialog(
        onSave: (section) {
          setState(() {
            _sections.add(section);
            _expandedSectionIndex = _sections.length - 1;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _editSection(SurveySection section, int index) {
    showDialog(
      context: context,
      builder: (context) => _SectionEditorDialog(
        section: section,
        onSave: (updatedSection) {
          setState(() {
            _sections[index] = SurveySection(
              id: section.id,
              title: updatedSection.title,
              description: updatedSection.description,
              isRequired: updatedSection.isRequired,
              questions: section.questions,
            );
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _deleteSection(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Section',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${_sections[index].title}"? This will also delete all ${_sections[index].questions.length} questions in this section.',
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
                _sections.removeAt(index);
                if (_expandedSectionIndex == index) {
                  _expandedSectionIndex = null;
                } else if (_expandedSectionIndex != null &&
                    _expandedSectionIndex! > index) {
                  _expandedSectionIndex = _expandedSectionIndex! - 1;
                }
                _hasChanges = true;
              });
              Navigator.pop(context);
              _showSuccessSnackbar('Section deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addQuestion(SurveySection section) {
    final newQuestion = SurveyQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: 'New Question',
      type: QuestionType.radio,
      isRequired: false,
      options: ['Option 1'],
    );

    setState(() {
      section.questions.add(newQuestion);
      _editingSectionId = section.id;
      _editingQuestionIndex = section.questions.length - 1;
      _hasChanges = true;
    });
  }

  void _deleteQuestion(SurveySection section, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Question',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
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
                section.questions.removeAt(index);
                _hasChanges = true;
              });
              Navigator.pop(context);
              _showSuccessSnackbar('Question deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _previewSurvey() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.preview, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Survey Preview',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _surveyTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _surveyDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._sections.map(
                        (section) => _buildPreviewSection(section),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection(SurveySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  section.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                if (section.isRequired) ...[
                  const SizedBox(width: 8),
                  Text('*', style: TextStyle(color: Colors.red.shade700)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...section.questions.map((q) => _buildPreviewQuestion(q)),
        ],
      ),
    );
  }

  Widget _buildPreviewQuestion(SurveyQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.question,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (question.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPreviewInput(question),
        ],
      ),
    );
  }

  Widget _buildPreviewInput(SurveyQuestion question) {
    switch (question.type) {
      case QuestionType.radio:
        return Column(
          children: question.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case QuestionType.checkbox:
        return Column(
          children: question.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case QuestionType.scale:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (i) {
            final emojis = ['😠', '😕', '😐', '🙂', '😄'];
            return Column(
              children: [
                Text(emojis[i], style: const TextStyle(fontSize: 24)),
                Text(
                  '${i + 1}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            );
          }),
        );

      case QuestionType.text:
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(8),
          child: Text(
            'Text input...',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        );

      case QuestionType.number:
        return Container(
          height: 40,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '0',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        );

      case QuestionType.dropdown:
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select an option...',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        );
    }
  }

  void _saveSurvey() {
    setState(() {
      _hasChanges = false;
    });
    _showSuccessSnackbar('Survey saved successfully!');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Section Editor Dialog
class _SectionEditorDialog extends StatefulWidget {
  final SurveySection? section;
  final Function(SurveySection) onSave;

  const _SectionEditorDialog({this.section, required this.onSave});

  @override
  State<_SectionEditorDialog> createState() => _SectionEditorDialogState();
}

class _SectionEditorDialogState extends State<_SectionEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.section?.description ?? '',
    );
    _isRequired = widget.section?.isRequired ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.section == null ? 'Add Section' : 'Edit Section',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Section Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() => _isRequired = value ?? true);
                  },
                  activeColor: AppColors.secondary,
                ),
                Text('Section is required', style: GoogleFonts.poppins()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please enter a section title',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final section = SurveySection(
              id:
                  widget.section?.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              isRequired: _isRequired,
              questions: widget.section?.questions ?? [],
            );

            widget.onSave(section);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: Text('Save', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

// Data Models
enum QuestionType {
  radio,
  checkbox,
  text,
  scale,
  number,
  dropdown;

  String get displayName {
    switch (this) {
      case QuestionType.radio:
        return 'Single Choice';
      case QuestionType.checkbox:
        return 'Multiple Choice';
      case QuestionType.text:
        return 'Text';
      case QuestionType.scale:
        return 'Rating Scale';
      case QuestionType.number:
        return 'Number';
      case QuestionType.dropdown:
        return 'Dropdown';
    }
  }
}

class SurveySection {
  final String id;
  String title;
  String description;
  bool isRequired;
  final List<SurveyQuestion> questions;

  SurveySection({
    required this.id,
    required this.title,
    required this.description,
    required this.isRequired,
    required this.questions,
  });
}

class SurveyQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final bool isRequired;
  final List<String> options;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.isRequired,
    required this.options,
  });
}
