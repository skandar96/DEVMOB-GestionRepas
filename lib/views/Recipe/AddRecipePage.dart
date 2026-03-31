import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/RecipeProvider.dart';
import '../../Models/recipe.dart';
import '../../Models/ingredient.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  RecipeCategory _selectedCategory = RecipeCategory.dejeuner;
  RecipeDifficulty _selectedDifficulty = RecipeDifficulty.facile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        title: const Text(
          'Ajouter une Recette',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Informations Générales'),
              _buildTextField(
                _nameController,
                'Nom de la recette',
                Icons.restaurant,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildSection('Détails'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _timeController,
                      'Temps (min)',
                      Icons.timer,
                      isNumeric: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _servingsController,
                      'Portions',
                      Icons.people,
                      isNumeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 12),
              _buildDifficultyDropdown(),
              const SizedBox(height: 16),
              _buildSection('Ingrédients'),
              _buildTextField(
                _ingredientsController,
                'Ingrédients (un par ligne)',
                Icons.list,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildSection('Instructions'),
              _buildTextField(
                _instructionsController,
                'Instructions',
                Icons.notes,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7C3AED),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<RecipeCategory>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: RecipeCategory.values
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category.label)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<RecipeDifficulty>(
      value: _selectedDifficulty,
      decoration: InputDecoration(
        labelText: 'Difficulté',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: RecipeDifficulty.values
          .map(
            (difficulty) => DropdownMenuItem(
              value: difficulty,
              child: Text(difficulty.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedDifficulty = value);
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF7C3AED)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ingredients = _ingredientsController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .map((line) {
              final parts = line.split(' - ');
              if (parts.length >= 3) {
                return Ingredient(
                  name: parts[0].trim(),
                  quantity: parts[1].trim(),
                  unit: parts[2].trim(),
                );
              }
              return Ingredient(
                name: line.trim(),
                quantity: '1',
                unit: 'unité',
              );
            })
            .toList();

        final instructions = _instructionsController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList();

        final recipe = Recipe(
          name: _nameController.text,
          description: _descriptionController.text,
          preparationTime: int.parse(_timeController.text),
          servings: int.parse(_servingsController.text),
          ingredients: ingredients,
          instructions: instructions,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
        );

        await context.read<RecipeProvider>().addRecipe(recipe);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recette enregistrée avec succès!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
