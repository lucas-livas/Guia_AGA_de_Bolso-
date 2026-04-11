// Arquivo: lib/screens/2_Pacientes/add_edit_patient_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Imports do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/widgets/medication_manager_widget.dart';

// Enum para controlar as etapas do formulário
enum _FormStep { personal, complementary, anamnesis }

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controle de Estado
  _FormStep _currentStep = _FormStep.personal;

  // Getters para facilitar a leitura da navegação
  int get _stepIndex => _FormStep.values.indexOf(_currentStep);
  int get _totalSteps => _FormStep.values.length;
  bool get _isLastStep => _currentStep == _FormStep.anamnesis;

  // --- VARIÁVEIS DE CONTROLE DE UI ---
  String? _selectedGender; 

  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Não Informado'];

  // --- LISTAS DINÂMICAS (Mudam com o Gênero) ---

  // 1. Estado Civil (Dinâmico)
  List<String> get _maritalStatusOptions {
    if (_selectedGender == 'Masculino') {
      return ['Solteiro', 'Casado', 'Divorciado', 'Viúvo', 'Separado', 'União Estável'];
    } else if (_selectedGender == 'Feminino') {
      return ['Solteira', 'Casada', 'Divorciada', 'Viúva', 'Separada', 'União Estável'];
    } else {
      return ['Solteiro(a)', 'Casado(a)', 'Divorciado(a)', 'Viúvo(a)', 'Separado(a)', 'União Estável'];
    }
  }

  // 2. Profissões (Dinâmico)
  List<String> get _professionOptions {
    if (_selectedGender == 'Masculino') {
      return [
        'Aposentado', 'Professor', 'Engenheiro', 'Advogado', 'Médico', 'Arquiteto', 
        'Comerciante', 'Motorista', 'Agricultor', 'Estudante', 'Autônomo', 'Funcionário Público', 'Funcionário Publico Aposentado',
        'Pedreiro', 'Eletricista', 'Mecânico', 'Pintor', 'Porteiro', 'Vendedor'
      ];
    } else if (_selectedGender == 'Feminino') {
      return [
        'Aposentada', 'Professora', 'Engenheira', 'Advogada', 'Médica', 'Arquiteta', 
        'Comerciante', 'Motorista', 'Agricultora', 'Estudante', 'Autônoma', 'Funcionária Pública', 'Funcionária Publica Aposentada',
        'Diarista', 'Empregada Doméstica', 'Costureira', 'Cozinheira', 'Vendedora'
      ];
    } else {
      return [
        'Aposentado(a)', 'Professor(a)', 'Engenheiro(a)', 'Advogado(a)', 'Médico(a)', 'Arquiteto(a)', 
        'Comerciante', 'Motorista', 'Agricultor(a)', 'Estudante', 'Autônomo(a)', 'Funcionário(a) Público(a)', 'Funcionário(a) Publico(a) Aposentado(a)',
        'Vendedor(a)', 'Cozinheiro(a)'
      ];
    }
  }

  // --- LISTAS ESTÁTICAS (Fixas, padrão IBGE/Comum) ---

  // 3. Escolaridade
  final List<String> _educationOptions = [
    'Analfabeto',
    'Alfabetizado',
    'Ensino Fundamental Incompleto',
    'Ensino Fundamental Completo',
    'Ensino Médio Incompleto',
    'Ensino Médio Completo',
    'Ensino Superior Incompleto',
    'Ensino Superior Completo',
    'Pós-graduação',
    'Mestrado',
    'Doutorado',
  ];

  // 4. Nacionalidade
  final List<String> _nationalityOptions = [
    'Brasileiro', 'Estrangeiro', 'Naturalizado',
  ];

  // 5. Naturalidade (Gentílicos dos Estados)
  final List<String> _naturalnessOptions = [
    'Acreano', 'Alagoano', 'Amapaense', 'Amazonense', 'Baiano', 'Brasiliense', 
    'Capixaba', 'Catarinense', 'Cearense', 'Fluminense', 'Gaúcho', 'Goiano', 
    'Maranhense', 'Mato-grossense', 'Mineiro', 'Paraense', 'Paraibano', 'Paranaense', 
    'Paulista', 'Pernambucano', 'Piauiense', 'Potiguar', 'Rondoniense', 'Roraimense', 
    'Sergipano', 'Sul-mato-grossense', 'Tocantinense'
  ];

  // 6. Raça / Cor (Padrão IBGE)
  final List<String> _raceOptions = [
    'Branca', 'Preta', 'Parda', 'Amarela', 'Indígena'
  ];

  // --- CONTROLADORES ---

  // 1. Dados Pessoais
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // 2. Dados Complementares
  final _occupationController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _raceController = TextEditingController();

  // 3. Anamnese
  final _chiefComplaintController = TextEditingController();
  final _hdaController = TextEditingController();
  final _pastMedicalHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();
  final _homeEnvironmentController = TextEditingController();
  final _notesController = TextEditingController();
  
  // JSON de Medicamentos
  String _medicationJson = ''; 

  // Agrupamento para descarte otimizado (Dispose)
  List<TextEditingController> get _allControllers => [
    _nameController, _birthDateController, _genderController, _maritalStatusController, _emergencyContactController,
    _occupationController, _educationLevelController, _nationalityController, _placeOfBirthController, _raceController,
    _chiefComplaintController, _hdaController, _pastMedicalHistoryController, _socialHistoryController, 
    _homeEnvironmentController, _notesController
  ];

  // --- CICLO DE VIDA ---

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _loadPatientData(widget.patient!);
    } else {
      _selectedGender = 'Não Informado';
      _genderController.text = 'Não Informado';
    }
  }

  @override
  void dispose() {
    for (var controller in _allControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadPatientData(Patient p) {
    // 1. Pessoais
    _nameController.text = p.name;
    _birthDateController.text = p.birthDate;
    
    _genderController.text = p.gender;
    if (_genderOptions.contains(p.gender)) {
      _selectedGender = p.gender;
    } else {
      _selectedGender = 'Não Informado';
    }

    _maritalStatusController.text = p.maritalStatus;
    _emergencyContactController.text = p.emergencyContact;
    
    // 2. Complementares
    _occupationController.text = p.occupation;
    _educationLevelController.text = p.educationLevel;
    _nationalityController.text = p.nationality;
    _placeOfBirthController.text = p.placeOfBirth;
    _raceController.text = p.race;
    
    // 3. Anamnese
    _chiefComplaintController.text = p.chiefComplaint;
    _hdaController.text = p.hda;
    _pastMedicalHistoryController.text = p.pastMedicalHistory;
    _socialHistoryController.text = p.socialHistory;
    _homeEnvironmentController.text = p.homeEnvironment;
    _notesController.text = p.notes;
    
    _medicationJson = p.medicationList; 
  }

  // --- LÓGICA DE VALIDAÇÃO ---

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    if (value.length != 10) return 'Data incompleta (DD/MM/AAAA)';

    try {
      final parts = value.split('/');
      if (parts.length != 3) return 'Formato inválido';

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (month < 1 || month > 12) return 'Mês inválido';
      if (day < 1 || day > 31) return 'Dia inválido';
      if (year < 1900) return 'Ano inválido';

      final tempDate = DateTime(year, month, day);
      if (tempDate.day != day || tempDate.month != month || tempDate.year != year) {
        return 'Data inexistente';
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (tempDate.isAfter(today)) return 'Data futura não permitida';

    } catch (e) {
      return 'Data inválida';
    }
    return null;
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      _handleValidationError();
      return;
    }

    final patient = Patient(
      id: widget.patient?.id,
      name: _nameController.text,
      birthDate: _birthDateController.text,
      gender: _genderController.text,
      maritalStatus: _maritalStatusController.text,
      emergencyContact: _emergencyContactController.text,
      occupation: _occupationController.text,
      educationLevel: _educationLevelController.text,
      nationality: _nationalityController.text,
      placeOfBirth: _placeOfBirthController.text,
      race: _raceController.text,
      chiefComplaint: _chiefComplaintController.text,
      hda: _hdaController.text,
      pastMedicalHistory: _pastMedicalHistoryController.text,
      medicationList: _medicationJson,
      socialHistory: _socialHistoryController.text,
      homeEnvironment: _homeEnvironmentController.text,
      notes: _notesController.text,
      isDeleted: widget.patient?.isDeleted ?? 0,
      deletedAt: widget.patient?.deletedAt,
    );

    if (widget.patient == null) {
      await DatabaseHelper.instance.insert(patient);
    } else {
      await DatabaseHelper.instance.update(patient);
    }

    if (mounted) {
      Navigator.pop(context);
      _showSnack(widget.patient == null ? 'Paciente adicionado!' : 'Dados atualizados!', AssessmentColors.successGreen);
    }
  }

  void _handleValidationError() {
    if (_nameController.text.isEmpty || _validateDate(_birthDateController.text) != null) {
      setState(() => _currentStep = _FormStep.personal);
    }
    _showSnack('Por favor, verifique os campos obrigatórios.', Colors.red);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- NAVEGAÇÃO ---

  void _nextStep() {
    if (_currentStep == _FormStep.personal) {
      bool hasNameError = _nameController.text.trim().isEmpty;
      bool hasDateError = _validateDate(_birthDateController.text) != null;

      if (hasNameError || hasDateError) {
        _showSnack('Verifique o Nome e a Data de Nascimento.', Colors.orange);
        _formKey.currentState!.validate(); 
        return;
      }
    }

    if (!_isLastStep) {
      FocusScope.of(context).unfocus();
      setState(() {
        _currentStep = _FormStep.values[_stepIndex + 1];
      });
    } else {
      _savePatient();
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_stepIndex > 0) {
      setState(() {
        _currentStep = _FormStep.values[_stepIndex - 1];
      });
    } else {
      Navigator.pop(context);
    }
  }

  // --- WIDGETS DE CONSTRUÇÃO UI ---

  InputDecoration _getInputDecoration({required String label, String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: icon != null ? Icon(icon, color: AssessmentColors.primaryBlue.withOpacity(0.7), size: 22) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AssessmentColors.primaryBlue, width: 2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool isRequired = false, 
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: _getInputDecoration(label: label, hint: hint, icon: icon),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator ?? (isRequired ? (value) => (value == null || value.trim().isEmpty) ? 'Campo obrigatório' : null : null),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        decoration: _getInputDecoration(label: label, icon: icon),
        isExpanded: true,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<String>(
            initialValue: TextEditingValue(text: controller.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return options.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              if (controller.text != textController.text && textController.text.isNotEmpty) {
                 controller.text = textController.text;
              }
              textController.addListener(() {
                controller.text = textController.text;
              });

              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
                decoration: _getInputDecoration(label: label, icon: icon),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomHeader() {
    String title = "";
    String subtitle = "";

    switch (_currentStep) {
      case _FormStep.personal:
        title = "Dados Pessoais";
        subtitle = "Identificação Básica";
        break;
      case _FormStep.complementary:
        title = "Dados Complementares";
        subtitle = "Social e Escolaridade";
        break;
      case _FormStep.anamnesis:
        title = "Anamnese";
        subtitle = "Histórico e Medicamentos";
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Passo ${_stepIndex + 1} de $_totalSteps", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const Spacer(),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: (_stepIndex + 1) / _totalSteps,
                  backgroundColor: Colors.grey.shade200,
                  color: AssessmentColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case _FormStep.personal:
        return Column(
          children: [
            _buildTextField(controller: _nameController, label: 'Nome Completo', icon: Icons.person_outline, isRequired: true),
            _buildTextField(
              controller: _birthDateController, label: 'Data de Nascimento', hint: 'DD/MM/AAAA', icon: Icons.calendar_today, 
              keyboardType: TextInputType.number,
              inputFormatters: [DateTextFormatter()],
              validator: _validateDate, 
            ),
            
            _buildDropdownField(
              label: 'Sexo / Gênero',
              icon: Icons.wc,
              value: _selectedGender,
              items: _genderOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                  _genderController.text = newValue ?? '';
                });
              },
            ),

            _buildDropdownField(
              label: 'Estado Civil',
              icon: Icons.favorite_border,
              value: _maritalStatusOptions.contains(_maritalStatusController.text) ? _maritalStatusController.text : null,
              items: _maritalStatusOptions,
              onChanged: (newValue) {
                setState(() {
                  _maritalStatusController.text = newValue ?? '';
                });
              },
            ),
            _buildTextField(controller: _emergencyContactController, label: 'Contato de Emergência', icon: Icons.phone, keyboardType: TextInputType.text),
          ],
        );
      case _FormStep.complementary:
        return Column(
          children: [
            // 1. Profissão (Autocomplete - Dinâmico)
            _buildAutocompleteField(
              controller: _occupationController,
              label: 'Profissão',
              icon: Icons.work_outline,
              options: _professionOptions,
            ),

            // 2. Escolaridade (Autocomplete - Estático)
            _buildAutocompleteField(
              controller: _educationLevelController,
              label: 'Escolaridade',
              icon: Icons.school_outlined,
              options: _educationOptions,
            ),

            // 3. Nacionalidade (Autocomplete - Estático)
            _buildAutocompleteField(
              controller: _nationalityController,
              label: 'Nacionalidade',
              icon: Icons.public,
              options: _nationalityOptions,
            ),

            // 4. Naturalidade (Autocomplete - Estático)
            _buildAutocompleteField(
              controller: _placeOfBirthController,
              label: 'Naturalidade',
              icon: Icons.location_on_outlined,
              options: _naturalnessOptions,
            ),

            // 5. Raça / Cor (Autocomplete - Estático)
            _buildAutocompleteField(
              controller: _raceController,
              label: 'Raça / Cor',
              icon: Icons.palette_outlined,
              options: _raceOptions,
            ),
          ],
        );
      case _FormStep.anamnesis:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("HISTÓRICO CLÍNICO", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue, letterSpacing: 1.1)),
            ),
            _buildTextField(controller: _chiefComplaintController, label: 'Queixa Principal (QP)', icon: Icons.chat_bubble_outline, maxLines: 2),
            _buildTextField(controller: _hdaController, label: 'História da Doença Atual (HDA)', icon: Icons.history, maxLines: 3),
            _buildTextField(controller: _pastMedicalHistoryController, label: 'História Patológica Pregressa (HPP)', icon: Icons.medical_services_outlined, maxLines: 3),

            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("MEDICAMENTOS EM USO", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue, letterSpacing: 1.1)),
            ),
            MedicationManagerWidget(
              initialJson: _medicationJson,
              onChanged: (newJson) => _medicationJson = newJson,
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("SOCIAL E AMBIENTAL", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue, letterSpacing: 1.1)),
            ),
            _buildTextField(controller: _socialHistoryController, label: 'Histórico Social', icon: Icons.people_outline, maxLines: 3),
            _buildTextField(controller: _homeEnvironmentController, label: 'Ambiente Domiciliar', icon: Icons.home_outlined, maxLines: 3),
            
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text("OUTRAS OBSERVAÇÕES", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue, letterSpacing: 1.1)),
            ),
            _buildTextField(controller: _notesController, label: 'Notas Gerais', icon: Icons.note_alt_outlined, maxLines: 3),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Novo Paciente' : 'Editar Paciente'),
        backgroundColor: Colors.white,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCustomHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (_stepIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('VOLTAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_stepIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLastStep ? AssessmentColors.successGreen : AssessmentColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: Text(
                      _isLastStep ? 'SALVAR FICHA' : 'CONTINUAR',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASSE DE FORMATAÇÃO VISUAL (DateTextFormatter) ---
class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. Remove tudo que não for número
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Limita a 8 dígitos (DDMMAAAA)
    if (text.length > 8) return oldValue;

    // 3. Reconstrói a string com as barras
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      newText += text[i];
      // Adiciona barra após o 2º número e o 4º número
      if ((i == 1 || i == 3) && i != text.length - 1) {
        newText += '/';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}