import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:question_app/question.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Enum ToastType { success, error, warning };

enum ToastType { success, error, warning }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuestionAdapter());
  await Hive.openBox<Question>('questions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<Question> questionsBox;
  late FToast fToast;
  bool showQuestions = false;

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    questionsBox = Hive.box<Question>('questions');
  }

  void showToast(String message, ToastType type) {
    Color color;
    IconData icon;

    switch (type) {
      case ToastType.success:
        icon = Icons.check;
        color = Colors.greenAccent;
        break;
      case ToastType.error:
        icon = Icons.close;
        color = Colors.redAccent;
        break;
      case ToastType.warning:
        icon = Icons.warning;
        color = Colors.yellowAccent;
        break;
    }

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
              child: Text(
            message,
          )),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addQuestion();
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  "ICE BREAKER",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              ListTile(
                title: const Text("Copier les Questions"),
                onTap: () {
                  String questions = "";
                  for (int i = 0; i < questionsBox.length; i++) {
                    questions += "${questionsBox.getAt(i)!.content}\n";
                  }
                  if (questions.isEmpty) {
                    showToast("Aucune question à copier", ToastType.error);
                    return;
                  }

                  Clipboard.setData(ClipboardData(text: questions));
                  showToast("Questions copiées dans le presse-papier",
                      ToastType.success);

                  // Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Supprimer toutes les Questions"),
                onTap: () {
                  questionsBox.clear();
                  setState(() {});
                  showToast(
                      "Questions supprimées avec succès !", ToastType.success);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Paramètres"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Nombre de Questions : ${questionsBox.length}"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              // add switch to show questions
              SwitchListTile(
                title: const Text("Afficher les Questions"),
                value: showQuestions,
                onChanged: (value) {
                  setState(() {
                    showQuestions = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("ICE BREAKER"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: showQuestions
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (showQuestions) ...{
              Expanded(
                child: ListView.builder(
                  itemCount: questionsBox.length,
                  itemBuilder: (context, index) {
                    Question question = questionsBox.getAt(index)!;
                    return ListTile(
                      title: Text(question.content),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                    );
                  },
                ),
              ),
            },
            Center(
              child: ElevatedButton(
                onPressed: () {
                  startGame();
                },
                child: const Text(
                  "PLAY",
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startGame() async {
    MediaQueryData screen = MediaQuery.of(context);

    int questionsCount = questionsBox.length;

    if (questionsCount == 0) {
      showToast(
          "Ajoute une première question pour commencer !", ToastType.error);
      return;
    }

    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

    Random random = Random(currentTimeMillis);

    List<Question> questions = questionsBox.values.toList();

    int randomIndex = random.nextInt(questions.length);

    Question randomQuestion = questions[randomIndex];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: screen.viewPadding.top,
            left: 30,
            right: 30,
            bottom: screen.viewPadding.bottom,
          ),
          height: screen.size.height,
          width: screen.size.width,
          child: Column(
            children: [
              Text(
                "Discuter de...",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    randomQuestion.content,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Terminer"),
              ),
            ],
          ),
        );
      },
    );
  }

  void addQuestion() {
    MediaQueryData screen = MediaQuery.of(context);
    TextEditingController questionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 20,
                    left: 30,
                    right: 30,
                    bottom: screen.viewPadding.bottom,
                  ),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Text(
                        "Pose ta question ici !",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: TextField(
                            controller: questionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Question',
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String question = questionController.text;
                          if (question.isEmpty) {
                            showToast("La question ne peut pas être vide",
                                ToastType.error);
                            return;
                          }
                          int key = await questionsBox
                              .add(Question(content: question));
                          setState(() {
                            questionController.clear();
                          });

                          if (key == -1) {
                            showToast(
                                "Une erreur est survenue", ToastType.error);
                            return;
                          } else if (key == -2) {
                            showToast(
                                "La question existe déjà", ToastType.warning);
                            return;
                          } else if (key == -3) {
                            showToast("La boîte n'existe pas", ToastType.error);
                            return;
                          } else {
                            showToast("Question ajoutée avec succès !",
                                ToastType.success);
                          }

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Ajouter"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
