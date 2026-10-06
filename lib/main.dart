import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const QubCalculatorClone());
}

class QubCalculatorClone extends StatelessWidget {
  const QubCalculatorClone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), 
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = "0";
  String result = "0";

  // Expanded layout with new scientific features and parentheses
  final List<String> buttons = [
    '📷', 'AC', 'C', '%',
    'sin', 'cos', 'tan', '/',
    'log', '√', '^', 'x',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '(',
    '0', '.', ')', '=',
  ];

  Future<void> scanMathProblem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        String scannedEquation = recognizedText.text
            .replaceAll('\n', '')
            .replaceAll(' ', '')
            .replaceAll('X', 'x');

        setState(() {
          equation = scannedEquation.isEmpty ? "0" : scannedEquation;
          result = "Scanned!";
        });
      } catch (e) {
        setState(() {
          result = "Scan Failed";
        });
      } finally {
        textRecognizer.close();
      }
    }
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        equation = "0";
        result = "0";
      } else if (buttonText == 'C') {
        equation = equation.substring(0, equation.length - 1);
        if (equation.isEmpty) {
          equation = "0";
        }
      } else if (buttonText == '📷') {
        scanMathProblem();
      } else if (buttonText == '=') {
        try {
          // Replace UI symbols with math_expressions syntax
          String expression = equation
            .replaceAll('x', '*')
            .replaceAll('√', 'sqrt'); 
          
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          
          if (result.endsWith(".0")) {
            result = result.substring(0, result.length - 2);
          }
        } catch (e) {
          result = "Error"; 
        }
      } else if (['sin', 'cos', 'tan', 'log'].contains(buttonText)) {
        if (equation == "0") {
          equation = "$buttonText(";
        } else {
          equation = equation + "$buttonText(";
        }
      } else if (buttonText == '√') {
        if (equation == "0") {
          equation = "√(";
        } else {
          equation = equation + "√(";
        }
      } else {
        if (equation == "0") {
          equation = buttonText; 
        } else {
          equation = equation + buttonText; 
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    equation,
                    style: const TextStyle(fontSize: 36, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1, // Slightly adjusted ratio to fit 7 rows better
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _buildButton(buttons[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    Color bgColor = Colors.grey[850]!;
    Color textColor = Colors.white;

    if (text == 'AC' || text == 'C' || text == '%') {
      bgColor = Colors.grey[600]!;
    } else if (text == '/' || text == 'x' || text == '-' || text == '+' || text == '=') {
      bgColor = Colors.orange;
    } else if (['sin', 'cos', 'tan', 'log', '√', '^', '(', ')', '📷'].contains(text)) {
      bgColor = Colors.blueGrey[800]!; 
    }

    return InkWell(
      onTap: () => buttonPressed(text), 
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}