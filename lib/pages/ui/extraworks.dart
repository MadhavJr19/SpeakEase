import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StoryGenerationScreen extends StatefulWidget {
  const StoryGenerationScreen({super.key});

  @override
  State<StoryGenerationScreen> createState() => _StoryGenerationScreenState();
}

class _StoryGenerationScreenState extends State<StoryGenerationScreen> with TickerProviderStateMixin {
  String? currentStory;
  bool isPracticed = false;
  List<String> favoriteStories = [];
  bool isGenerating = false;
  List<PracticeRecord> practiceRecords = [];
  late TabController _tabController;
  final TextEditingController _difficultyController = TextEditingController();
  String selectedDifficulty = 'Easy';
  String? selectedPracticeFocus;

  // Animation controller
  late AnimationController _confettiController;

  // Sample story components for random generation with difficulty levels
  final Map<String, List<String>> charactersMap = {
    'Easy': [
      'a curious fox',
      'a brave knight',
      'a playful dolphin',
      'a wise owl',
      'a cheerful robot',
    ],
    'Medium': [
      'an adventurous squirrel',
      'a mysterious wizard',
      'a determined astronaut',
      'a clever detective',
      'a mischievous fairy',
    ],
    'Hard': [
      'a philosophical tortoise',
      'an eccentric scientist',
      'a sophisticated dragon',
      'a revolutionary inventor',
      'a contemplative ghost',
    ],
  };

  final Map<String, List<String>> settingsMap = {
    'Easy': [
      'in a magical forest',
      'on a sunny beach',
      'under the deep ocean',
      'in a big city',
      'on a farm',
    ],
    'Medium': [
      'in an ancient castle',
      'on a mysterious island',
      'through a secret garden',
      'during a thunderstorm',
      'aboard a flying ship',
    ],
    'Hard': [
      'in a parallel dimension',
      'amidst the celestial constellations',
      'through the labyrinthine catacombs',
      'during the renaissance period',
      'within a microscopic world',
    ],
  };

  final Map<String, List<String>> actionsMap = {
    'Easy': [
      'found a shiny treasure',
      'made a new friend',
      'learned to fly',
      'built a cozy house',
      'solved a simple puzzle',
    ],
    'Medium': [
      'discovered a hidden map',
      'rescued a trapped animal',
      'invented a helpful gadget',
      'decoded a secret message',
      'organized a grand celebration',
    ],
    'Hard': [
      'orchestrated an elaborate expedition',
      'negotiated peace between rival kingdoms',
      'unraveled a centuries-old mystery',
      'revolutionized transportation methods',
      'established communication with extraterrestrial beings',
    ],
  };

  // Speech practice focus areas
  final List<String> practiceFocusAreas = [
    'Articulation: S sounds',
    'Articulation: R sounds',
    'Articulation: L sounds',
    'Articulation: TH sounds',
    'Fluency: Slow speech',
    'Voice: Projection',
    'Language: Storytelling',
    'Language: Descriptive words',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadPracticeRecords();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteStories = prefs.getStringList('favoriteStories') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteStories', favoriteStories);
  }

  Future<void> _loadPracticeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordStrings = prefs.getStringList('practiceRecords') ?? [];
    setState(() {
      practiceRecords = recordStrings
          .map((record) {
        final parts = record.split('|');
        if (parts.length >= 3) {
          return PracticeRecord(
            story: parts[0],
            date: DateTime.parse(parts[1]),
            focusArea: parts.length > 3 ? parts[2] : 'General practice',
            difficulty: parts.length > 3 ? parts[3] : 'Easy',
          );
        }
        return null;
      })
          .whereType<PracticeRecord>()
          .toList();
    });
  }

  Future<void> _savePracticeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordStrings = practiceRecords
        .map((record) =>
    '${record.story}|${record.date.toIso8601String()}|${record.focusArea}|${record.difficulty}')
        .toList();
    await prefs.setStringList('practiceRecords', recordStrings);
  }

  void _generateStory() {
    setState(() {
      isGenerating = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      final random = Random();

      // Select components based on difficulty
      final characters = charactersMap[selectedDifficulty] ?? charactersMap['Easy']!;
      final settings = settingsMap[selectedDifficulty] ?? settingsMap['Easy']!;
      final actions = actionsMap[selectedDifficulty] ?? actionsMap['Easy']!;

      final character = characters[random.nextInt(characters.length)];
      final setting = settings[random.nextInt(settings.length)];
      final action = actions[random.nextInt(actions.length)];

      // Create a more developed story based on difficulty
      String story;
      if (selectedDifficulty == 'Easy') {
        story = 'Once upon a time, $character $action $setting. The end.';
      } else if (selectedDifficulty == 'Medium') {
        story = 'Once upon a time, $character was exploring $setting when something amazing happened. The $character $action and learned an important lesson about friendship. Everyone celebrated and lived happily ever after.';
      } else {
        story = 'In a time long forgotten, $character embarked on an extraordinary journey $setting. After facing numerous challenges and obstacles, the $character finally $action. This remarkable achievement changed everything, teaching everyone about courage, perseverance, and the importance of believing in oneself. The legend of this adventure would be told for generations to come.';
      }

      setState(() {
        currentStory = story;
        isPracticed = false;
        isGenerating = false;
      });
    });
  }

  void _markAsPracticed() {
    if (currentStory == null) return;

    setState(() {
      isPracticed = true;

      // Add to practice records
      practiceRecords.add(PracticeRecord(
        story: currentStory!,
        date: DateTime.now(),
        focusArea: selectedPracticeFocus ?? 'General practice',
        difficulty: selectedDifficulty,
      ));

      _savePracticeRecords();
    });

    // Show celebration animation
    _confettiController.forward(from: 0);

    // Show congratulatory dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_touohxv0.json',
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 15),
                Text(
                  'Great job!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You\'ve practiced this story successfully!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(
                  'Keep Going!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _toggleFavorite() {
    if (currentStory == null) return;
    setState(() {
      if (favoriteStories.contains(currentStory)) {
        favoriteStories.remove(currentStory);
      } else {
        favoriteStories.add(currentStory!);
      }
      _saveFavorites();
    });
  }

  void _copyToClipboard() {
    if (currentStory != null) {
      Clipboard.setData(ClipboardData(text: currentStory!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Story copied to clipboard!',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF323232), size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Speech Practice Stories',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.help_outline, color: Color(0xFF323232), size: 20),
            ),
            onPressed: () {
              _showHelpDialog();
            },
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Stories'),
            Tab(text: 'Favorites'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF42A5F5),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStoriesTab(),
              _buildFavoritesTab(),
              _buildProgressTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeaderWithLottie(),
            const SizedBox(height: 20),
            _buildStorySettings(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _generateStory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories, color: Color(0xFF1976D2)),
                    const SizedBox(width: 10),
                    Text(
                      'Generate Story',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (isGenerating)
              Center(
                child: Column(
                  children: [
                    Lottie.network(
                      'https://assets10.lottiefiles.com/packages/lf20_l5qvvz.json',
                      height: 120,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Creating your story...',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else if (currentStory != null)
              _buildStoryCard()
            else
              _buildPlaceholder(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithLottie() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Practice Speaking',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'Generate fun stories to read aloud!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Lottie.network(
            'https://assets5.lottiefiles.com/packages/lf20_qp1q7mct.json',
            repeat: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStorySettings() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Story Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          // Difficulty selector
          Text(
            'Difficulty:',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildDifficultyOption('Easy', Colors.green),
                _buildDifficultyOption('Medium', Colors.orange),
                _buildDifficultyOption('Hard', Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Practice focus dropdown
          Text(
            'Practice Focus:',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF1976D2),
                isExpanded: true,
                hint: Text(
                  'Select focus area',
                  style: GoogleFonts.nunito(color: Colors.white),
                ),
                value: selectedPracticeFocus,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: practiceFocusAreas.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPracticeFocus = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption(String label, Color color) {
    final isSelected = selectedDifficulty == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDifficulty = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.7) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard() {
    final wordCount = currentStory!.split(' ').length;
    final isFavorite = favoriteStories.contains(currentStory);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedDifficulty == 'Easy'
                          ? Colors.green.withOpacity(0.2)
                          : selectedDifficulty == 'Medium'
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      selectedDifficulty,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: selectedDifficulty == 'Easy'
                            ? Colors.green
                            : selectedDifficulty == 'Medium'
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$wordCount words',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, color: Colors.blue),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            currentStory!,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (selectedPracticeFocus != null)
                Chip(
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.2),
                  label: Text(
                    selectedPracticeFocus!,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: isPracticed ? null : _markAsPracticed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: isPracticed ? Colors.grey : const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPracticed ? Icons.check : Icons.mic,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPracticed ? 'Practiced' : 'Mark as Practiced',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (favoriteStories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets5.lottiefiles.com/packages/lf20_0s6tfbuc.json',
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'No favorite stories yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Generate stories and add them to your favorites for easy access',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: favoriteStories.length,
      itemBuilder: (context, index) {
        final story = favoriteStories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.length > 100 ? '${story.substring(0, 100)}...' : story,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_copy, color: Colors.blue, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: story));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Story copied to clipboard!',
                            style: GoogleFonts.nunito(),
                          ),
                          backgroundColor: Colors.teal,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy to clipboard',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        favoriteStories.removeAt(index);
                        _saveFavorites();
                      });
                    },
                    tooltip: 'Remove from favorites',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    if (practiceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets8.lottiefiles.com/packages/lf20_5tvifusg.json',
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'No practice sessions yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Practice stories and track your progress over time',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sort records by date, most recent first
    final sortedRecords = List<PracticeRecord>.from(practiceRecords)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildProgressStats(),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              final record = sortedRecords[index];
              final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(record.date);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.difficulty == 'Easy'
                              ? Colors.green.withOpacity(0.2)
                              : record.difficulty == 'Medium'
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          record.difficulty,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: record.difficulty == 'Easy'
                                ? Colors.green
                                : record.difficulty == 'Medium'
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          record.focusArea,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  children: [
                    Text(
                      record.story,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.content_copy, size: 16),
                          label: Text(
                            'Copy',
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: record.story));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Story copied to clipboard!',
                                  style: GoogleFonts.nunito(),
                                ),
                                backgroundColor: Colors.teal,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats() {
    // Calculate stats
    final totalPracticed = practiceRecords.length;

    // Count practices by difficulty
    int easyCount = 0;
    int mediumCount = 0;
    int hardCount = 0;

    for (final record in practiceRecords) {
      if (record.difficulty == 'Easy') {
        easyCount++;
      } else if (record.difficulty == 'Medium') {
        mediumCount++;
      } else if (record.difficulty == 'Hard') {
        hardCount++;
      }
    }

    // Count practices by focus areas
    final focusAreaCounts = <String, int>{};
    for (final record in practiceRecords) {
      focusAreaCounts[record.focusArea] = (focusAreaCounts[record.focusArea] ?? 0) + 1;
    }

    // Find most practiced focus area
    String? mostPracticedFocus;
    int mostPracticedCount = 0;

    focusAreaCounts.forEach((focus, count) {
      if (count > mostPracticedCount) {
        mostPracticedFocus = focus;
        mostPracticedCount = count;
      }
    });

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total', totalPracticed.toString(), Icons.auto_stories),
              _buildStatCard('Easy', easyCount.toString(), Icons.sentiment_satisfied, Colors.green),
              _buildStatCard('Medium', mediumCount.toString(), Icons.sentiment_neutral, Colors.orange),
              _buildStatCard('Hard', hardCount.toString(), Icons.sentiment_very_dissatisfied, Colors.red),
            ],
          ),
          if (mostPracticedFocus != null) ...[
            const SizedBox(height: 15),
            Text(
              'Most practiced: $mostPracticedFocus',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF1976D2)).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color ?? const Color(0xFF1976D2),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1976D2),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        children: [
          Lottie.network(
            'https://assets5.lottiefiles.com/packages/lf20_Cou4dx.json',
            height: 200,
          ),
          const SizedBox(height: 10),
          Text(
            'Generate a story to practice',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Customize the difficulty and focus area for your practice needs',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'How to Use',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1976D2),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  '1. Choose Difficulty',
                  'Select Easy, Medium, or Hard based on your speech skill level',
                  Icons.tune,
                ),
                _buildHelpItem(
                  '2. Select Focus Area',
                  'Choose a specific speech skill you want to practice',
                  Icons.center_focus_strong,
                ),
                _buildHelpItem(
                  '3. Generate Story',
                  'Create a new story that includes elements relevant to your focus area',
                  Icons.auto_stories,
                ),
                _buildHelpItem(
                  '4. Practice Speaking',
                  'Read the story aloud, focusing on your selected speech skills',
                  Icons.record_voice_over,
                ),
                _buildHelpItem(
                  '5. Mark as Practiced',
                  'Record your progress to see improvement over time',
                  Icons.check_circle_outline,
                ),
                _buildHelpItem(
                  '6. Save Favorites',
                  'Keep stories you like for future practice sessions',
                  Icons.favorite,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Got it!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeRecord {
  final String story;
  final DateTime date;
  final String focusArea;
  final String difficulty;

  PracticeRecord({
    required this.story,
    required this.date,
    required this.focusArea,
    required this.difficulty,
  });
}