import 'package:flutter/material.dart';
import 'package:noobcode_flutter_chatapp/components/chat_bubble.dart';
import 'package:noobcode_flutter_chatapp/constants/strings.dart';
import 'package:noobcode_flutter_chatapp/ui/base_view.dart';
import 'package:noobcode_flutter_chatapp/viewmodel/home_viewmodel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late HomeViewModel _model;
  late final TextEditingController _textEditingController;
  late final ScrollController _listViewController;
  late final FocusNode _focusNode;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _listViewController = ScrollController();
    _focusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _listViewController.dispose();
    _focusNode.dispose();
    _formKey.currentState?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
        onModelReady: (model) =>
            {_model = model, _model.initState(_listViewController)},
        onModelDestroy: (_) {
          _model.dispose();
        },
        builder: ((context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  'Chat ${_model.chatId.isNotEmpty ? "#" : ""}${_model.chatId}'),
              actions: [
                IconButton(
                    onPressed: () {
                      _model.deleteTextsFromSession();
                    },
                    icon: const Icon(Icons.delete_forever_rounded)),
                IconButton(
                    onPressed: () {
                      _model.resetSession(_listViewController);
                    },
                    icon: const Icon(Icons.exit_to_app_rounded)),
              ],
            ),
            body: _model.isBusy(HOME_STATE)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _listViewController,
                            itemCount: _model.chats.length,
                            itemBuilder: (context, index) {
                              var chat = _model.chats.elementAt(index);
                              return ChatBubble(
                                chat: chat.chat,
                                username: chat.username,
                                isSender: chat.username == _model.username,
                                dateTime: chat.createdAt.toLocal().toString(),
                              );
                            },
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: TextFormField(
                                    autofocus: true,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.text,
                                    controller: _textEditingController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a message';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        hintText: 'Enter a message',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1000))),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 0)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 0))),
                                    minLines: 1,
                                    maxLines: 5,
                                    onFieldSubmitted: (_) {
                                      if (_formKey.currentState!.validate()) {
                                        _model.sendMessage(
                                            _textEditingController.text,
                                            _listViewController);
                                        _textEditingController.clear();
                                      }
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _model.sendMessage(
                                        _textEditingController.text,
                                        _listViewController);
                                    _textEditingController.clear();
                                    _focusNode.requestFocus();
                                  }
                                },
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        }));
  }
}
