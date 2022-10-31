import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

class SmallTalkPage extends StatefulWidget {
  const SmallTalkPage({Key? key, required this.handleName}) : super(key: key);

  final String handleName;

  @override
  // ignore: library_private_types_in_public_api
  _SmallTalkPageState createState() => _SmallTalkPageState();
}

class _SmallTalkPageState extends State<SmallTalkPage> {
  List<SmallTalk> smallTalks = <SmallTalk>[];
  final TextEditingController _messageController = TextEditingController();

  Widget _buildMessage(int index) {
    if (widget.handleName == smallTalks[index].name) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(smallTalks[index].name),
          Dismissible(
            key: Key(smallTalks[index].id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteMessage(index);
            },
            child: BubbleSpecialOne(
              text: smallTalks[index].message!,
              isSender: true,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(smallTalks[index].name),
          BubbleSpecialOne(
            text: smallTalks[index].message!,
            isSender: false,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: smallTalks.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildMessage(index);
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10.0),
            child: Form(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.red),
                    onPressed: () {
                      _postMessage();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.red.shade100,
    );
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    // Amplifyの初期化処理
    try {
      if (!Amplify.isConfigured) {
        AmplifyDataStore datastorePlugin =
            AmplifyDataStore(modelProvider: ModelProvider.instance);
        await Amplify.addPlugin(datastorePlugin);
        await Amplify.addPlugin(AmplifyAPI());
        await Amplify.configure(amplifyconfig);
      }
    } on AmplifyAlreadyConfiguredException catch (e) {
      debugPrint('Amplify Configure failed: $e');
    }
    // 入室時にDataStoreの内容をクリア
    await Amplify.DataStore.clear();

    // Streamをlistenし、リアルタイムに雑談内容を受け取る
    Stream<QuerySnapshot<SmallTalk>> stream = Amplify.DataStore.observeQuery(
      SmallTalk.classType,
      where: SmallTalk.ROOM.eq("1"),
      sortBy: [SmallTalk.CREATEDAT.ascending()],
    );
    stream.listen((QuerySnapshot<SmallTalk> snapshot) {
      if (mounted) {
        setState(() {
          smallTalks = snapshot.items;
        });
      }
    });
  }

  void _postMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      SmallTalk smallTalk = SmallTalk(
        room: "1",
        name: widget.handleName,
        message: _messageController.text,
        createdAt: TemporalDateTime(DateTime.now()),
      );
      await Amplify.DataStore.save(smallTalk);
    }
    _messageController.text = '';
  }

  void _deleteMessage(int index) async {
    // ignore: no_leading_underscores_for_local_identifiers
    List<SmallTalk> _smallTalks = await Amplify.DataStore.query(
      SmallTalk.classType,
      where: SmallTalk.ID.eq(smallTalks[index].id),
    );
    // ignore: no_leading_underscores_for_local_identifiers
    for (SmallTalk _smallTalk in _smallTalks) {
      try {
        await Amplify.DataStore.delete(_smallTalk);
      } on DataStoreException catch (e) {
        debugPrint('Delete failed: $e');
      }
    }
  }
}
