import 'package:flutter/material.dart';
import 'dart:convert'; // Para codificar os dados
import 'package:http/http.dart' as http; // Para fazer a requisição HTTP
import 'package:shared_preferences/shared_preferences.dart'; // Para recuperar o token
import 'package:projpet/view/doglist_screen.dart';

void main() {
  runApp(CreateDogScreen());
}

class CreateDogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreatePetInformation(),
    );
  }
}

class CreatePetInformation extends StatefulWidget {
  @override
  _CreatePetInformationState createState() => _CreatePetInformationState();
}

class _CreatePetInformationState extends State<CreatePetInformation> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController imagesController = TextEditingController();

  Future<void> _createPet() async {
    final String url = "https://pet-adopt-dq32j.ondigitalocean.app/pet/create";

    // Recuperar o token armazenado
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token não encontrado. Faça login novamente.")),
      );
      return;
    }

    // Dados do corpo da requisição
    final Map<String, dynamic> body = {
      "name": nameController.text,
      "color": colorController.text,
      "weight": int.tryParse(weightController.text) ?? 0,
      "age": int.tryParse(ageController.text) ?? 0,
      "images": imagesController.text.split(","),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Enviar o token na autorização
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pet criado com sucesso!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DogsListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao criar pet: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 220, 220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DogsListScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Adicionar Pet',
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            buildTextField("Nome:", nameController),
            SizedBox(height: 15),
            buildTextField("Cor:", colorController),
            SizedBox(height: 15),
            buildTextField("Peso (kg):", weightController),
            SizedBox(height: 15),
            buildTextField("Idade (meses):", ageController),
            SizedBox(height: 15),
            buildTextField(
                "Imagens (URLs separadas por vírgula):", imagesController),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _createPet,
              child: Text(
                "Criar Pet",
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 155, 155),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
