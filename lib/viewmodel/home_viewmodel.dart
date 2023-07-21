import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:noobcode_flutter_chatapp/constants/strings.dart';
import 'package:noobcode_flutter_chatapp/enums/view_state.dart';
import 'package:noobcode_flutter_chatapp/locator.dart';
import 'package:noobcode_flutter_chatapp/model/chat_model.dart';
import 'package:noobcode_flutter_chatapp/services/dialog_service.dart';
import 'package:noobcode_flutter_chatapp/services/local_storage_service.dart';
import 'package:noobcode_flutter_chatapp/viewmodel/base_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends BaseModel {
  final LinkedHashSet<ChatData> _chats = LinkedHashSet<ChatData>();
  final DialogService _dialogService = locator<DialogService>();
  final _localStorageService = locator<LocalStorageService>();

  LinkedHashSet<ChatData> get chats => _chats;
  String _chatId = "";
  String? _username = "";

  String get chatId => _chatId;
  String? get username => _localStorageService.username;

  Future<void> getDataFromModal() async {
    // fetch previous username from local storage
    _username = _localStorageService.username;

    final dialogResponse = await _dialogService.showInputService(
        title: "Welcome!", field1Value: username);

    // save new username
    if (dialogResponse.confirmed == true) {
      _localStorageService.username = dialogResponse.value1;
      _username = dialogResponse.value1;
    }

    _chatId = dialogResponse.value2 ?? "0";
  }

  void supabaseSubscribe(ScrollController controller) {
    final supabase = Supabase.instance.client;
    supabase.channel('public:$CHATS_TABLE:chat_id=eq.$_chatId').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: CHATS_TABLE,
          filter: "chat_id=eq.$_chatId"),
      (payload, [ref]) {
        final newChat = ChatData.fromJson(payload["new"]);

        if (newChat.username != _username) {
          _chats.add(newChat);
          setStateFor(NEW_MESSAGE, ViewState.update);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.jumpTo(controller.position.maxScrollExtent);
          });
        }
      },
    ).subscribe();
  }

  Future<void> initState(ScrollController controller) async {
    setStateFor(HOME_STATE, ViewState.busy);
    debugPrint('***** home view model initialised');

    await getDataFromModal();

    supabaseSubscribe(controller);

    setStateFor(HOME_STATE, ViewState.success);
  }

  @override
  void dispose() {
    super.dispose();
    final supabase = Supabase.instance.client;
    supabase.removeAllChannels();
    _chats.clear();
  }

  void sendMessage(String chat, ScrollController controller) {
    final supabase = Supabase.instance.client;
    supabase
        .from(CHATS_TABLE)
        .insert({
          'username': _username,
          'chat': chat,
          'chat_id': _chatId,
        })
        .select("id, created_at")
        .single()
        .then((value) {
          final Map<String, dynamic> temp = {
            "id": value["id"],
            "created_at": value["created_at"],
            "chat": chat,
            "chat_id": _chatId,
            "username": _username,
          };
          _chats.add(ChatData.fromJson(temp));
          setStateFor(NEW_MESSAGE, ViewState.update);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.jumpTo(controller.position.maxScrollExtent);
          });
        })
        .catchError((error) {
          setStateFor(NEW_MESSAGE, ViewState.error);
        });
  }

  Future<void> deleteTextsFromSession() async {
    final dialogResponse = await _dialogService.showConfirmationDialog(
        title: "Delete texts from this session?",
        description:
            "Conversations are not stored in the cloud or on your device and you will not be able to view them again.");
    if (dialogResponse.confirmed == true) {
      _chats.clear();
      setStateFor(NEW_MESSAGE, ViewState.update);
    }
  }

  Future<void> resetSession(ScrollController controller) async {
    final dialogResponse = await _dialogService.showConfirmationDialog(
        title: "Reset session?",
        description:
            "You will be logged out of this session. Conversations are not stored in the cloud or on your device and you will not be able to view them again.");

    if (dialogResponse.confirmed == true) {
      _chats.clear();

      final supabase = Supabase.instance.client;

      await supabase.removeAllChannels();

      await getDataFromModal();

      supabaseSubscribe(controller);

      setStateFor(HOME_STATE, ViewState.update);
    }
  }
}
