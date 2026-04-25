import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'result_screen.dart';
import '../models/game_model.dart';


class GuessScreen extends StatefulWidget {
  final int maxNumber;
  const GuessScreen({super.key, required this.maxNumber});

  @override
  State<GuessScreen> createState() => _GuessScreenState();
}

class _GuessScreenState extends State<GuessScreen> {
  late int _targetNumber;
  late int _attempts;
  late List<int> _guessHistory;
  final TextEditingController _guessController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _message = '';
  Color _messageColor = Colors.black;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _targetNumber = DateTime.now().millisecondsSinceEpoch % widget.maxNumber + 1;
    _attempts = 0;
    _guessHistory = [];
    _message = 'Guess a number between 1 and ${widget.maxNumber}';
    _messageColor = Colors.blue;
    _gameOver = false;
    _guessController.clear();
  }

  void _checkGuess() {
    if (_formKey.currentState!.validate()) {
      int guess = int.parse(_guessController.text);
      _attempts++;
      _guessHistory.add(guess);

      if (guess == _targetNumber) {
        _message = 'Congratulations! You guessed it in $_attempts attempts! 🎉';
        _messageColor = Colors.green;
        _gameOver = true;
        _saveGameResult(true);
      } else if (guess < _targetNumber) {
        _message = 'Too low! Try a higher number. ⬆️';
        _messageColor = Colors.orange;
      } else {
        _message = 'Too high! Try a lower number. ⬇️';
        _messageColor = Colors.orange;
      }

      _guessController.clear();
      setState(() {});

      if (_gameOver) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                attempts: _attempts,
                targetNumber: _targetNumber,
                maxNumber: widget.maxNumber,
                isWin: true,
              ),
            ),
          );
        });
      }
    }
  }

  Future<void> _saveGameResult(bool isWin) async {
    final game = GameModel(
      targetNumber: _targetNumber,
      attempts: _attempts,
      date: DateTime.now(),
      isWin: isWin,
      maxNumber: widget.maxNumber,
      minNumber: 1,
    );
    await DatabaseHelper.instance.insertGame(game);
  }

  void _giveUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Give Up?'),
          content: Text('The number was $_targetNumber. Do you want to give up?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _saveGameResult(false);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      attempts: _attempts,
                      targetNumber: _targetNumber,
                      maxNumber: widget.maxNumber,
                      isWin: false,
                    ),
                  ),
                );
              },
              child: const Text('Give Up', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess Number (1-${widget.maxNumber})'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetGame();
              setState(() {});
            },
            tooltip: 'New Game',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text(
                      'Attempts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_attempts',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _messageColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _guessController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter your guess',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                      suffixText: 'Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a number';
                      }
                      int? number = int.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      if (number < 1 || number > widget.maxNumber) {
                        return 'Please enter a number between 1 and ${widget.maxNumber}';
                      }
                      return null;
                    },
                    enabled: !_gameOver,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _gameOver ? null : _checkGuess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit Guess',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _gameOver ? null : _giveUp,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Give Up'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_guessHistory.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guess History:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _guessHistory.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                'Guess: ${_guessHistory[index]}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(
                                _guessHistory[index] < _targetNumber
                                    ? Icons.arrow_upward
                                    : _guessHistory[index] > _targetNumber
                                    ? Icons.arrow_downward
                                    : Icons.check_circle,
                                color: _guessHistory[index] == _targetNumber
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }
}