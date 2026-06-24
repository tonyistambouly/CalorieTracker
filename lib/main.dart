import 'package:flutter/material.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF205295),
          secondary: Color(0xFFF6C453),
          surface: Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
      home: const RootFlow(),
    );
  }
}

class RootFlow extends StatefulWidget {
  const RootFlow({super.key});

  @override
  State<RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<RootFlow> {
  final AppState state = AppState();
  bool completedOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return completedOnboarding
        ? HomeShell(
            state: state,
            onReset: () => setState(() => completedOnboarding = false),
          )
        : OnboardingPage(
            state: state,
            onContinue: () => setState(() => completedOnboarding = true),
          );
  }
}

class AppState {
  AppState() {
    foods = List.of(sampleFoods);
    recipes = List.of(sampleRecipes);
    todayTip = mindfulTips.first;
    profile = UserProfile();
    weights = [
      WeightEntry(date: DateTime.now().subtract(const Duration(days: 14)), weightKg: 79),
      WeightEntry(date: DateTime.now().subtract(const Duration(days: 7)), weightKg: 78.4),
      WeightEntry(date: DateTime.now(), weightKg: 77.8),
    ];
    mealPlan = {
      'Monday': sampleRecipes[0].title,
      'Tuesday': sampleRecipes[1].title,
      'Wednesday': sampleRecipes[2].title,
      'Thursday': sampleRecipes[0].title,
      'Friday': sampleRecipes[1].title,
      'Saturday': sampleRecipes[2].title,
      'Sunday': sampleRecipes[0].title,
    };
    shoppingList = {
      for (final recipe in sampleRecipes) ...recipe.ingredients,
    }.toList();
    currentJournal = JournalEntry();
  }

  late UserProfile profile;
  late List<FoodItem> foods;
  late List<RecipeItem> recipes;
  final List<MealLog> mealLogs = [];
  final List<WaterEntry> waterLogs = [];
  final List<ExerciseEntry> exerciseLogs = [
    ExerciseEntry(name: '30 min walk', caloriesBurned: 140),
  ];
  late List<WeightEntry> weights;
  late Map<String, String> mealPlan;
  late List<String> shoppingList;
  late JournalEntry currentJournal;
  late String todayTip;
  final List<String> badges = ['7-day streak', 'Hydration starter', 'Levant explorer'];
  final List<String> communityPosts = [
    'Success story: “I stayed consistent for 30 days and learned healthier ways to enjoy shawarma bowls.”',
    'Cooking tip: “Add extra parsley and tomatoes to make tabbouleh more filling without adding many calories.”',
    'Forum topic: “What is your favorite high-protein Lebanese breakfast?”',
  ];

  int get consumedCalories => mealLogs.expand((m) => m.items).fold(0, (sum, i) => sum + i.calories);
  int get burnedCalories => exerciseLogs.fold(0, (sum, e) => sum + e.caloriesBurned);
  int get remainingCalories => (profile.dailyCalories - consumedCalories + burnedCalories).clamp(0, 999999);
  double get protein => mealLogs.expand((m) => m.items).fold(0.0, (sum, i) => sum + i.protein);
  double get carbs => mealLogs.expand((m) => m.items).fold(0.0, (sum, i) => sum + i.carbs);
  double get fat => mealLogs.expand((m) => m.items).fold(0.0, (sum, i) => sum + i.fat);
  int get waterMl => waterLogs.fold(0, (sum, i) => sum + i.amountMl);
  List<FoodItem> get mealSuggestions => foods.take(3).toList();

  void saveProfile(UserProfile newProfile) {
    profile = newProfile;
  }

  void addFood(String mealType, FoodItem item) {
    final index = mealLogs.indexWhere((m) => m.mealType == mealType);
    if (index == -1) {
      mealLogs.add(MealLog(mealType: mealType, items: [item]));
    } else {
      mealLogs[index].items.add(item);
    }
  }

  List<FoodItem> mockRecognizePhoto() {
    return [
      foods.firstWhere((f) => f.name == 'Hummus'),
      FoodItem(
        name: 'Pita Bread',
        region: 'Middle Eastern',
        category: 'Bread',
        calories: 170,
        protein: 6,
        carbs: 35,
        fat: 1,
        culturalInsight: 'Common accompaniment to dips and mezze.',
        micronutrientNote: 'Mostly carbohydrates with modest protein.',
      ),
    ];
  }

  FoodItem? mockBarcodeLookup(String code) {
    if (code.trim() == '629000000001') {
      return FoodItem(
        name: 'Labneh Cup',
        region: 'Lebanese',
        category: 'Dairy',
        calories: 120,
        protein: 9,
        carbs: 5,
        fat: 7,
        culturalInsight: 'Creamy strained yogurt often used in breakfast plates.',
        micronutrientNote: 'Source of calcium and protein.',
      );
    }
    return null;
  }

  void addWater(int amountMl, {String beverage = 'Water'}) {
    waterLogs.insert(0, WaterEntry(beverage: beverage, amountMl: amountMl));
  }

  void addWeight(double weightKg) {
    weights.add(WeightEntry(date: DateTime.now(), weightKg: weightKg));
  }

  void saveJournal(JournalEntry entry) {
    currentJournal = entry;
  }
}

class UserProfile {
  String email;
  String name;
  int age;
  double heightCm;
  double weightKg;
  String gender;
  String goal;
  String activityLevel;
  String dietaryPreference;
  bool familiarWithMiddleEasternCuisine;
  int dailyCalories;
  int dailyWaterMl;
  String language;
  String units;

  UserProfile({
    this.email = '',
    this.name = 'Guest',
    this.age = 30,
    this.heightCm = 170,
    this.weightKg = 75,
    this.gender = 'Prefer not to say',
    this.goal = 'Weight Loss',
    this.activityLevel = 'Moderate',
    this.dietaryPreference = 'Balanced',
    this.familiarWithMiddleEasternCuisine = true,
    this.dailyCalories = 2100,
    this.dailyWaterMl = 2500,
    this.language = 'English',
    this.units = 'Metric',
  });
}

class FoodItem {
  final String name;
  final String region;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String culturalInsight;
  final String micronutrientNote;

  FoodItem({
    required this.name,
    required this.region,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.culturalInsight,
    required this.micronutrientNote,
  });
}

class MealLog {
  final String mealType;
  final List<FoodItem> items;

  MealLog({required this.mealType, required this.items});
}

class RecipeItem {
  final String title;
  final String region;
  final String difficulty;
  final int prepMinutes;
  final int calories;
  final String culturalContext;
  final List<String> ingredients;
  final List<String> steps;

  RecipeItem({
    required this.title,
    required this.region,
    required this.difficulty,
    required this.prepMinutes,
    required this.calories,
    required this.culturalContext,
    required this.ingredients,
    required this.steps,
  });
}

class WeightEntry {
  final DateTime date;
  final double weightKg;

  WeightEntry({required this.date, required this.weightKg});
}

class WaterEntry {
  final DateTime at;
  final int amountMl;
  final String beverage;

  WaterEntry({DateTime? at, required this.beverage, required this.amountMl}) : at = at ?? DateTime.now();
}

class ExerciseEntry {
  final String name;
  final int caloriesBurned;

  ExerciseEntry({required this.name, required this.caloriesBurned});
}

class JournalEntry {
  String preMealEmotion;
  String postMealSatisfaction;
  int hungerLevel;
  int fullnessLevel;
  String trigger;
  String reflection;

  JournalEntry({
    this.preMealEmotion = '',
    this.postMealSatisfaction = '',
    this.hungerLevel = 5,
    this.fullnessLevel = 5,
    this.trigger = '',
    this.reflection = '',
  });
}

final List<String> mindfulTips = [
  'Pause for three deep breaths before your first bite.',
  'Rate your hunger from 1 to 10 before eating.',
  'Try one meal today without your phone nearby.',
  'Notice herbs, textures, and spices in your plate before eating.',
];

final List<FoodItem> sampleFoods = [
  FoodItem(
    name: 'Tabbouleh',
    region: 'Lebanese',
    category: 'Salad',
    calories: 180,
    protein: 4,
    carbs: 19,
    fat: 10,
    culturalInsight: 'A parsley-forward Levantine salad with tomatoes, bulgur, lemon, and olive oil.',
    micronutrientNote: 'High in vitamin K from parsley.',
  ),
  FoodItem(
    name: 'Hummus',
    region: 'Middle Eastern',
    category: 'Dip',
    calories: 160,
    protein: 6,
    carbs: 14,
    fat: 9,
    culturalInsight: 'A chickpea dip shared across the Levant and broader Middle East.',
    micronutrientNote: 'Good source of folate and manganese.',
  ),
  FoodItem(
    name: 'Shawarma Chicken Wrap',
    region: 'Lebanese',
    category: 'Sandwich',
    calories: 460,
    protein: 32,
    carbs: 35,
    fat: 20,
    culturalInsight: 'Popular street-food wrap often served with garlic sauce and pickles.',
    micronutrientNote: 'Protein-rich, though sodium can be high.',
  ),
  FoodItem(
    name: 'Mujadara',
    region: 'Levant',
    category: 'Main',
    calories: 310,
    protein: 11,
    carbs: 48,
    fat: 8,
    culturalInsight: 'A comforting lentil and rice dish topped with caramelized onions.',
    micronutrientNote: 'Fiber-rich and plant-protein friendly.',
  ),
  FoodItem(
    name: 'Manakish Zaatar',
    region: 'Lebanese',
    category: 'Bakery',
    calories: 340,
    protein: 8,
    carbs: 42,
    fat: 14,
    culturalInsight: 'A breakfast flatbread topped with zaatar and olive oil.',
    micronutrientNote: 'Contains iron and calcium depending on flour and toppings.',
  ),
  FoodItem(
    name: 'Greek Yogurt',
    region: 'General',
    category: 'Dairy',
    calories: 100,
    protein: 17,
    carbs: 6,
    fat: 0,
    culturalInsight: 'Useful as a high-protein base for snacks and sauces.',
    micronutrientNote: 'Calcium-rich and protein-dense.',
  ),
];

final List<RecipeItem> sampleRecipes = [
  RecipeItem(
    title: 'Balanced Lebanese Breakfast Plate',
    region: 'Lebanese',
    difficulty: 'Easy',
    prepMinutes: 12,
    calories: 420,
    culturalContext: 'A breakfast-style plate built around labneh, vegetables, olives, mint, and whole grains.',
    ingredients: ['Labneh', 'Cucumber', 'Tomato', 'Mint', 'Olives', 'Whole-wheat pita', 'Zaatar'],
    steps: ['Spread labneh on a plate.', 'Top with zaatar and a small amount of olive oil.', 'Serve with chopped vegetables and warm pita.'],
  ),
  RecipeItem(
    title: 'Light Mujadara Bowl',
    region: 'Levant',
    difficulty: 'Medium',
    prepMinutes: 35,
    calories: 380,
    culturalContext: 'A high-fiber comfort dish often served with yogurt or salad.',
    ingredients: ['Brown lentils', 'Rice', 'Onions', 'Cumin', 'Olive oil'],
    steps: ['Cook lentils until tender.', 'Add rice and spices.', 'Top with caramelized onions.'],
  ),
  RecipeItem(
    title: 'Protein Shawarma Bowl',
    region: 'Middle Eastern',
    difficulty: 'Medium',
    prepMinutes: 25,
    calories: 510,
    culturalContext: 'Shawarma spices adapted into a higher-protein bowl with vegetables and yogurt sauce.',
    ingredients: ['Chicken breast', 'Paprika', 'Cumin', 'Garlic', 'Rice', 'Pickles', 'Tahini yogurt'],
    steps: ['Marinate chicken with spices.', 'Roast or grill until cooked.', 'Serve over rice with pickles and tahini yogurt.'],
  ),
];

enum Section { dashboard, foodLog, recipes, planner, progress, hydration, journal, education, community, settings }

class HomeShell extends StatefulWidget {
  final AppState state;
  final VoidCallback onReset;
  const HomeShell({super.key, required this.state, required this.onReset});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  Section section = Section.dashboard;

  @override
  Widget build(BuildContext context) {
    final page = switch (section) {
      Section.dashboard => DashboardPage(state: widget.state, onStateChanged: _refresh),
      Section.foodLog => FoodLogPage(state: widget.state, onStateChanged: _refresh),
      Section.recipes => RecipesPage(state: widget.state),
      Section.planner => PlannerPage(state: widget.state),
      Section.progress => ProgressPage(state: widget.state, onStateChanged: _refresh),
      Section.hydration => HydrationPage(state: widget.state, onStateChanged: _refresh),
      Section.journal => JournalPage(state: widget.state, onStateChanged: _refresh),
      Section.education => EducationPage(state: widget.state),
      Section.community => CommunityPage(state: widget.state),
      Section.settings => SettingsPage(state: widget.state, onStateChanged: _refresh),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForSection(section)),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.state.profile.name),
                accountEmail: Text(widget.state.profile.email.isEmpty ? 'guest@local.app' : widget.state.profile.email),
                currentAccountPicture: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
              ),
              _drawerItem(Icons.home_outlined, 'Dashboard', Section.dashboard),
              _drawerItem(Icons.search_outlined, 'Food Log', Section.foodLog),
              _drawerItem(Icons.menu_book_outlined, 'Recipes', Section.recipes),
              _drawerItem(Icons.calendar_month_outlined, 'Meal Planner', Section.planner),
              _drawerItem(Icons.insights_outlined, 'Progress & Goals', Section.progress),
              _drawerItem(Icons.water_drop_outlined, 'Hydration', Section.hydration),
              _drawerItem(Icons.edit_note_outlined, 'Mindful Journal', Section.journal),
              _drawerItem(Icons.school_outlined, 'Cultural Education', Section.education),
              _drawerItem(Icons.groups_outlined, 'Community', Section.community),
              _drawerItem(Icons.settings_outlined, 'Settings', Section.settings),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Restart onboarding'),
                onTap: widget.onReset,
              )
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex(section),
        onDestinationSelected: (value) {
          setState(() {
            section = switch (value) {
              0 => Section.dashboard,
              1 => Section.foodLog,
              2 => Section.recipes,
              3 => Section.progress,
              _ => Section.settings,
            };
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  int _bottomIndex(Section section) {
    switch (section) {
      case Section.dashboard:
        return 0;
      case Section.foodLog:
        return 1;
      case Section.recipes:
        return 2;
      case Section.progress:
        return 3;
      default:
        return 4;
    }
  }

  String _titleForSection(Section section) {
    switch (section) {
      case Section.dashboard:
        return 'Home Dashboard';
      case Section.foodLog:
        return 'Food Logging';
      case Section.recipes:
        return 'Recipes';
      case Section.planner:
        return 'Meal Planning';
      case Section.progress:
        return 'Progress & Goals';
      case Section.hydration:
        return 'Hydration';
      case Section.journal:
        return 'Mindful Eating Journal';
      case Section.education:
        return 'Cultural Food Education';
      case Section.community:
        return 'Community';
      case Section.settings:
        return 'Settings';
    }
  }

  ListTile _drawerItem(IconData icon, String label, Section target) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        setState(() => section = target);
      },
    );
  }

  void _refresh() => setState(() {});
}

class OnboardingPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onContinue;

  const OnboardingPage({super.key, required this.state, required this.onContinue});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final TextEditingController emailController;
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController heightController;
  late final TextEditingController weightController;
  late final TextEditingController caloriesController;
  late final TextEditingController waterController;
  String goal = 'Weight Loss';
  String activity = 'Moderate';
  String dietary = 'Balanced';

  @override
  void initState() {
    super.initState();
    final profile = widget.state.profile;
    emailController = TextEditingController(text: profile.email);
    nameController = TextEditingController(text: profile.name);
    ageController = TextEditingController(text: profile.age.toString());
    heightController = TextEditingController(text: profile.heightCm.toString());
    weightController = TextEditingController(text: profile.weightKg.toString());
    caloriesController = TextEditingController(text: profile.dailyCalories.toString());
    waterController = TextEditingController(text: profile.dailyWaterMl.toString());
    goal = profile.goal;
    activity = profile.activityLevel;
    dietary = profile.dietaryPreference;
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              const Text('Calorie Tracker', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Track calories, hydration, recipes, mindful eating, and culturally relevant Middle Eastern food insights in a Flutter starter app.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Tag(label: 'Email/Password Registration'),
                        _Tag(label: 'Social Login Placeholder'),
                        _Tag(label: 'Guest Account'),
                        _Tag(label: 'AI Meal Suggestions'),
                        _Tag(label: 'Middle Eastern Foods'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _card(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Profile Setup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    _field(emailController, 'Email'),
                    const SizedBox(height: 12),
                    _field(nameController, 'Display Name'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _field(ageController, 'Age', number: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(heightController, 'Height (cm)', number: true)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _field(weightController, 'Weight (kg)', number: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(caloriesController, 'Daily Calories', number: true)),
                    ]),
                    const SizedBox(height: 12),
                    _field(waterController, 'Daily Water (ml)', number: true),
                    const SizedBox(height: 12),
                    _dropdown('Goal', goal, ['Weight Loss', 'Maintenance', 'Muscle Gain'], (v) => setState(() => goal = v!)),
                    const SizedBox(height: 12),
                    _dropdown('Activity', activity, ['Low', 'Moderate', 'High'], (v) => setState(() => activity = v!)),
                    const SizedBox(height: 12),
                    _dropdown('Dietary Preference', dietary, ['Balanced', 'Vegetarian', 'High Protein', 'Low Carb'], (v) => setState(() => dietary = v!)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveAndContinue,
                            child: const Text('Save & Continue'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.state.saveProfile(UserProfile(name: 'Guest'));
                          widget.onContinue();
                        },
                        child: const Text('Continue as Guest'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Social login buttons can be connected in the next phase using Firebase Auth / OAuth providers.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return TextField(
      controller: controller,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  void _saveAndContinue() {
    widget.state.saveProfile(
      UserProfile(
        email: emailController.text.trim(),
        name: nameController.text.trim().isEmpty ? 'Guest' : nameController.text.trim(),
        age: int.tryParse(ageController.text) ?? 30,
        heightCm: double.tryParse(heightController.text) ?? 170,
        weightKg: double.tryParse(weightController.text) ?? 75,
        goal: goal,
        activityLevel: activity,
        dietaryPreference: dietary,
        dailyCalories: int.tryParse(caloriesController.text) ?? 2100,
        dailyWaterMl: int.tryParse(waterController.text) ?? 2500,
      ),
    );
    widget.onContinue();
  }
}

class DashboardPage extends StatelessWidget {
  final AppState state;
  final VoidCallback onStateChanged;

  const DashboardPage({super.key, required this.state, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hello, ${state.profile.name}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Daily summary, meal suggestions, and simple progress at a glance.', style: TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _metricCard('Consumed', '${state.consumedCalories}', 'kcal', Icons.local_fire_department_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Remaining', '${state.remainingCalories}', 'kcal', Icons.flag_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard('Water', '${state.waterMl}', 'ml', Icons.water_drop_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Exercise', '${state.burnedCalories}', 'kcal', Icons.directions_run_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Macronutrient Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _macroRow('Protein', state.protein, Colors.redAccent),
              const SizedBox(height: 10),
              _macroRow('Carbs', state.carbs, Colors.green),
              const SizedBox(height: 10),
              _macroRow('Fat', state.fat, Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today’s Recommended Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (final item in state.mealSuggestions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: const Color(0xFFEEF2FF), child: Text(item.name.substring(0, 1))),
                  title: Text(item.name),
                  subtitle: Text('${item.region} • ${item.culturalInsight}'),
                  trailing: Text('${item.calories} kcal'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Latest weight: ${state.weights.last.weightKg.toStringAsFixed(1)} kg'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: state.badges.map((b) => _Tag(label: b)).toList()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mindful Eating Tip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(state.todayTip),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  state.addWater(250);
                  onStateChanged();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added 250 ml of water.')));
                },
                child: const Text('Quick Add Water'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, String unit, IconData icon) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: const TextStyle(color: Color(0xFF6B7280))),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _macroRow(String name, double amount, Color color) {
    final normalized = (amount / 150).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$name: ${amount.toStringAsFixed(0)} g'),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: normalized, minHeight: 10, color: color, backgroundColor: color.withOpacity(0.12)),
        ),
      ],
    );
  }
}

class FoodLogPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  const FoodLogPage({super.key, required this.state, required this.onStateChanged});

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  String mealType = 'Breakfast';

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = widget.state.foods.where((f) {
      if (query.isEmpty) return true;
      return f.name.toLowerCase().contains(query) || f.region.toLowerCase().contains(query) || f.category.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Add', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: mealType,
                decoration: const InputDecoration(labelText: 'Meal Type', border: OutlineInputBorder()),
                items: const ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (v) => setState(() => mealType = v ?? 'Breakfast'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Search food database',
                  hintText: 'Middle Eastern, Lebanese, saved, recent...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        final recognized = widget.state.mockRecognizePhoto();
                        for (final item in recognized) {
                          widget.state.addFood(mealType, item);
                        }
                        widget.onStateChanged();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mock AI recognized ${recognized.length} food items and added them to $mealType.')),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('AI Photo Recognition'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'Try 629000000001',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      final item = widget.state.mockBarcodeLookup(barcodeController.text);
                      if (item == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No mock item found for this barcode.')));
                        return;
                      }
                      widget.state.addFood(mealType, item);
                      widget.onStateChanged();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${item.name} from barcode.')));
                    },
                    child: const Text('Scan'),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Food Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final food in filtered)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${food.region} • ${food.category}', style: const TextStyle(color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              widget.state.addFood(mealType, food);
                              widget.onStateChanged();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${food.name} to $mealType.')));
                            },
                            child: const Text('Add'),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${food.calories} kcal • P ${food.protein.toStringAsFixed(0)} • C ${food.carbs.toStringAsFixed(0)} • F ${food.fat.toStringAsFixed(0)}'),
                      const SizedBox(height: 4),
                      Text(food.culturalInsight),
                      const SizedBox(height: 4),
                      Text(food.micronutrientNote, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    ],
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Meal Details & Nutrition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (widget.state.mealLogs.isEmpty)
                const Text('No meals logged yet. Add foods from the database, mock camera, or barcode action.')
              else
                for (final meal in widget.state.mealLogs)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(meal.mealType),
                    subtitle: Text('${meal.items.fold(0, (sum, i) => sum + i.calories)} kcal total'),
                    children: meal.items
                        .map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.name),
                              subtitle: Text('${item.region} • ${item.category}'),
                              trailing: Text('${item.calories} kcal'),
                            ))
                        .toList(),
                  ),
            ],
          ),
        )
      ],
    );
  }
}

class RecipesPage extends StatelessWidget {
  final AppState state;
  const RecipesPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Recipe Explorer', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Featured Middle Eastern recipes with ingredients, prep steps, and cultural context.', style: TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _Tag(label: 'By Ingredient'),
            _Tag(label: 'By Region'),
            _Tag(label: 'By Nutrition'),
            _Tag(label: 'By Time'),
            _Tag(label: 'By Difficulty'),
          ],
        ),
        const SizedBox(height: 12),
        for (final recipe in state.recipes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(recipe.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${recipe.region} • ${recipe.difficulty} • ${recipe.prepMinutes} min'),
                          ],
                        ),
                      ),
                      _Tag(label: '${recipe.calories} kcal')
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(recipe.culturalContext),
                  const SizedBox(height: 10),
                  const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 8, runSpacing: 8, children: recipe.ingredients.map((i) => _Tag(label: i)).toList()),
                  const SizedBox(height: 10),
                  const Text('Preparation Steps', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  for (int i = 0; i < recipe.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${i + 1}. ${recipe.steps[i]}'),
                    ),
                ],
              ),
            ),
          )
      ],
    );
  }
}

class PlannerPage extends StatelessWidget {
  final AppState state;
  const PlannerPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Meal Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Drag & drop is represented here as a configurable weekly plan placeholder for the starter app.'),
              const SizedBox(height: 10),
              for (final entry in state.mealPlan.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shopping List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: state.shoppingList.map((i) => _Tag(label: i)).toList()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal Prep Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Batch cook lentils and rice for mujadara.'),
              Text('• Chop cucumbers, tomatoes, and herbs ahead for breakfast plates and salads.'),
              Text('• Marinate chicken in shawarma spices at night for quick weekday bowls.'),
              Text('• Store yogurt-based sauces separately to maintain texture.'),
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  const ProgressPage({super.key, required this.state, required this.onStateChanged});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final latest = widget.state.weights.last.weightKg;
    final target = widget.state.profile.goal == 'Muscle Gain' ? latest + 3 : latest - 4;
    final progress = widget.state.profile.goal == 'Muscle Gain'
        ? (latest / target).clamp(0.0, 1.0)
        : ((widget.state.weights.first.weightKg - latest) / (widget.state.weights.first.weightKg - target).abs().clamp(1.0, 9999.0)).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weight Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Log weight (kg)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final value = double.tryParse(weightController.text);
                  if (value == null) return;
                  widget.state.addWeight(value);
                  widget.onStateChanged();
                  setState(() => weightController.clear());
                },
                child: const Text('Save Weight'),
              ),
              const SizedBox(height: 12),
              Text('Goal: ${widget.state.profile.goal}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress, minHeight: 12),
              const SizedBox(height: 6),
              Text('Latest: ${latest.toStringAsFixed(1)} kg • Target preview: ${target.toStringAsFixed(1)} kg'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weight History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final entry in widget.state.weights.reversed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                  subtitle: Text('${entry.date.day}/${entry.date.month}/${entry.date.year}'),
                )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Achievement Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: 'Milestone Achievement'),
                  _Tag(label: 'Cuisine Exploration'),
                  _Tag(label: 'Consistency Streak'),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class HydrationPage extends StatelessWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  const HydrationPage({super.key, required this.state, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    final progress = (state.waterMl / state.profile.dailyWaterMl).clamp(0.0, 1.0);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${state.waterMl} / ${state.profile.dailyWaterMl} ml'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress, minHeight: 12),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(onPressed: () { state.addWater(250); onStateChanged(); }, child: const Text('+250 ml Water')),
                  FilledButton.tonal(onPressed: () { state.addWater(500, beverage: 'Water'); onStateChanged(); }, child: const Text('+500 ml Water')),
                  FilledButton.tonal(onPressed: () { state.addWater(250, beverage: 'Arabic Coffee'); onStateChanged(); }, child: const Text('Arabic Coffee')),
                  FilledButton.tonal(onPressed: () { state.addWater(300, beverage: 'Jallab'); onStateChanged(); }, child: const Text('Jallab')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hydration Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Smart reminders and notification scheduling are represented as placeholders in this starter build.'),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: 'Morning reminder'),
                  _Tag(label: 'Workout reminder'),
                  _Tag(label: 'Afternoon reminder'),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (state.waterLogs.isEmpty)
                const Text('No hydration entries yet.')
              else
                for (final entry in state.waterLogs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_drink_outlined),
                    title: Text(entry.beverage),
                    subtitle: Text('${entry.at.hour.toString().padLeft(2, '0')}:${entry.at.minute.toString().padLeft(2, '0')}'),
                    trailing: Text('${entry.amountMl} ml'),
                  )
            ],
          ),
        )
      ],
    );
  }
}

class JournalPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  const JournalPage({super.key, required this.state, required this.onStateChanged});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final TextEditingController preMealController;
  late final TextEditingController postMealController;
  late final TextEditingController triggerController;
  late final TextEditingController reflectionController;
  double hunger = 5;
  double fullness = 5;

  @override
  void initState() {
    super.initState();
    preMealController = TextEditingController(text: widget.state.currentJournal.preMealEmotion);
    postMealController = TextEditingController(text: widget.state.currentJournal.postMealSatisfaction);
    triggerController = TextEditingController(text: widget.state.currentJournal.trigger);
    reflectionController = TextEditingController(text: widget.state.currentJournal.reflection);
    hunger = widget.state.currentJournal.hungerLevel.toDouble();
    fullness = widget.state.currentJournal.fullnessLevel.toDouble();
  }

  @override
  void dispose() {
    preMealController.dispose();
    postMealController.dispose();
    triggerController.dispose();
    reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Journal Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: preMealController, decoration: const InputDecoration(labelText: 'Pre-meal emotion', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: postMealController, decoration: const InputDecoration(labelText: 'Post-meal satisfaction', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Text('Hunger / Fullness Scale'),
              const SizedBox(height: 8),
              Text('Hunger: ${hunger.toStringAsFixed(0)}'),
              Slider(value: hunger, min: 1, max: 10, divisions: 9, onChanged: (v) => setState(() => hunger = v)),
              Text('Fullness: ${fullness.toStringAsFixed(0)}'),
              Slider(value: fullness, min: 1, max: 10, divisions: 9, onChanged: (v) => setState(() => fullness = v)),
              const SizedBox(height: 8),
              TextField(controller: triggerController, decoration: const InputDecoration(labelText: 'Emotional trigger', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                controller: reflectionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Reflection / coping strategy', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  widget.state.saveJournal(
                    JournalEntry(
                      preMealEmotion: preMealController.text,
                      postMealSatisfaction: postMealController.text,
                      hungerLevel: hunger.round(),
                      fullnessLevel: fullness.round(),
                      trigger: triggerController.text,
                      reflection: reflectionController.text,
                    ),
                  );
                  widget.onStateChanged();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal saved.')));
                },
                child: const Text('Save Journal'),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mindfulness Exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Guided eating meditation placeholder'),
              Text('• Breathing exercise placeholder'),
              Text('• Mindful eating tip rotation placeholder'),
            ],
          ),
        )
      ],
    );
  }
}

class EducationPage extends StatelessWidget {
  final AppState state;
  const EducationPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Food Encyclopedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Ingredient Guide: parsley, chickpeas, lentils, zaatar, tahini, labneh, olive oil.'),
              SizedBox(height: 8),
              Text('Traditional dishes explained: tabbouleh, hummus, mujadara, manakish, shawarma bowls.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cooking Techniques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Toast spices lightly before use for deeper aroma.'),
              Text('• Use fresh herbs generously for brightness and volume.'),
              Text('• Yogurt sauces can increase satiety while keeping meals balanced.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cultural Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Middle Eastern dining often centers around sharing plates, hospitality, and balancing herbs, grains, proteins, and dips.'),
              SizedBox(height: 8),
              Text('The production version can expand this section into a full encyclopedia with regional variations, videos, and dining customs.'),
            ],
          ),
        )
      ],
    );
  }
}

class CommunityPage extends StatelessWidget {
  final AppState state;
  const CommunityPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recipe Sharing & Success Stories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...state.communityPosts.map((post) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $post'),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discussion Forums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Cooking tips'),
              Text('• Nutritional advice'),
              Text('• Regional food discussions'),
              SizedBox(height: 8),
              Text('The production version should connect this section to a backend with posts, comments, moderation, ratings, and reporting.'),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onStateChanged;
  const SettingsPage({super.key, required this.state, required this.onStateChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController nameController;
  late final TextEditingController caloriesController;
  late final TextEditingController waterController;
  String language = 'English';
  String units = 'Metric';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.state.profile.name);
    caloriesController = TextEditingController(text: widget.state.profile.dailyCalories.toString());
    waterController = TextEditingController(text: widget.state.profile.dailyWaterMl.toString());
    language = widget.state.profile.language;
    units = widget.state.profile.units;
  }

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: caloriesController, keyboardType: const TextInputType.numberWithOptions(decimal: false), decoration: const InputDecoration(labelText: 'Daily Calories', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: waterController, keyboardType: const TextInputType.numberWithOptions(decimal: false), decoration: const InputDecoration(labelText: 'Daily Water (ml)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                items: const ['English', 'Arabic', 'French'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => language = v ?? 'English'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: units,
                decoration: const InputDecoration(labelText: 'Units', border: OutlineInputBorder()),
                items: const ['Metric', 'Imperial'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => units = v ?? 'Metric'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
                title: const Text('Notifications enabled'),
                subtitle: const Text('Placeholder until local notifications are integrated.'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final profile = widget.state.profile;
                  widget.state.saveProfile(
                    UserProfile(
                      email: profile.email,
                      name: nameController.text.trim().isEmpty ? profile.name : nameController.text.trim(),
                      age: profile.age,
                      heightCm: profile.heightCm,
                      weightKg: profile.weightKg,
                      gender: profile.gender,
                      goal: profile.goal,
                      activityLevel: profile.activityLevel,
                      dietaryPreference: profile.dietaryPreference,
                      familiarWithMiddleEasternCuisine: profile.familiarWithMiddleEasternCuisine,
                      dailyCalories: int.tryParse(caloriesController.text) ?? profile.dailyCalories,
                      dailyWaterMl: int.tryParse(waterController.text) ?? profile.dailyWaterMl,
                      language: language,
                      units: units,
                    ),
                  );
                  widget.onStateChanged();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved.')));
                },
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data & Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Export, device sync, and third-party integrations are represented as roadmap items in this starter project.'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: 'Export Data'),
                  _Tag(label: 'Connect Devices'),
                  _Tag(label: 'FAQ'),
                  _Tag(label: 'Support'),
                  _Tag(label: 'Tutorial Videos'),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

Widget _card({required Widget child}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}
