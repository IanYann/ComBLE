import 'package:clientapp/chatMessageModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Sendmsg extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  Sendmsg({required Key key, required this.connectedDevice}) : super(key: key);
  @override
  _SendmsgState createState() => _SendmsgState();
}

class _SendmsgState extends State<Sendmsg> {
  final myController = TextEditingController();
  BluetoothCharacteristic? targetCharacteristic;
  List<BluetoothService> services = [];
  List<ChatMessage> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Stack(
        children: <Widget>[
          // show all the message contains in the list
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                child: Text(messages[index].messageContent),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print(myController.text);
                      setState(() {
                        //this line is use to send data to the connected device
                        // connectedDevice?.write(myController.text);
                        messages.add(ChatMessage(
                            messageContent: myController.text,
                            messageType: "sender"));
                        myController.clear();
                      });
                    },
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void discoverServices(BluetoothDevice device) async {
    services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            targetCharacteristic = characteristic;
          });
        }
      }
    }
  }

  void writeToCharacteristic(List<int> value) async {
    if (targetCharacteristic != null) {
      await targetCharacteristic!.write(value);
      print('Data written to characteristic');
    }
  }

  void sendMessage() {
    discoverServices(widget.connectedDevice!);
    String sentence = myController.text;
    List<int> asciiValues = sentence.codeUnits;

    print(asciiValues);

    writeToCharacteristic(asciiValues);
    setState(() {
      messages.add(ChatMessage(
          messageContent: myController.text, messageType: "sender"));
      myController.clear();
    });

    print(myController.text);
  }
}
