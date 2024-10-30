import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  List<dynamic> _characters = [];
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
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    final url = Uri.parse('https://rickandmortyapi.com/api/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _allCharacters = data['results'];
        _characters = _allCharacters;
      });
    } else {
      throw Exception('Erro ao consultar API');
    }
  }

  void _applyFilters() {
    setState(() {
      _characters = _allCharacters.where((character) {
        bool matchesGender = _selectedGender == 'Todos' ||
            character['gender'] == _selectedGender;
        bool matchesStatus = _selectedStatus == 'Todos' ||
            character['status'] == _selectedStatus;
        bool matchesSpecies = _selectedSpecies == 'Todos' ||
            character['species'] == _selectedSpecies;
        bool matchesName = _nameFilter.isEmpty ||
            character['name'].toLowerCase().contains(_nameFilter.toLowerCase());
        bool matchesOrigin = _originFilter.isEmpty ||
            character['origin']['name']
                .toLowerCase()
                .contains(_originFilter.toLowerCase());

        return matchesGender &&
            matchesStatus &&
            matchesSpecies &&
            matchesName &&
            matchesOrigin;
      }).toList();
    });
  }

  void _showFilterDialog() {
    String tempSelectedGender = _selectedGender;
    String tempSelectedStatus = _selectedStatus;
    String tempSelectedSpecies = _selectedSpecies;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: Color(0xFF737373),
              title: Text(
                'Aplicar filtro:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Gênero
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.lightGreenAccent),
                        ),
                        labelText: "Gênero",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Colors.black54,
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
                          child: Text(value,
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            tempSelectedGender = newValue;
                            _selectedGender = newValue;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    // Status
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.lightGreenAccent),
                        ),
                        labelText: "Status",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Colors.black54,
                      value: tempSelectedStatus,
                      items: <String>['Todos', 'Alive', 'Dead', 'unknown']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            tempSelectedStatus = newValue;
                            _selectedStatus = newValue;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    // Espécie
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black45,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.lightGreenAccent),
                        ),
                        labelText: "Espécie",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Colors.black54,
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
                          child: Text(value,
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            tempSelectedSpecies = newValue;
                            _selectedSpecies = newValue;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF80FF00),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Aplicar filtros',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212424),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Aumenta a altura da AppBar
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 20), // Ajusta o padding para baixo
            child: Center(
              child: Transform.scale(
                scale: 1.4, // Escala para 130%
                child: Image.asset(
                  'assets/images/appBarImage.png',
                  fit: BoxFit.contain, // Ajuste conforme necessário
                ),
              ),
            ),
          ),
        ),
      ),


      body: Column(
        children: [
          IconButton(
            icon: Image(
              image: AssetImage("assets/images/filtro.png"),
              width: 36,
              height: 36,
            ),
            onPressed: _showFilterDialog,
          ),
          Expanded(
            child: _characters.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: _characters.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1 / 1,
                    ),
                    itemBuilder: (context, index) {
                      final character = _characters[index];
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
                          color: Colors.transparent,
                          // Define a cor do Card como transparente
                          elevation: 0,
                          // Remove a sombra do Card, se não desejar sombra
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
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/appBarImage.png',
              fit: BoxFit.cover,
              width: 411,
              height: 50,
            ),
            Center(
              child: Image.network(
                character['image'],
                width: 380,
                height: 300,
                fit: BoxFit.fill,
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
