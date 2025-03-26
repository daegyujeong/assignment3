import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Store Animation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const GameStorePage(),
    );
  }
}

class GameStorePage extends StatefulWidget {
  const GameStorePage({super.key});

  @override
  State<GameStorePage> createState() => _GameStorePageState();
}

class _GameStorePageState extends State<GameStorePage> {
  int selectedGameIndex = 0;
  bool isDetailView = false;

  final List<Game> games = [
    Game(
      title: "Shadow of the Tomb Raider",
      image: "assets/images/tomb_raider.webp",
      description:
          "The Lara Croft who appears in Shadow of the Tomb Raider has made a ton of discoveries, lost a lot of friends, and killed countless living beings. She has incredible drive and self-confidence, and her enemies fear her.",
      rating: 3,
      platforms: ["PS4", "XBOX ONE", "STEAM"],
      tagline: "STANDING IN THE SHADOWS.",
    ),
    Game(
      title: "God of War",
      image: "assets/images/god_of_war.jpg",
      description:
          "Latest chapter in God Of War saga sees Kratos going on a journey with his Son Atreus to fulfill the final wish of Atreus' mother.",
      rating: 5,
      platforms: ["PS4"],
      tagline: "A NEW BEGINNING.",
    ),
    Game(
      title: "Horizon Forbidden West",
      image: "assets/images/horizon.jpg",
      description:
          "Explore distant lands, fight bigger and more awe-inspiring machines, and encounter new tribes as you return to the far-future, post-apocalyptic world of Horizon.",
      rating: 4,
      platforms: ["PS4", "PS5"],
      tagline: "BRAVE THE FRONTIER.",
    ),
  ];

  void toggleDetailView() {
    setState(() {
      isDetailView = !isDetailView;
    });
  }

  void selectGame(int index) {
    setState(() {
      selectedGameIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: isDetailView
              ? GameDetailScreen(
                  game: games[selectedGameIndex],
                  onBack: toggleDetailView,
                  key: ValueKey<String>(
                      'detail-${games[selectedGameIndex].title}'),
                )
              : GameGridScreen(
                  games: games,
                  onGameTap: (index) {
                    selectGame(index);
                    toggleDetailView();
                  },
                  key: const ValueKey<String>('grid'),
                ),
        ),
      ),
    );
  }
}

class GameGridScreen extends StatefulWidget {
  final List<Game> games;
  final Function(int) onGameTap;

  const GameGridScreen({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  @override
  State<GameGridScreen> createState() => _GameGridScreenState();
}

class _GameGridScreenState extends State<GameGridScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Featured Games',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.games.length,
            itemBuilder: (context, index) {
              // Calculate scale factor based on the current page
              final double scale = _currentPage == index ? 1.0 : 0.9;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: scale, end: scale),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutQuint,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.onGameTap(index),
                  child: GameCard(game: widget.games[index]),
                ),
              );
            },
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms).moveY(
              begin: 30, end: 0, duration: 600.ms, curve: Curves.easeOutQuint),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.games.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.blue
                      : Colors.grey.shade700,
                ),
              )
                  .animate(target: _currentPage == index ? 1 : 0)
                  .scaleXY(begin: 1.0, end: 1.5, duration: 300.ms)
                  .then(delay: 300.ms)
                  .scaleXY(begin: 1.5, end: 1.0);
            }),
          ),
        ),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Game image taking full space
          Container(
            color: Colors.black,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                game.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Game info
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < game.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  game.tagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  game.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: game.platforms.map((platform) {
                    return Chip(
                      backgroundColor: Colors.blue.withOpacity(0.3),
                      label: Text(
                        platform,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameDetailScreen extends StatelessWidget {
  final Game game;
  final VoidCallback onBack;

  const GameDetailScreen({
    super.key,
    required this.game,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App bar with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
              const Text(
                'Game Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Game details
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game cover image
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Image.asset(
                        game.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        game.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).moveY(
                    begin: 20,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad),

                // Rating
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < game.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          ).animate(delay: (100 * index).ms).scale(
                              duration: 400.ms, curve: Curves.elasticOut);
                        }),
                      ),
                    ],
                  ),
                ),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    game.tagline,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[400],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms).moveX(
                    begin: -20,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    game.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).moveY(
                    begin: 20,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad),

                // Platforms
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available on',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: game.platforms.map((platform) {
                          return Chip(
                            backgroundColor: Colors.blue,
                            label: Text(
                              platform,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                // Add to cart button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart),
                        SizedBox(width: 8),
                        Text(
                          'Add to cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms).moveY(
                    begin: 20,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Game {
  final String title;
  final String image;
  final String description;
  final int rating;
  final List<String> platforms;
  final String tagline;

  Game({
    required this.title,
    required this.image,
    required this.description,
    required this.rating,
    required this.platforms,
    required this.tagline,
  });
}
