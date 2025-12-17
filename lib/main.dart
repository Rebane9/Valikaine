import 'package:flutter/material.dart';

void main() {
runApp(MathHelperApp());
}

class MathHelperApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Math Helper',
home: ClassSelectionScreen(),
debugShowCheckedModeBanner: false,
);
}
}

class ClassSelectionScreen extends StatelessWidget {
final List<int> classes = List.generate(12, (index) => index + 1);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('Vali klass')),
body: ListView.builder(
itemCount: classes.length,
itemBuilder: (context, index) {
return ListTile(
title: Text('${classes[index]}. klass'),
trailing: Icon(Icons.arrow_forward),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => QuestionScreen(classLevel: classes[index]),
),
);
},
);
},
),
);
}
}

class QuestionScreen extends StatefulWidget {
final int classLevel;

QuestionScreen({required this.classLevel});

@override
_QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
int currentQuestion = 0;
String userAnswer = '';
String feedback = '';

List<Map<String, dynamic>> getQuestions(int classLevel) {
return List.generate(15, (index) {
return {
'question': '(${classLevel}. klass) ${index + 1} + ${classLevel}',
'answer': (index + 1 + classLevel).toString(),
};
});
}

@override
Widget build(BuildContext context) {
final questions = getQuestions(widget.classLevel);

return Scaffold(
appBar: AppBar(title: Text('${widget.classLevel}. klassi ülesanded')),
body: Padding(
padding: EdgeInsets.all(16),
child: Column(
children: [
Text(
questions[currentQuestion]['question'],
style: TextStyle(fontSize: 22),
),
TextField(
keyboardType: TextInputType.number,
onChanged: (value) {
userAnswer = value;
},
decoration: InputDecoration(labelText: 'Sinu vastus'),
),
SizedBox(height: 10),
ElevatedButton(
onPressed: () {
setState(() {
if (userAnswer ==
questions[currentQuestion]['answer']) {
feedback = 'Õige vastus!';
} else {
feedback = 'Vale vastus 😕';
}
});
},
child: Text('Kontrolli'),
),
SizedBox(height: 10),
Text(
feedback,
style: TextStyle(fontSize: 18),
),
Spacer(),
ElevatedButton(
onPressed: () {
setState(() {
if (currentQuestion < questions.length - 1) {
currentQuestion++;
feedback = '';
userAnswer = '';
}
});
},
child: Text('Järgmine küsimus'),
),
],
),
),
);
}
}