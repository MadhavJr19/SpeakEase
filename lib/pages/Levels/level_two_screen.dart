import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LevelTwoScreen extends StatefulWidget {
  @override
  _LevelTwoScreenState createState() => _LevelTwoScreenState();
}

class _LevelTwoScreenState extends State<LevelTwoScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = "";
  String _currentSound = "";
  bool _feedbackShown = false;
  double _progress = 0.0;
  Timer? _timer;

  final List<String> sounds = [
    "bah", "be", "bi", "bo", "bu", "da", "de", "di", "do", "du", "ka", "ke", "ki", "ko", "ku"
  ];
  int _completedSounds = 0;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech Status: $status"),
      onError: (error) => print("Speech Error: $error"),
    );

    if (!available) {
      print("Speech recognition not available");
    }
  }

  void _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1);
    await _flutterTts.speak(text);
  }

  void _startListening(String sound) async {
    _currentSound = sound;
    _feedbackShown = false;

    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = "";
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords.trim();
            });

            if (_recognizedText.isNotEmpty) {
              _processSpeechRecognition();
            }
          },
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          localeId: "en-US",
        );

        _timer = Timer(const Duration(seconds: 6), _stopListening);
      } else {
        print("Speech Recognition Not Available");
      }
    } else {
      print("Microphone Permission Denied");
    }
  }

  void _stopListening() {
    _speech.stop();
    _timer?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  void _processSpeechRecognition() {
    if (_feedbackShown) return;
    _feedbackShown = true;
    _stopListening();

    if (_recognizedText.toLowerCase() == _currentSound.toLowerCase()) {
      _speak("Good job! You said $_currentSound.");
      _showFeedbackDialog("Good Job!", "You said the correct sound.");
      setState(() {
        _completedSounds++;
        _progress = _completedSounds / sounds.length;
      });
    } else {
      _speak("Try again. You said $_recognizedText.");
      _showFeedbackDialog(
          "Try Again!", "You said $_recognizedText. Try saying $_currentSound.");
    }
  }

  void _showFeedbackDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Level Two: Consonant-Vowel Sounds"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white,
              color: Colors.greenAccent,
              minHeight: 12,
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: sounds.map((sound) => _buildSoundCard(sound)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard(String sound) {
    return Container(
      width: (MediaQuery.of(context).size.width / 3) - 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            sound,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () => _speak(sound),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            child: const Text("Hear", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => _isListening && _currentSound == sound
                ? _stopListening()
                : _startListening(sound),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            child: Text(_isListening && _currentSound == sound ? "Stop" : "Rehearse", style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}