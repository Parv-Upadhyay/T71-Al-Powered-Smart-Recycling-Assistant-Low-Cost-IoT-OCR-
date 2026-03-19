import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String scannedText = "No text scanned";

  Future<void> scanText(ImageSource source) async {

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      scannedText = recognizedText.text;
    });

    textRecognizer.close();
  }

  void copyText() {
    Clipboard.setData(ClipboardData(text: scannedText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Text copied")),
    );
  }

  void clearText() {
    setState(() {
      scannedText = "No text scanned";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Text Scanner"),
        actions: [

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ),
              );
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Scanned Text",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Text(
                  scannedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () => scanText(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan From Camera"),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () => scanText(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text("Scan From Gallery"),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: copyText,
              icon: const Icon(Icons.copy),
              label: const Text("Copy Text"),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: clearText,
              icon: const Icon(Icons.delete),
              label: const Text("Clear Text"),
            ),
          ],
        ),
      ),
    );
  }
}