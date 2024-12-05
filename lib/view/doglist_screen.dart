import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:projpet/view/createdog_screen.dart';
import 'package:projpet/view/user_profile_screen.dart';
import 'package:projpet/view/dog_detail_page.dart';
import 'package:projpet/widget/dog_card.dart'; // Import da página de detalhes

class DogsListScreen extends StatefulWidget {
  @override
  _DogsListScreenState createState() => _DogsListScreenState();
}

class _DogsListScreenState extends State<DogsListScreen> {
  List<dynamic> dogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDogs();
  }

  Future<void> fetchDogs() async {
    try {
      final response = await http.get(
        Uri.parse('https://pet-adopt-dq32j.ondigitalocean.app/pet/pets'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['pets'] != null && data['pets'] is List) {
          setState(() {
            dogs = data['pets'];
            isLoading = false;
          });
        } else {
          throw Exception('Resposta da API não contém o campo "pets".');
        }
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro durante a requisição: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFirstImage(dynamic images) {
    if (images is List && images.isNotEmpty) {
      return images[0];
    }
    return 'https://via.placeholder.com/150';
  }

  final List<Color> cardColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.blue.shade100,
    Colors.red.shade100
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 220, 220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileView()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://i.pinimg.com/736x/61/f7/5e/61f75ea9a680def2ed1c6929fe75aeee.jpg',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : dogs.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum pet encontrado.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.03),
                      // Grid de cards dos cães
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: dogs.length,
                          itemBuilder: (context, index) {
                            final dog = dogs[index];
                            final color = cardColors[index % cardColors.length];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DogDetailPage(
                                      dogName: dog['name'] ?? 'Sem nome',
                                      dogAge: dog['age'] != null
                                          ? '${dog['age']} meses'
                                          : 'Idade desconhecida',
                                      imageUrl: getFirstImage(dog['images']),
                                    ),
                                  ),
                                );
                              },
                              child: DogCard(
                                dogName: dog['name'] ?? 'Sem nome',
                                dogAge: dog['age'] != null
                                    ? '${dog['age']} meses'
                                    : 'Idade desconhecida',
                                imageUrl: getFirstImage(dog['images']),
                                backgroundColor: color,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDogScreen(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 204, 109, 109),
        child: Icon(Icons.add),
      ),
    );
  }
}
