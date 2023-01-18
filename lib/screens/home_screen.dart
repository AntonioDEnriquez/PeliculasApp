import 'package:flutter/material.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/search/search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Películas en Cine'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => showSearch(
                    context: context, delegate: MovieSearchDelegate()),
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        // SingleChildScrollView Permite hacer scroll
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Tarjetas Principales
              CardSwiper(movies: moviesProvider.onDisplayMovies),
              // Slider de peliculas
              MovieSlider(
                  movies: moviesProvider.popularMovies,
                  title: 'Populares',
                  onNextPage: () => moviesProvider.getPopularMovies()),
            ],
          ),
        ));
  }
}
