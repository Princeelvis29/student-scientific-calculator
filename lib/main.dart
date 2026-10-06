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
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Dark background
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

  // Expanded WAEC/JAMB layout including a Camera button
  final List<String> buttons = [
    '📷', 'AC', 'C', '%',
    'sin', 'cos', 'tan', '/',
    '7', '8', '9', 'x',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    'log', '0', '.', '=',
  ];

  // AI Camera Scanner Logic
  Future<void> scanMathProblem() async {
    final ImagePicker picker = ImagePicker();
    // Launch the device camera
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        // Process the image and extract text
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        // Clean the recognized text to fit our parser
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

  // Core Logic: Handles button presses and updates the screen
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
        scanMathProblem(); // Triggers the AI Scanner
      } else if (buttonText == '=') {
        try {
          // Replace 'x' with '*' so the parser understands multiplication
          String expression = equation.replaceAll('x', '*');
          
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          
          // Evaluate the math expression
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          
          // Remove decimal if it's a whole number (e.g., 5.0 becomes 5)
          if (result.endsWith(".0")) {
            result = result.substring(0, result.length - 2);
          }
        } catch (e) {
          result = "Error"; // Catches invalid syntax like "++"
        }
      } else if (['sin', 'cos', 'tan', 'log'].contains(buttonText)) {
        // Appends the function with an open parenthesis
        if (equation == "0") {
          equation = "$buttonText(";
        } else {
          equation = equation + "$buttonText(";
        }
      } else {
        if (equation == "0") {
          equation = buttonText; // Replace the initial 0
        } else {
          equation = equation + buttonText; // Append new numbers/operators
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Screen Display Area
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
          // Button Grid Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
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
    // Determine button color based on its function
    Color bgColor = Colors.grey[850]!; // Default dark grey
    Color textColor = Colors.white;

    if (text == 'AC' || text == 'C' || text == '%') {
      bgColor = Colors.grey[600]!;
    } else if (text == '/' || text == 'x' || text == '-' || text == '+' || text == '=') {
      bgColor = Colors.orange; // High-contrast orange for operators
    } else if (['sin', 'cos', 'tan', 'log', '📷'].contains(text)) {
      bgColor = Colors.blueGrey[800]!; // Distinct color for scientific functions and camera
    }

    return InkWell(
      onTap: () => buttonPressed(text), // Trigger the logic on tap
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