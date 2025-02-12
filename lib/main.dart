import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemon_app/detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'PressStart2P'),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.yellow],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Image(
                    image: AssetImage('assets/pokedex.png'),
                    width: 300,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '¡Bienvenido a la Pokedex!',
                  style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage> {
  List pokemons = [];
  bool isLoading = false;
  bool hasMore = true;  // Añadimos una variable para controlar si hay más Pokémon por cargar
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchFirstGenPokemons();
  }

  fetchFirstGenPokemons() async {
    setState(() {
      isLoading = true;
    });

    // URL para obtener solo los primeros 151 Pokémon (Primera Generación)
    var url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151');
    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        pokemons = data['results'];
      });
    }
    setState(() {
      isLoading = false;
      hasMore = false; // No hay más Pokémon por cargar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex - 1era Generacion', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: pokemons.length,
          itemBuilder: (context, index) {
            // Condición para evitar que se cargue más allá de los 151 Pokémon
            if (index == pokemons.length - 1 && hasMore) {
              return const Center(child: CircularProgressIndicator());
            }

            var pokemonUrl = pokemons[index]['url'];
            var pokemonNumber = pokemonUrl.split('/')[6];
            var imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonNumber.png';

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Image.network( // Agregamos la imagen oficial
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                title: Text(
                  '#$pokemonNumber - ${pokemons[index]['name'].toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(url: pokemons[index]['url']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
