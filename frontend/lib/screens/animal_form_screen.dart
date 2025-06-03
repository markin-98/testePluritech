import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/animal_model.dart';
import '../serviecs/api_service.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _nomeTutorController;
  late TextEditingController _contatoTutorController;
  late TextEditingController _racaController;
  late TextEditingController _dataEntradaController;
  late TextEditingController _previsaoDataSaidaController;
  String? _especieSelecionada;
  DateTime? _dataEntradaSelecionada;
  DateTime? _previsaoDataSaidaSelecionada;

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.animal != null; 

    _nomeTutorController = TextEditingController(text: _isEditMode ? widget.animal!.nomeTutor : '');
    _contatoTutorController = TextEditingController(text: _isEditMode ? widget.animal!.contatoTutor : '');
    _racaController = TextEditingController(text: _isEditMode ? widget.animal!.raca : '');

    if (_isEditMode) {
      _especieSelecionada = widget.animal!.especie;
      _dataEntradaSelecionada = widget.animal!.dataEntrada;
      _previsaoDataSaidaSelecionada = widget.animal!.previsaoDataSaida;
    }

    _dataEntradaController = TextEditingController(text: _dataEntradaSelecionada != null ? DateFormat('dd/MM/yyyy').format(_dataEntradaSelecionada!) : '');
    _previsaoDataSaidaController = TextEditingController(text: _previsaoDataSaidaSelecionada != null ? DateFormat('dd/MM/yyyy').format(_previsaoDataSaidaSelecionada!) : '');
  }

  @override
  void dispose() {
    _nomeTutorController.dispose();
    _contatoTutorController.dispose();
    _racaController.dispose();
    _dataEntradaController.dispose();
    _previsaoDataSaidaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDataEntrada) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isDataEntrada ? _dataEntradaSelecionada : _previsaoDataSaidaSelecionada) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: isDataEntrada ? 'SELECIONE DATA DE ENTRADA' : 'SELECIONE PREVISÃO DE SAÍDA',
    );
    if (picked != null) {
      setState(() {
        if (isDataEntrada) {
          _dataEntradaSelecionada = picked;
          _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _previsaoDataSaidaSelecionada = picked;
          _previsaoDataSaidaController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_especieSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a espécie.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (_dataEntradaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de entrada.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isLoading = true);

      final animalData = Animal(
        id: _isEditMode ? widget.animal!.id : null,
        nomeTutor: _nomeTutorController.text,
        contatoTutor: _contatoTutorController.text,
        especie: _especieSelecionada!,
        raca: _racaController.text,
        dataEntrada: _dataEntradaSelecionada!,
        previsaoDataSaida: _previsaoDataSaidaSelecionada,
      );

      try {
        if (_isEditMode) {
          await _apiService.updateAnimal(widget.animal!.id!, animalData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal atualizado com sucesso!'), backgroundColor: Colors.green),
          );
        } else {
          await _apiService.addAnimal(animalData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal adicionado com sucesso!'), backgroundColor: Colors.green),
          );
        }
        Navigator.of(context).pop(true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar animal: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Animal ' : 'Adicionar Animal '),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, 
                child: ListView( 
                  children: <Widget>[
                    TextFormField(
                      controller: _nomeTutorController,
                      decoration: const InputDecoration(labelText: 'Nome do Tutor', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do tutor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contatoTutorController,
                      decoration: const InputDecoration(labelText: 'Contato do Tutor (Telefone/Email)', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o contato do tutor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _especieSelecionada,
                      hint: const Text('Selecione a Espécie'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: <String>['Cachorro', 'Gato'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _especieSelecionada = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _racaController,
                      decoration: const InputDecoration(labelText: 'Raça', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a raça.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dataEntradaController,
                      decoration: const InputDecoration(
                        labelText: 'Data de Entrada',
                        hintText: 'dd/MM/yyyy',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                      validator: (value) {
                        if (_dataEntradaSelecionada == null) {
                          return 'Por favor, selecione a data de entrada.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _previsaoDataSaidaController,
                      decoration: InputDecoration(
                        labelText: 'Previsão de Saída (Opcional)',
                        hintText: 'dd/MM/yyyy',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                        suffix: _previsaoDataSaidaSelecionada != null ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _previsaoDataSaidaSelecionada = null;
                              _previsaoDataSaidaController.clear();
                            });
                          },
                        ) : null,
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, false)
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: Text(_isEditMode ? 'Salvar Alterações' : 'Adicionar Animal'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}



