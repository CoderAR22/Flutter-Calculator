import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  // ignore: use_super_parameters
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: CalculatorHome(
        isDarkMode: isDarkMode,
        onThemeChanged: (val) {
          setState(() {
            isDarkMode = val;
          });
        },
      ),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const CalculatorHome({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  int _selectedIndex = 0;
  String userInput = '';
  String answer = '';

  final List<String> buttons = [
    'C', '+/-', '%', 'DEL',
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '=', '+',
  ];

  List<String> history = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isOperator(String x) {
    return (x == '/' || x == '*' || x == '-' || x == '+' || x == '=');
  }

  void calculateResult() {
    String finalInput = userInput.replaceAll('x', '*');
    try {
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      answer = eval.toString();

      // Save to history
      if (userInput.isNotEmpty) {
        history.insert(0, '$userInput = $answer');
      }
      userInput = answer;
    } catch (e) {
      answer = 'Error';
    }
  }

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        userInput = '';
        answer = '';
      } else if (buttonText == 'DEL') {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (buttonText == '=') {
        calculateResult();
      } else if (buttonText == '+/-') {
        // Toggle plus/minus for current input
        if (userInput.isNotEmpty) {
          if (userInput.startsWith('-')) {
            userInput = userInput.substring(1);
          } else {
            userInput = '-$userInput';
          }
        }
      } else {
        userInput += buttonText;
      }
    });
  }

  Widget buildCalculator() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomRight,
            child: Text(
              userInput,
              style: TextStyle(fontSize: 28, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topRight,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.orange : Colors.blue,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (BuildContext context, int index) {
                Color buttonColor;
                Color textColor;

                if (buttons[index] == 'C' || buttons[index] == 'DEL' || buttons[index] == '+/-' || buttons[index] == '%') {
                  buttonColor = widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
                  textColor = widget.isDarkMode ? Colors.white : Colors.black;
                } else if (isOperator(buttons[index])) {
                  buttonColor = widget.isDarkMode ? Colors.orange.shade700 : Colors.blue.shade700;
                  textColor = Colors.white;
                } else {
                  buttonColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
                  textColor = widget.isDarkMode ? Colors.white : Colors.black;
                }

                return ElevatedButton(
                  onPressed: () => onButtonPressed(buttons[index]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    buttons[index],
                    style: TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHistory() {
    if (history.isEmpty) {
      return const Center(
        child: Text('No history yet.', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(history[index], style: const TextStyle(fontSize: 18)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // You can add menu action here
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu clicked')));
          },
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.wb_sunny),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
                activeColor: Colors.orange,
                inactiveThumbColor: Colors.yellow,
              ),
              const Icon(Icons.nightlight_round),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: _selectedIndex == 0 ? buildCalculator() : buildHistory(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
