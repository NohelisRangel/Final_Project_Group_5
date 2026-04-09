import 'package:final_project/views/screens/favorite_folder.dart';
import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../services/meal_api_service.dart';
import '../widgets/recipe_card.dart';
import 'cart_list_screen.dart';
import 'profile_screen.dart';
import 'recipe_description_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final MealApiService _apiService = MealApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Recipe> _recipes = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 40;

  String _selectedCuisine = '';
  int _selectedIndex = 0;

  final List<String> _cuisines = [
    '',
    'Italian',
    'Indian',
    'Mexican',
    'Chinese',
    'Thai',
    'American',
    'French',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialRecipes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          !_isLoading &&
          _hasMore &&
          _selectedIndex == 0) {
        _loadMoreRecipes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRecipes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _offset = 0;
      _hasMore = true;
      _recipes.clear();
    });

    try {
      final recipes = await _apiService.fetchRecipes(
        query: _searchController.text.trim(),
        cuisine: _selectedCuisine,
        offset: 0,
        number: _limit,
      );

      if (!mounted) return;

      setState(() {
        _recipes = recipes;
        _offset = recipes.length;
        _hasMore = recipes.length == _limit;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreRecipes() async {
    if (!mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreRecipes = await _apiService.fetchRecipes(
        query: _searchController.text.trim(),
        cuisine: _selectedCuisine,
        offset: _offset,
        number: _limit,
      );

      if (!mounted) return;

      setState(() {
        _recipes.addAll(moreRecipes);
        _offset += moreRecipes.length;
        _hasMore = moreRecipes.length == _limit;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more recipes: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onSearch() {
    _loadInitialRecipes();
  }

  void _onCuisineChanged(String? value) {
    setState(() {
      _selectedCuisine = value ?? '';
    });
    _loadInitialRecipes();
  }

  Widget _buildRecipeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            onSubmitted: (_) => _onSearch(),
            decoration: InputDecoration(
              hintText: 'Search recipe by name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _onSearch,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCuisine,
            decoration: InputDecoration(
              labelText: 'Filter by country',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: _cuisines.map((cuisine) {
              return DropdownMenuItem<String>(
                value: cuisine,
                child: Text(cuisine.isEmpty ? 'All Countries' : cuisine),
              );
            }).toList(),
            onChanged: _onCuisineChanged,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recipes.isEmpty
                  ? const Center(
                      child: Text(
                        'No recipes found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _recipes.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _recipes.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final recipe = _recipes[index];

                        return RecipeCard(
                          title: recipe.title,
                          imageUrl: recipe.image,
                          cuisine: recipe.cuisine,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDescriptionScreen(recipe: recipe),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Recipe List';
      case 1:
        return 'Favorites';
      case 2:
        return 'Cart';
      case 3:
        return 'Profile';
      default:
        return 'Recipe List';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildRecipeTab();
      case 1:
        return FavoriteScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildRecipeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}