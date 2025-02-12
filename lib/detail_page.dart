import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final String url;
  const DetailPage({Key? key, required this.url}) : super(key: key);

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> pokemonDetailFuture;

  @override
  void initState() {
    super.initState();
    pokemonDetailFuture = fetchPokemonDetail();
  }

  // Fetch Pokémon details from the API
  Future<Map<String, dynamic>> fetchPokemonDetail() async {
    var response = await http.get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Pokémon"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: pokemonDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var pokemonDetail = snapshot.data!;
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        pokemonDetail['sprites']['other']['official-artwork']['front_default'],
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        pokemonDetail['name'].toUpperCase(),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "ID: #${pokemonDetail['id']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Tipos:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          itemCount: pokemonDetail['types'].length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Chip(
                              label: Text(pokemonDetail['types'][index]['type']['name']),
                              backgroundColor: Colors.deepOrange,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Estadísticas:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: List.generate(pokemonDetail['stats'].length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "${pokemonDetail['stats'][index]['stat']['name'].toUpperCase()}: ${pokemonDetail['stats'][index]['base_stat']}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
