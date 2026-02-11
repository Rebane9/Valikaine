import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MathHelperApp());
}

class MathHelperApp extends StatelessWidget {
  const MathHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eesti Matemaatika 1-9',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ---------------- ANDMEMUDEL ----------------
class Topic {
  final String title;
  final String id;
  final String hint; // Vihje raskemate ülesannete jaoks

  Topic(this.title, this.id, {this.hint = ""});
}

// Eesti Riiklik Õppekava (RÕK) matemaatika teemad klasside kaupa
final Map<int, List<Topic>> curriculum = {
  // I KOOLIASTE
  1: [
    Topic("Liitmine 20 piires", "g1_add", hint: "Kasuta sõrmi või loendurite abi!"),
    Topic("Lahutamine 20 piires", "g1_sub"),
    Topic("Võrdlemine (<, >, =)", "g1_comp"),
  ],
  2: [
    Topic("Korrutustabel (2-5)", "g2_mult"),
    Topic("Liitmine 100 piires", "g2_add_100"),
    Topic("Mõõtühikud (m -> cm)", "g2_units"),
  ],
  3: [
    Topic("Jagamine jäägita", "g3_div"),
    Topic("Korrutamine (6-9)", "g3_mult_9"),
    Topic("Tehete järjekord", "g3_order"),
  ],
  // II KOOLIASTE
  4: [
    Topic("Suured arvud (Liitmine)", "g4_big_add"),
    Topic("Korrutamine 10, 100-ga", "g4_mult_10"),
    Topic("Rooma numbrid (I-X)", "g4_roman"),
  ],
  5: [
    Topic("Kümnendmurrud (Liitmine)", "g5_dec_add", hint: "Jälgi komakohta!"),
    Topic("Lihtsustamine", "g5_simplify"), // Lihtsustatud versioon
    Topic("Ümbermõõt (Ruut)", "g5_perim"),
  ],
  6: [
    Topic("Negatiivsed arvud (+/-)", "g6_neg", hint: "Miinus ja miinus annab plussi."),
    Topic("Protsent (Lihtne)", "g6_perc"),
    Topic("Koordinaatteljestik (x,y)", "g6_coord"),
  ],
  // III KOOLIASTE
  7: [
    Topic("Lineaarvõrrand (x+a=b)", "g7_lin_eq", hint: "vii arvud teisele poole võrdusmärki."),
    Topic("Astendamine (Ruut)", "g7_pow"),
    Topic("Kolmnurga pindala", "g7_tri_area"),
  ],
  8: [
    Topic("Ruutvõrrandi diskriminant", "g8_quad", hint: "D = b² - 4ac"),
    Topic("Tõenäosus (Täring)", "g8_prob"),
    Topic("Pütagorase teoreem", "g8_pyth"),
  ],
  9: [
    Topic("Trigonomeetria (sin/cos 0,90)", "g9_trig"),
    Topic("Funktsiooni nullkoht", "g9_func"),
    Topic("Astmed ja juured", "g9_roots"),
  ]
};

// ---------------- UI: AVALEHT ----------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📚 Matemaatika 1.-9. Klass")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 9,
        itemBuilder: (context, index) {
          int grade = index + 1;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getGradeColor(grade),
                child: Text("$grade", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text("$grade. Klass"),
              subtitle: Text(_getGradeDescription(grade)),
              children: curriculum[grade]!.map((topic) => ListTile(
                title: Text(topic.title),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage(topic: topic, grade: grade)),
                ),
              )).toList(),
            ),
          );
        },
      ),
    );
  }

  Color _getGradeColor(int grade) {
    if (grade <= 3) return Colors.green; // I kooliaste
    if (grade <= 6) return Colors.orange; // II kooliaste
    return Colors.purple; // III kooliaste
  }

  String _getGradeDescription(int grade) {
    if (grade <= 3) return "Algõpetus";
    if (grade <= 6) return "Põhiõpe";
    return "Lõpuklassid";
  }
}

// ---------------- UI: MÄNGU LEHT ----------------
class GamePage extends StatefulWidget {
  final Topic topic;
  final int grade;

  const GamePage({super.key, required this.topic, required this.grade});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _rnd = Random();
  final TextEditingController _controller = TextEditingController();
  
  String question = "";
  String correctAnswer = ""; // Hoiame vastust stringina võrdlemiseks
  String feedback = "";
  Color feedbackColor = Colors.transparent;
  int score = 0;
  bool isComparison = false; // Kasutatakse erijuhtudel (< > =)

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  // ---------------- LOOGIKA MOOTOR ----------------
  void _generateQuestion() {
    _controller.clear();
    setState(() {
      feedback = "";
      feedbackColor = Colors.transparent;
      isComparison = false;
    });

    int a, b, c;

    switch (widget.topic.id) {
      // --- 1. KLASS ---
      case "g1_add":
        a = _rnd.nextInt(10) + 1;
        b = _rnd.nextInt(20 - a);
        question = "$a + $b = ?";
        correctAnswer = "${a + b}";
        break;
      case "g1_sub":
        a = _rnd.nextInt(15) + 5;
        b = _rnd.nextInt(a);
        question = "$a - $b = ?";
        correctAnswer = "${a - b}";
        break;
      case "g1_comp":
        isComparison = true;
        a = _rnd.nextInt(20);
        b = _rnd.nextInt(20);
        question = "$a ... $b";
        correctAnswer = a > b ? ">" : (a < b ? "<" : "=");
        break;

      // --- 2. KLASS ---
      case "g2_mult":
        a = _rnd.nextInt(4) + 2; // 2..5
        b = _rnd.nextInt(9) + 1;
        question = "$a × $b = ?";
        correctAnswer = "${a * b}";
        break;
      case "g2_units":
        a = _rnd.nextInt(9) + 1;
        question = "$a m = ... cm";
        correctAnswer = "${a * 100}";
        break;
      case "g2_add_100":
        a = _rnd.nextInt(50) + 10;
        b = _rnd.nextInt(100 - a);
        question = "$a + $b = ?";
        correctAnswer = "${a + b}";
        break;

      // --- 3. KLASS ---
      case "g3_div": // Jäägita jagamine
        b = _rnd.nextInt(8) + 2; 
        c = _rnd.nextInt(9) + 1; 
        a = b * c;
        question = "$a : $b = ?";
        correctAnswer = "$c";
        break;
      case "g3_order":
        a = _rnd.nextInt(5) + 2;
        b = _rnd.nextInt(5) + 2;
        c = _rnd.nextInt(10) + 1;
        // Näide: 2 + 3 * 4
        question = "$c + $a × $b = ?";
        correctAnswer = "${c + (a * b)}";
        break;

      // --- 4. KLASS ---
      case "g4_big_add":
        a = _rnd.nextInt(4000) + 1000;
        b = _rnd.nextInt(4000) + 1000;
        question = "$a + $b = ?";
        correctAnswer = "${a + b}";
        break;
      case "g4_mult_10":
        a = _rnd.nextInt(90) + 10;
        b = [10, 100, 1000][_rnd.nextInt(3)];
        question = "$a × $b = ?";
        correctAnswer = "${a * b}";
        break;
      case "g4_roman":
        List<String> romans = ["I", "II", "III", "IV", "V", "VI", "IX", "X"];
        List<int> arabic = [1, 2, 3, 4, 5, 6, 9, 10];
        int idx = _rnd.nextInt(romans.length);
        question = "Rooma ${romans[idx]} araabia numbrina?";
        correctAnswer = "${arabic[idx]}";
        break;

      // --- 5. KLASS ---
      case "g5_dec_add":
        double da = (_rnd.nextInt(100) + 1) / 10; // Nt 2.5
        double db = (_rnd.nextInt(50) + 1) / 10;  // Nt 1.3
        // Et vältida ujukoma vigu, arvutame ja vormindame
        question = "$da + $db = ?";
        correctAnswer = (da + db).toStringAsFixed(1);
        break;
      case "g5_perim":
        a = _rnd.nextInt(10) + 2;
        question = "Ruudu külg on $a cm. Ümbermõõt?";
        correctAnswer = "${4 * a}";
        break;
        
      // --- 6. KLASS ---
      case "g6_neg":
        a = _rnd.nextInt(10) + 1; // 5
        b = _rnd.nextInt(10) + 10; // 15
        // 5 - 15 = -10
        question = "$a - $b = ?";
        correctAnswer = "${a - b}";
        break;
      case "g6_perc":
        a = [10, 20, 25, 50][_rnd.nextInt(4)];
        b = _rnd.nextInt(10) * 10 + 100; // 100, 110...
        question = "$a% arvust $b?";
        correctAnswer = "${(b * a / 100).round()}";
        break;

      // --- 7. KLASS ---
      case "g7_lin_eq": // x + a = b
        a = _rnd.nextInt(20) - 10;
        c = _rnd.nextInt(20) - 10; // see on x
        b = c + a;
        String sign = a >= 0 ? "+ $a" : "- ${a.abs()}";
        question = "Lahenda: x $sign = $b. x = ?";
        correctAnswer = "$c";
        break;
      case "g7_pow":
        a = _rnd.nextInt(9) + 1;
        question = "Arvuta $a²";
        correctAnswer = "${a * a}";
        break;

      // --- 8. KLASS ---
      case "g8_pyth": // Lihtne pütagoras (3,4,5 jne)
        question = "Täisnurkse kolmnurga kaatetid on 3 ja 4. Hüpotenuus?";
        correctAnswer = "5";
        break;
      case "g8_prob":
        question = "Tõenäosus veeretada täringul 6 (murd)?";
        correctAnswer = "1/6";
        break;

      // --- 9. KLASS ---
      case "g9_roots":
        List<int> squares = [4, 9, 16, 25, 36, 49, 64, 81, 100];
        a = squares[_rnd.nextInt(squares.length)];
        question = "√$a = ?";
        correctAnswer = "${sqrt(a).round()}";
        break;
      case "g9_func":
         // y = 2x - 4, nullkoht? 0 = 2x - 4 -> 2x = 4 -> x = 2
         a = _rnd.nextInt(5) + 1; // kordaja
         b = a * (_rnd.nextInt(5) + 1); // vabaliige
         question = "Leia nullkoht: y = ${a}x - $b";
         correctAnswer = "${b ~/ a}";
         break;

      default:
        question = "Ülesanne tulekul...";
        correctAnswer = "0";
    }
  }

  void _checkAnswer() {
    String userAns = _controller.text.trim().replaceAll(',', '.'); // Luba koma ja punkti
    
    // Lihtne normaliseerimine võrdlemiseks (string vs string)
    if (userAns == correctAnswer) {
      setState(() {
        score += 10;
        feedback = "Õige! Väga tubli! 🌟";
        feedbackColor = Colors.green;
      });
      Future.delayed(const Duration(seconds: 2), _generateQuestion);
    } else {
      setState(() {
        feedback = "Vale. Õige on $correctAnswer.";
        feedbackColor = Colors.red;
      });
    }
  }

  // Abifunktsioon võrdlemise nuppude jaoks
  void _submitComparison(String sign) {
    _controller.text = sign;
    _checkAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.grade}. klass: ${widget.topic.title}")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Score Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Punktid: $score", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (widget.topic.hint.isNotEmpty)
                  Tooltip(
                    message: widget.topic.hint,
                    triggerMode: TooltipTriggerMode.tap,
                    child: const Icon(Icons.help_outline, color: Colors.blue),
                  )
              ],
            ),
            const Spacer(),
            
            // Question Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
              ),
              child: Text(
                question,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 30),

            // Input Area
            if (isComparison)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["<", "=", ">"].map((s) => ElevatedButton(
                  onPressed: () => _submitComparison(s),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                  child: Text(s, style: const TextStyle(fontSize: 24)),
                )).toList(),
              )
            else
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  hintText: "Kirjuta vastus",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => _checkAnswer(),
              ),

            const SizedBox(height: 20),
            
            if (!isComparison)
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text("KONTROLLI", style: TextStyle(fontSize: 18)),
              ),

            const SizedBox(height: 20),
            Text(
              feedback,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: feedbackColor),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}