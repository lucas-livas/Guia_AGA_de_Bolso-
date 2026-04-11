import 'package:flutter/material.dart';
import '../models/medication_data.dart';
import 'assessment_widgets.dart'; // Para usar as cores do tema

class MedicationManagerWidget extends StatefulWidget {
  final String initialJson;
  final ValueChanged<String> onChanged; // Retorna o JSON atualizado

  const MedicationManagerWidget({
    super.key,
    required this.initialJson,
    required this.onChanged,
  });

  @override
  State<MedicationManagerWidget> createState() => _MedicationManagerWidgetState();
}

class _MedicationManagerWidgetState extends State<MedicationManagerWidget> {
  List<PrescribedMedication> _medications = [];

  @override
  void initState() {
    super.initState();
    // Tenta decodificar o JSON. Se falhar (texto antigo), inicia vazio.
    _medications = PrescribedMedication.decodeList(widget.initialJson);
  }

  void _updateParent() {
    final json = PrescribedMedication.encodeList(_medications);
    widget.onChanged(json);
  }

  void _addMedication(PrescribedMedication med) {
    setState(() {
      _medications.add(med);
      _updateParent();
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
      _updateParent();
    });
  }

  // --- Modal para Adicionar Medicamento ---
  void _showAddMedicationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMedicationForm(onSave: (med) {
        _addMedication(med);
        Navigator.pop(ctx);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lista de Cards dos Medicamentos já adicionados
        if (_medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: const Center(child: Text("Nenhum medicamento registrado.", style: TextStyle(color: Colors.grey))),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AssessmentColors.primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.medication, color: AssessmentColors.primaryBlue, size: 20),
                  ),
                  title: Text(med.drugName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${med.dosage} • ${med.presentation}\n${med.frequency} às ${med.time}"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AssessmentColors.errorRed),
                    onPressed: () => _removeMedication(index),
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 10),
        
        // Botão de Adicionar
        OutlinedButton.icon(
          onPressed: _showAddMedicationSheet,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Adicionar Medicamento"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: AssessmentColors.primaryBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

// --- Formulário Interno do Modal ---
class _AddMedicationForm extends StatefulWidget {
  final ValueChanged<PrescribedMedication> onSave;

  const _AddMedicationForm({required this.onSave});

  @override
  State<_AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<_AddMedicationForm> {
  final _nameCtrl = TextEditingController();
  final _presCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  
  DrugReference? _selectedDrugInfo;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: scrollController,
          children: [
            const Text("Novo Medicamento", style: AssessmentTextStyles.sectionTitle, textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // 1. Busca Automática (Autocomplete)
            Autocomplete<DrugReference>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<DrugReference>.empty();
                return DrugDatabase.allDrugs.where((DrugReference option) {
                  return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (DrugReference option) => option.name,
              onSelected: (DrugReference selection) {
                _nameCtrl.text = selection.name;
                setState(() => _selectedDrugInfo = selection);
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                // Sincroniza o controller interno do autocomplete com o nosso se necessário
                textEditingController.addListener(() {
                   _nameCtrl.text = textEditingController.text;
                });
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Nome do Medicamento",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),

            // 2. Cartão de Informação (Bula Resumida)
            if (_selectedDrugInfo != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AssessmentColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AssessmentColors.primaryBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedDrugInfo!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AssessmentColors.primaryBlue)),
                    const SizedBox(height: 8),
                    _buildInfoLine("Apresentação:", _selectedDrugInfo!.commercialNames),
                    _buildInfoLine("Classe:", _selectedDrugInfo!.therapeuticClass),
                    _buildInfoLine("Indicação:", _selectedDrugInfo!.indications),
                    _buildInfoLine("Dose Ref:", _selectedDrugInfo!.dosageInfo),
                    const SizedBox(height: 8),
                    // Expansível para detalhes
                    ExpansionTile(
                      title: const Text("Ver descrição completa e contraindicações", style: TextStyle(fontSize: 12)),
                      childrenPadding: EdgeInsets.zero,
                      tilePadding: EdgeInsets.zero,
                      dense: true,
                      children: [
                        Text(_selectedDrugInfo!.description, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Contraindicações: ${_selectedDrugInfo!.contraindications}", style: const TextStyle(fontSize: 12, color: AssessmentColors.errorRed)),
                      ],
                    )
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            
            // 3. Campos de Preenchimento
            Row(
              children: [
                Expanded(
                  child: _buildTextField(controller: _presCtrl, label: "Apresentação", hint: "Ex: Comprimido"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(controller: _doseCtrl, label: "Dosagem", hint: "Ex: 50mg"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(controller: _freqCtrl, label: "Frequência", hint: "Ex: 1x ao dia"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(controller: _timeCtrl, label: "Horário", hint: "Ex: 08:00"),
                ),
              ],
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.isEmpty) return;
                final newMed = PrescribedMedication(
                  drugName: _nameCtrl.text,
                  presentation: _presCtrl.text,
                  dosage: _doseCtrl.text,
                  frequency: _freqCtrl.text,
                  time: _timeCtrl.text,
                );
                widget.onSave(newMed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AssessmentColors.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Salvar Medicamento"),
            ),
            const SizedBox(height: 20), // Espaço teclado
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DE LEITURA (FALTAVA ESTA PARTE) ---
class MedicationReadView extends StatelessWidget {
  final String jsonString;

  const MedicationReadView({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    final meds = PrescribedMedication.decodeList(jsonString);

    if (meds.isEmpty) {
      // Tenta mostrar como texto simples caso seja dado antigo (legado)
      if (jsonString.isNotEmpty && !jsonString.trim().startsWith('[')) {
        return Text(jsonString); 
      }
      return const Text("-");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meds.map((med) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, size: 6, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(text: "${med.drugName} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "(${med.dosage}, ${med.presentation}) - "),
                    TextSpan(text: "${med.frequency} às ${med.time}", style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}