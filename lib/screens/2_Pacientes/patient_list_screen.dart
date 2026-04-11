// Arquivo: lib/screens/2_Pacientes/patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/add_edit_patient_screen.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/patient_details_screen.dart';

// Importação do Design System
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<Patient>> _patientsFuture;
  final TextEditingController _searchController = TextEditingController();
  
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  List<bool> _showItems = [];
  bool _isSearching = false;

  // --- VARIÁVEIS PARA O MODO DE EXCLUSÃO ---
  bool _isDeleteMode = false;
  final Set<int> _selectedPatientIds = {};

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _patientsFuture = DatabaseHelper.instance.queryAllRows();
      _allPatients = [];
      _filteredPatients = [];
      _searchController.clear();
      
      // Reseta o modo de exclusão ao recarregar a lista
      _isDeleteMode = false;
      _selectedPatientIds.clear();
    });
  }

  void _startAnimation(List<Patient> patients) {
    if (!mounted) return;
    _showItems = List.generate(patients.length, (_) => false);
    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < patients.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted && i < _showItems.length) {
            setState(() {
              _showItems[i] = true;
            });
          }
        });
      }
    });
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredPatients = _allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query);
      }).toList();
      _startAnimation(_filteredPatients);
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  // --- LÓGICA DE EXCLUSÃO MÚLTIPLA E SELEÇÃO ---

  void _handleDeleteButtonPress() {
    setState(() {
      if (_isDeleteMode && _selectedPatientIds.isNotEmpty) {
        // Se já está no modo e tem itens selecionados, pede confirmação
        _showDeleteConfirmationDialog();
      } else {
        // Alterna o modo visual (entra ou sai)
        _isDeleteMode = !_isDeleteMode;
        // Se saiu do modo, limpa a seleção
        if (!_isDeleteMode) {
          _selectedPatientIds.clear();
        }
      }
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedPatientIds.contains(id)) {
        _selectedPatientIds.remove(id);
      } else {
        _selectedPatientIds.add(id);
      }
    });
  }

  Future<void> _deleteSelectedPatients() async {
    for (int id in _selectedPatientIds) {
      await DatabaseHelper.instance.delete(id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedPatientIds.length} ficha(s) apagada(s) com sucesso.'),
          backgroundColor: AssessmentColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadPatients(); // Recarrega a lista
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão', style: AssessmentTextStyles.sectionTitle),
          content: Text('Tem certeza de que deseja apagar ${_selectedPatientIds.length} ficha(s)? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: AssessmentColors.textSecondary)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Apagar', style: TextStyle(color: AssessmentColors.errorRed)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSelectedPatients();
    }
  }
  
  void _navigateToAddEditScreen({Patient? patient}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditPatientScreen(patient: patient)),
    ).then((_) => _loadPatients());
  }

  void _navigateToDetailsScreen(Patient patient) {
    // Se estiver em modo de deleção, o clique seleciona o item em vez de abrir detalhes
    if (_isDeleteMode) {
      _toggleSelection(patient.id!);
      return;
    }

     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PatientDetailsScreen(initialPatient: patient)),
    ).then((_) => _loadPatients());
  }

  // WIDGETS DE CONSTRUÇÃO DA UI
  //----------------------------------------------------------------------------
  
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        style: AssessmentTextStyles.itemTitle,
        decoration: InputDecoration(
          hintText: 'Buscar paciente por nome...',
          hintStyle: AssessmentTextStyles.instructionText,
          prefixIcon: Icon(Icons.search, size: 22, color: AssessmentColors.primaryBlue),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20, color: AssessmentColors.textSecondary),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            // Borda sutil
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          // Fundo branco limpo para o campo de busca
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPatientListItem(Patient patient, int index) {
    final bool show = index < _showItems.length && _showItems[index];
    final bool isSelected = _selectedPatientIds.contains(patient.id);

    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: show ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          decoration: BoxDecoration(
            // Fundo transparente, mas com destaque leve se selecionado
            color: isSelected && _isDeleteMode 
                ? AssessmentColors.errorRed.withOpacity(0.05) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            // Borda sutil ou vermelha se selecionado
            border: isSelected && _isDeleteMode
                ? Border.all(color: AssessmentColors.errorRed.withOpacity(0.5))
                : Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
          ),
          child: InkWell(
            onTap: () => _navigateToDetailsScreen(patient),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Row(
                children: [
                  // --- LÓGICA DE EXIBIÇÃO (Avatar vs Checkbox) ---
                  if (_isDeleteMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AssessmentColors.errorRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? value) => _toggleSelection(patient.id!),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AssessmentColors.primaryBlue.withOpacity(0.1),
                        child: Text(
                          patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: AssessmentColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  
                  // Informações
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: AssessmentTextStyles.itemTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: AssessmentColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              patient.birthDate,
                              style: AssessmentTextStyles.itemSubtitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Ações Rápidas (Apenas se não estiver no modo de exclusão)
                  if (!_isDeleteMode)
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: AssessmentColors.primaryBlue),
                      onPressed: () => _navigateToAddEditScreen(patient: patient),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    final patients = _isSearching ? _filteredPatients : _allPatients;

    if (_isSearching && patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: AssessmentColors.textDisabled),
            const SizedBox(height: 16),
            const Text('Nenhum paciente encontrado', style: AssessmentTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text('Para a busca: "${_searchController.text}"', style: AssessmentTextStyles.itemSubtitle),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPatients,
      color: AssessmentColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return _buildPatientListItem(patient, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AssessmentColors.lightBlue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_add_outlined, size: 60, color: AssessmentColors.primaryBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum paciente cadastrado',
            style: AssessmentTextStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Clique no botão "+" abaixo para iniciar a sua primeira avaliação.',
              textAlign: TextAlign.center,
              style: AssessmentTextStyles.instructionText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        // Se estiver no modo delete, o título muda
        title: Text(_isDeleteMode ? 'Selecionados: ${_selectedPatientIds.length}' : 'Fichas de Pacientes'),
        // Fundo transparente
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        // Botão de voltar fecha o modo de exclusão se estiver ativo
        leading: _isDeleteMode 
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isDeleteMode = false;
                    _selectedPatientIds.clear();
                  });
                },
              )
            : null,
        // Removido actions da AppBar (Lixeira saiu daqui)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: _buildSearchField(),
        ),
      ),
      body: FutureBuilder<List<Patient>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AssessmentColors.primaryBlue));
          } 
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: AssessmentColors.errorRed)));
          } 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          if (_allPatients.isEmpty && snapshot.hasData) {
            _allPatients = snapshot.data!;
            _filteredPatients = List.from(_allPatients);
            WidgetsBinding.instance.addPostFrameCallback((_) {
               _startAnimation(_allPatients);
            });
          }

          return _buildPatientList();
        },
      ),
      
      // --- CONFIGURAÇÃO DOS BOTÕES FLUTUANTES ---
      // Usamos centerFloat para ter espaço para colocar a Row
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Botão de LIXEIRA (Canto Inferior Esquerdo)
            FloatingActionButton(
              heroTag: 'deleteBtn', // Necessário tag única quando há múltiplos FABs
              tooltip: 'Apagar Fichas',
              backgroundColor: AssessmentColors.errorRed, // Vermelho
              onPressed: _handleDeleteButtonPress,
              child: Icon(
                // Muda para check se tiver itens para confirmar
                (_isDeleteMode && _selectedPatientIds.isNotEmpty) ? Icons.check : Icons.delete_outline, 
                color: Colors.white,
              ),
            ),

            // 2. Botão de ADICIONAR (Canto Inferior Direito)
            // Só aparece se NÃO estiver no modo de exclusão para não poluir
            if (!_isDeleteMode)
              FloatingActionButton(
                heroTag: 'addBtn', // Necessário tag única
                tooltip: 'Adicionar Novo Paciente',
                backgroundColor: AssessmentColors.primaryBlue,
                onPressed: () => _navigateToAddEditScreen(),
                child: const Icon(Icons.add),
              )
            else
              // Espaçador para manter o botão da esquerda no lugar se o da direita sumir
              const SizedBox(width: 56), 
          ],
        ),
      ),
    );
  }
}