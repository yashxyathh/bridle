import 'package:flutter/material.dart';
import 'game.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Birdle'),
        ),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(_fade),
            child: GamePage(),
          ),
        ),
      ),
    ),
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// main game page
class GamePage extends StatefulWidget {
  GamePage({super.key});
  final Game _game = Game();

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_game.didWin ? 'You got it! 🎉' : 'Out of guesses'),
        content: Text('The word was "${_game.hiddenWord}".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _game.resetGame());
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 5.0,
              children: [
                for (var guess in _game.guesses)
                  Row(
                    spacing: 5.0,
                    children: [
                      for (var letter in guess) Tile(letter.char, letter.type),
                    ],
                  ),
                Column(
                  children: [
                    GuessInput(
                      onSubmitGuess: (String guess) {
                        setState(() => _game.guess(guess));
                        if (_game.didWin || _game.didLose) _showResultDialog();
                      },
                    ),
                    OnScreenKeyboard(
                      letterStatuses: _game.letterStatuses,
                      onKeyTap: (c) {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// tile which is dispalyed
class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});
  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(hitType), // restarts the tween whenever hitType changes
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        final angle = (1 - value) * (3.14159 / 2);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateX(angle),
          child: child,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: switch (hitType) {
            HitType.hit => Colors.green,
            HitType.partial => Colors.yellow,
            HitType.miss => Colors.grey,
            _ => Colors.white,
          },
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}

// implementation of guess input
class GuessInput extends StatelessWidget {
  GuessInput({super.key, required this.onSubmitGuess});
  final void Function(String) onSubmitGuess;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
              ),
              controller: _textEditingController,
              autofocus: true,
              focusNode: _focusNode,

              onSubmitted: (input) {
                onSubmitGuess(input.trim());
                _textEditingController.clear();
                _focusNode.requestFocus();
              },
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_circle_up),
          onPressed: () {
            onSubmitGuess(_textEditingController.text.trim());
            _textEditingController.clear();
            _focusNode.requestFocus();
          },
        ),
        IconButton(
          icon: const Icon(Icons.lightbulb_outline),
          onPressed: () {
            final i = Random().nextInt(5);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Letter ${i + 1} is "${_game.hintLetterAt(i).toUpperCase()}"',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class OnScreenKeyboard extends StatelessWidget {
  const OnScreenKeyboard({
    super.key,
    required this.letterStatuses,
    required this.onKeyTap,
  });
  final Map<String, HitType> letterStatuses;
  final void Function(String) onKeyTap;
  static const _rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
  Color _colorFor(String c) => switch (letterStatuses[c]) {
    HitType.hit => Colors.green,
    HitType.partial => Colors.yellow,
    HitType.miss => Colors.grey,
    _ => Colors.grey.shade200,
  };
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final row in _rows)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final c in row.split(''))
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: () => onKeyTap(c),
                  child: Container(
                    width: 32,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _colorFor(c),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(c.toUpperCase()),
                  ),
                ),
              ),
          ],
        ),
    ],
  );
}
