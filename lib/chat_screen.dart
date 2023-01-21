import 'package:chat_app/controller/chat_controller.dart';
import 'package:chat_app/model/message.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgInputController = TextEditingController();
  Color purple = Color(0xFF6c5ce7);
  Color black = Color(0xFF191919);
  late IO.Socket socket;
  ChatController chatController = ChatController();
  @override
  void initState() {
    // TODO: implement initState
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());

    socket.connect();
    setUpSocketListner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        sendByMe: currentItem.sentByMe == socket.id,
                        message: currentItem.message,
                      );
                    }),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: purple,
                  controller: msgInputController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: purple,
                      ),
                      child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.text = "";
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListner() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sendByMe, required this.message})
      : super(key: key);
  final bool sendByMe;
  final String message;
  @override
  Widget build(BuildContext context) {
    Color purple = Color(0xFF6c5ce7);
    Color white = Colors.white;
    return Align(
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: sendByMe ? purple : white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style:
                  TextStyle(fontSize: 18, color: (sendByMe ? white : purple)),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              // "02:22 AM",
              // "",
              dateTime(),
              style: TextStyle(
                  fontSize: 10,
                  color: (sendByMe ? white : purple).withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

String dateTime() {
  var dt = DateTime.now();
  int hr = dt.hour;
  int min = dt.minute;
  var time = '${hr}' ":" '${min}';
  print(time);
  return time;
}
