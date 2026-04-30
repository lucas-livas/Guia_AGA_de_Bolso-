// lib/screens/select_patient_screen.dart
// Tela para selecionar um paciente existente com busca e animações
// Usuário é direcionado a essa tela após apertar/comfirma o botão "Salvar" em qualquer avaliação
// Descrição: Permite ao usuário selecionar um paciente para salvar dados relacionados.
// caminho: o usuario apartir da "tela de salvar" Presente em todos os testes avaliações e escalas pode acessa essa tela para escolher o paciente desejado.

// Importações do Flutter
import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/patient_model.dart';
import 'add_edit_patient_screen.dart'; // <--- Import da tela de cadastro adicionado

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  late Future<List<Patient>> _patientsFuture;
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late List<bool> _showItems;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_onSearchChanged);
    _showItems = [];
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
    });
  }

  void _startAnimation(List<Patient> patients) {
    _showItems = List.generate(patients.length, (_) => false);
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < patients.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
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

    if (query.isEmpty) {
      setState(() {
        _filteredPatients = List.from(_allPatients);
        _isSearching = false;
      });
      _startAnimation(_allPatients);
    } else {
      setState(() {
        _filteredPatients = _allPatients.where((patient) {
          return patient.name.toLowerCase().contains(query);
        }).toList();
        _isSearching = true;
      });
      _startAnimation(_filteredPatients);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredPatients = List.from(_allPatients);
      _isSearching = false;
    });
    _startAnimation(_allPatients);
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar paciente por nome...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Color.fromARGB(179, 0, 0, 0)),
                onPressed: _clearSearch,
              )
            : const Icon(Icons.search, color: Color.fromARGB(179, 0, 0, 0)),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      cursorColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar pacientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadPatients,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 80, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(height: 16),
            const Text(
              'Nenhum paciente cadastrado',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre pacientes para começar a usar o sistema',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // Navega para a tela de Nova Ficha
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditPatientScreen(),
                  ),
                );

                // Se o usuário salvou um paciente, recarrega a lista para exibi-lo
                if (result == true) {
                  _loadPatients();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Primeiro Paciente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando pacientes...'),
        ],
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
            const Icon(Icons.search_off, size: 64, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(height: 16),
            const Text(
              'Nenhum paciente encontrado',
              style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 8),
            Text(
              'Busca: "${_searchController.text}"',
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Limpar busca'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: patients.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final patient = patients[index];

          if (index >= _showItems.length) {
            return const SizedBox.shrink();
          }

          return AnimatedOpacity(
            opacity: _showItems[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _showItems[index] ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: Icon(
                    Icons.person,
                    size: 35,
                    color: Theme.of(context).primaryColor
                  ),
                  title: Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  subtitle: _buildPatientSubtitle(patient),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Previne múltiplos cliques acidentais
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        Navigator.pop(context, patient);
                      }
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientSubtitle(Patient patient) {
    final List<String> infoParts = [];

    if (patient.birthDate.isNotEmpty) {
      infoParts.add('Nasc: ${patient.birthDate}');
    }

    if (patient.gender.isNotEmpty) {
      infoParts.add(patient.gender);
    }

    if (infoParts.isEmpty) {
      return const Text('Clique para selecionar');
    }

    return Text(
      infoParts.join(' • '),
      style: const TextStyle(fontSize: 12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _loadPatients,
        tooltip: 'Recarregar',
      ),
    ];
  }

  Widget _buildAppBarTitle() {
    if (_searchController.text.isNotEmpty) {
      return const Text('Buscar paciente');
    }

    final patientCount = _isSearching ? _filteredPatients.length : _allPatients.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Salvar para qual paciente?'),
        if (patientCount > 0)
          Text(
            '$patientCount paciente${patientCount != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSearchField(),
          ),
        ),
      ),
      body: FutureBuilder<List<Patient>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Error State
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // Success State - inicializa as listas
          if (_allPatients.isEmpty) {
            _allPatients = snapshot.data!;
            _filteredPatients = List.from(_allPatients);
            _startAnimation(_allPatients);
          }

          return _buildPatientList();
        },
      ),
    );
  }
}

// Classe para busca avançada (opcional)
class PatientSearchDelegate extends SearchDelegate<Patient?> {
  final List<Patient> patients;

  PatientSearchDelegate({required this.patients});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(suggestions, context);
  }

  Widget _buildSearchResults(List<Patient> results, BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(height: 16),
            const Text('Nenhum paciente encontrado'),
            const SizedBox(height: 8),
            Text(
              'Busca: "$query"',
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final patient = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(patient.name),
            subtitle: _buildPatientSubtitle(patient),
            onTap: () {
              close(context, patient);
            },
          ),
        );
      },
    );
  }

  Widget _buildPatientSubtitle(Patient patient) {
    final List<String> infoParts = [];

    if (patient.birthDate.isNotEmpty) {
      infoParts.add('Nasc: ${patient.birthDate}');
    }

    if (patient.gender.isNotEmpty) {
      infoParts.add(patient.gender);
    }

    if (infoParts.isEmpty) {
      return const Text('Clique para selecionar');
    }

    return Text(
      infoParts.join(' • '),
      style: const TextStyle(fontSize: 12),
    );
  }
}