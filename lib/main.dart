import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MeetingApp());
}

class MeetingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeting Notes App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechToText speech = SpeechToText();
  bool isListening = false;

  String text = "Tap the mic and start speaking...";
  String summary = "";
  String actions = "";

  void startListening() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) {
          setState(() {
            text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
      generateSummary();
    }
  }

  void generateSummary() {
    List<String> words = text.split(" ");
    summary = words.take(25).join(" ");

    if (text.toLowerCase().contains("do") ||
        text.toLowerCase().contains("complete") ||
        text.toLowerCase().contains("finish")) {
      actions = "• Task detected: Follow up required";
    } else {
      actions = "No action items detected";
    }
  }

  void copyText() {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Copied")));
  }

  void clearAll() {
    setState(() {
      text = "Tap the mic and start speaking...";
      summary = "";
      actions = "";
    });
  }

  Widget buildCard(String title, String content, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.brown, size: 26),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Meeting Notes App",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.brown.shade800),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown.shade100,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.copy, color: Colors.brown),
              onPressed: copyText),
          IconButton(
              icon: Icon(Icons.delete, color: Colors.brown),
              onPressed: clearAll),
        ],
      ),

      // 🌄 BACKGROUND IMAGE
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.6), // overlay for readability
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                buildCard("Notes", text, Icons.mic),
                buildCard("Summary", summary, Icons.description),
                buildCard("Action Items", actions, Icons.check_circle),
              ],
            ),
          ),
        ),
      ),

      // 🎤 BIG MIC BUTTON
      floatingActionButton: Container(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.brown,
          onPressed: startListening,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}