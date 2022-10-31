import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sample_chat_app/samll_talk_page.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '雑談の小部屋',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ChatHomePage(title: '雑談の小部屋'),
      // 日本語フォントで表示
      locale: const Locale("ja", "JP"),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ja", "JP")],
      // デバッグ時バナー非表示
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key, required this.title});
  final String title;

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _handleNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: "ハンドル名",
                  hintText: "Chat",
                ),
                controller: _handleNameController,
                maxLength: 20,
                autovalidateMode: AutovalidateMode.disabled,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "ハンドル名を入力してください。";
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.all(30.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return SmallTalkPage(
                            handleName: _handleNameController.text,
                          );
                      }));
                    }
                  },
                  child: const Text('入室'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
