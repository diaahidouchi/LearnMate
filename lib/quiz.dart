import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Map<String, dynamic>> _allQuestions = [];
  List<Map<String, dynamic>> _remainingQuestions = [];
  List<Map<String, dynamic>> _currentQuizSet = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    String jsonString = await rootBundle.rootBundle.loadString('assets/questions.json');
    List<dynamic> jsonResponse = jsonDecode(jsonString);

    _allQuestions = jsonResponse.map((question) {
      return {
        'question': question['question'],
        'answers': List<String>.from(question['answers']),
        'correctAnswer': question['correctAnswer'],
      };
    }).toList();

    _remainingQuestions = List.from(_allQuestions);
    _startNewQuizSet();
  }

  void _startNewQuizSet() {
    final random = Random();
    _remainingQuestions.shuffle(random);

    int takeCount = _remainingQuestions.length >= 5 ? 5 : _remainingQuestions.length;
    _currentQuizSet = _remainingQuestions.take(takeCount).toList();
    _remainingQuestions.removeRange(0, takeCount);

    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
    });
    _controller.forward(from: 0.0);
  }

  void _answerQuestion(String answer) {
    if (answer == _currentQuizSet[_currentQuestionIndex]['correctAnswer']) {
      _score++;
    }

    setState(() {
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= _currentQuizSet.length) {
      _showResult();
    } else {
      _controller.forward(from: 0.0);
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Quiz Finished',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= _currentQuizSet.length * 0.7
                  ? Icons.celebration_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              size: 64,
              color: _score >= _currentQuizSet.length * 0.7
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16),
            Text(
              'Your score: $_score/${_currentQuizSet.length}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_remainingQuestions.isEmpty) {
                _showAllDoneDialog();
              } else {
                _startNewQuizSet();
              }
            },
            child: Text(
              'Next Set',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllDoneDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'All Questions Completed',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Text(
          'You finished all questions. Start again?',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _remainingQuestions = List.from(_allQuestions);
              });
              _startNewQuizSet();
            },
            child: Text(
              'Restart',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: _currentQuizSet.isEmpty
          ? Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              ),
            )
          : _currentQuestionIndex < _currentQuizSet.length
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1}/${_currentQuizSet.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  _currentQuizSet[_currentQuestionIndex]['question'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 24),
                                ...(_currentQuizSet[_currentQuestionIndex]['answers'] as List<String>)
                                    .map((answer) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _answerQuestion(answer),
                                      icon: Icon(Icons.question_answer_rounded),
                                      label: Text(
                                        answer,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: SpinKitFadingCircle(
                    color: Theme.of(context).colorScheme.primary,
                    size: 50.0,
                  ),
                ),
    );
  }
}
