// lib/screens/reference_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/data/reference_data.dart';

class ReferenceDetailScreen extends StatelessWidget {
  final String testName;

  const ReferenceDetailScreen({super.key, required this.testName});

  @override
  Widget build(BuildContext context) {
    final info = referenceData[testName];

    if (info == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Dados de referência não encontrados.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(testName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard('Objetivo', info.objective),
          _buildInfoCard('Instruções de Aplicação', info.instructions),
          _buildInfoCard('Pontuação e Interpretação', info.scoring),
          _buildInfoCard('Referências', info.references, isReference: true),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, {bool isReference = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                fontStyle: isReference ? FontStyle.italic : FontStyle.normal,
                color: isReference ? Colors.grey[600] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}