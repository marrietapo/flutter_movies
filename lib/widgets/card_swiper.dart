import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:peliculas/widgets/widgets.dart';
import '../models/movies.dart';

class CardSwipper extends StatelessWidget {

  final List<Movie> movies;

  const CardSwipper({
    Key? key,
    required this.movies
  }):super(key:key);

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    if( this.movies.length == 0 ){
      return Container(
        width: double.infinity,
        height: size.height * 0.6,
        child: Center(child: CircularProgressIndicator(),),
      );
    }

    return Container(
      width: double.infinity,
      height: size.height * 0.6,
      //color:Colors.red[300],
      child: Swiper(
        itemCount: movies.length, 
        layout: SwiperLayout.STACK, 
        itemWidth: size.width *0.6, 
        itemHeight: size.height * 0.5, 
        itemBuilder: ( _ , int index){

          final movie = movies[index];
          movie.heroId = 'swiper-${movie.id}';

          return GestureDetector(
            onTap: ()=>Navigator.pushNamed(context, 'details', arguments: movie ),
            child: Hero(
              tag: movie.heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: AssetImage('assets/no-image.jpg'), 
                  image: NetworkImage(movie.fullPosterImg),
                  fit: BoxFit.cover
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}