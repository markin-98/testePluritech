import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/animal_model.dart';
import '../serviecs/api_service.dart';
import 'animal_form_screen.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});
  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Animal>> _futureAnimais;

  @override
  void initState() {
    super.initState();
    _loadAnimais();
  }

  void _loadAnimais(){
    setState(() {
      _futureAnimais = _apiService.getAnimais();     
    });
  }

  void _navigateToForm({Animal? animal}) async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalFormScreen(animal: animal),
      ),
    );
    if(result == true){
      _loadAnimais();
    }
  }

  void _deleteAnimal(int id) async{
    try{
      await _apiService.deleteAnimal(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal excluído com sucesso!'), backgroundColor: Colors.green),
      );
      _loadAnimais();
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir animal: $e'), backgroundColor:  Colors.red),
      );
    }
  }

  String _formatDate(DateTime date){
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Pet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnimais,
            ),
        ],
      ),

      body: FutureBuilder<List<Animal>>(
        future:  _futureAnimais,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasError) {
            return Center(child: Text('Erro ao carregar animais: ${snapshot.error}'));
          }
          else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return  const Center(child: Text('Nenhum animal cadastrado.'));
          }

          List<Animal> animais = snapshot.data!;
          return ListView.builder(
            itemCount: animais.length,
            itemBuilder: (context, index){
              final animal = animais[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(animal.especie == "Cachorro" ? "🐶" : "🐱", style: const TextStyle(fontSize: 24)),
                  ),
                  title: Text('${animal.raca} (Tutor: ${animal.nomeTutor})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contato Tutor: ${animal.contatoTutor}'),
                      Text('Entrada: ${_formatDate(animal.dataEntrada)}'),
                      if (animal.previsaoDataSaida != null)
                        Text('Previsão Saída: ${_formatDate(animal.previsaoDataSaida!)}'),
                        Text('Diárias até hoje: ${animal.diariasAteHoje ?? 'N/A'}'),
                      if (animal.diariasPrevistas != null)
                        Text('Diárias Totais Previstas: ${animal.diariasPrevistas}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(animal: animal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(animal),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToForm(animal: animal), 
                ),
              );
            },
          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Adicionar Animal',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o registro de ${animal.raca} (Tutor: ${animal.nomeTutor})?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnimal(animal.id!);
              },
            ),
          ],
        );
      },
    );
  }
}