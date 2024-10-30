import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: CharacterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CharacterPage extends StatefulWidget {
  @override
  _CharacterPageState createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  late Future<List<dynamic>> _characters;
  List<dynamic> _allCharacters = [];

  // Variáveis de filtros
  String _selectedGender = 'Todos';
  String _selectedStatus = 'Todos';
  String _selectedSpecies = 'Todos';
  String _nameFilter = '';
  String _originFilter = '';

  @override
  void initState() {
    super.initState();
    _characters = fetchCharacters();
  }

  Future<List<dynamic>> fetchCharacters() async {
    final url = Uri.parse('https://rickandmortyapi.com/api/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _allCharacters = data['results'];
      return _allCharacters;
    } else {
      throw Exception('Erro ao consultar Api');
    }
  }

  void _applyFilters() {
    setState(() {
      _characters = Future.value(
        _allCharacters.where((character) {
          bool matchesGender = _selectedGender == 'Todos' ||
              character['gender'] == _selectedGender;
          bool matchesStatus = _selectedStatus == 'Todos' ||
              character['status'] == _selectedStatus;
          bool matchesSpecies = _selectedSpecies == 'Todos' ||
              character['species'] == _selectedSpecies;
          bool matchesName = _nameFilter.isEmpty ||
              character['name']
                  .toLowerCase()
                  .contains(_nameFilter.toLowerCase());
          bool matchesOrigin = _originFilter.isEmpty ||
              character['origin']['name']
                  .toLowerCase()
                  .contains(_originFilter.toLowerCase());

          return matchesGender &&
              matchesStatus &&
              matchesSpecies &&
              matchesName &&
              matchesOrigin;
        }).toList(),
      );
    });
  }

  void _showFilterDialog() {
    // Variáveis temporárias para o diálogo
    String tempSelectedGender = _selectedGender;
    String tempSelectedStatus = _selectedStatus;
    String tempSelectedSpecies = _selectedSpecies;
    String tempNameFilter = _nameFilter;
    String tempOriginFilter = _originFilter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          backgroundColor: Color(0xFF737373),
          title: Text(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              'Aplicar filtro:'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Filtro de Nome
                /*  TextField(
                  decoration: InputDecoration(labelText: 'Filtrar por nome'),
                  onChanged: (value) {
                    tempNameFilter = value;
                  },
                ),
              */
                SizedBox(height: 0),
                // Filtro de Gênero
                DropdownButton<String>(
                  value: tempSelectedGender,
                  items: <String>[
                    'Todos',
                    'Male',
                    'Female',
                    'Genderless',
                    'unknown'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      tempSelectedGender = newValue;
                    }
                  },
                ),
                // Filtro de Status
                DropdownButton<String>(
                  value: tempSelectedStatus,
                  items: <String>['Todos', 'Alive', 'Dead', 'unknown']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      tempSelectedStatus = newValue;
                    }
                  },
                ),
                // Filtro de Espécie
                DropdownButton<String>(
                  value: tempSelectedSpecies,
                  items: <String>[
                    'Todos',
                    'Human',
                    'Alien',
                    'Humanoid',
                    'Poopybutthole',
                    'Mythological Creature',
                    'unknown'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      tempSelectedSpecies = newValue;
                    }
                  },
                ),
                SizedBox(height: 0),
                // Filtro de Origem
                /* TextField(
                  decoration: InputDecoration(labelText: 'Filtrar por origem'),
                  onChanged: (value) {
                    tempOriginFilter = value;
                  },
                ),
               */
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0x8080FF00),
                fixedSize: const Size(100, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  'Aplicar filtros'),
              onPressed: () {
                // Atualiza os filtros ao pressionar 'Aplicar'
                setState(() {
                  _selectedGender = tempSelectedGender;
                  _selectedStatus = tempSelectedStatus;
                  _selectedSpecies = tempSelectedSpecies;
                  _nameFilter = tempNameFilter;
                  _originFilter = tempOriginFilter;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF242424),
      appBar: AppBar(
        actions: [
          Container(
            height: 200,
            child: Image.asset(
              'assets/images/appBarImage.png',
              fit: BoxFit.cover, // Ajusta a imagem para preencher o Container
              width: 411,
              height: 100,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          IconButton(
            icon: Image(
              image: AssetImage("assets/images/filtro.png"),
              width: 32,
              height: 32,
            ),
            onPressed: _showFilterDialog,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _characters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final characters = snapshot.data!;
                  return GridView.builder(
                    itemCount: characters.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // Define o número de colunas da grade
                      crossAxisSpacing: 20,
                      // Espaçamento horizontal entre os itens
                      mainAxisSpacing: 24,
                      // Espaçamento vertical entre os itens
                      childAspectRatio:
                          1 / 1, // Ajusta a proporção de cada item
                    ),
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CharacterDetailPage(character: character),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.network(character['image'],
                                    fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  character['name'],
                                  style:
                                      TextStyle(color: Colors.lightGreenAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('Nenhum dado disponível'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterDetailPage extends StatelessWidget {
  final Map<String, dynamic> character;

  CharacterDetailPage({required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141515),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0), // Define a altura da AppBar
        child: AppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/appBarImage.png',
              fit: BoxFit.cover, // Ajusta a imagem para preencher o Container
              width: 411,
              height: 50,
            ),
            Center(
              child: Image.network(
                character['image'],
                width: 380,
                height: 300,
                fit: BoxFit.fill, // Estica a imagem na horizontal
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nome: ${character['name']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Status: ${character['status']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Espécie: ${character['species']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Gênero: ${character['gender']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Origem: ${character['origin']['name']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Visto por Último: ${character['location']['name']}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
