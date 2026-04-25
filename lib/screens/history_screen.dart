import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/game_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameModel> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final games = await DatabaseHelper.instance.getAllGames();
    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to clear all game history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.clearAllGames();
                await _loadHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared successfully')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
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
        title: const Text('Game History'),
        centerTitle: true,
        actions: [
          if (_games.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No game history yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Play a game to see your history here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        game.isWin ? 'Victory Details 🎉' : 'Game Details',
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target Number: ${game.targetNumber}'),
                          const SizedBox(height: 8),
                          Text('Attempts: ${game.attempts}'),
                          const SizedBox(height: 8),
                          Text('Range: ${game.minNumber} - ${game.maxNumber}'),
                          const SizedBox(height: 8),
                          Text('Date: ${game.getFormattedDate()}'),
                          const SizedBox(height: 8),
                          Text(
                            'Result: ${game.isWin ? "Won" : "Lost"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: game.isWin ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: game.isWin ? Colors.green : Colors.red,
                  child: Icon(
                    game.isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Range: ${game.minNumber} - ${game.maxNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target: ${game.targetNumber}'),
                    Text('Attempts: ${game.attempts}'),
                    Text('Date: ${game.getFormattedDate()}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Record'),
                          content: const Text('Are you sure you want to delete this game record?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteGame(game.id!);
                                await _loadHistory();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Record deleted')),
                                );
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }
}