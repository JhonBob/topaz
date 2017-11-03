// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:lib.widgets/model.dart';

import '../models.dart';
import '../widgets.dart';
import 'conversation_list_module_model.dart';

/// Top-level widget for the chat_conversation_list module.
class ChatConversationListScreen extends StatefulWidget {
  /// Creates a new instance of [ChatConversationListScreen].
  const ChatConversationListScreen({Key key}) : super(key: key);

  @override
  _ChatConversationListScreenState createState() =>
      new _ChatConversationListScreenState();
}

class _ChatConversationListScreenState
    extends State<ChatConversationListScreen> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.purple),
      home: new Material(
        child: new ScopedModelDescendant<ChatConversationListModuleModel>(
          builder: (
            BuildContext context,
            Widget child,
            ChatConversationListModuleModel model,
          ) {
            List<Widget> stackChildren = <Widget>[
              new ChatConversationList(
                conversations: model.conversations == null
                    ? new Set<Conversation>()
                    : model.conversations,
                onNewConversation: model.showNewConversationForm,
                onSelectConversation: (Conversation c) => model
                  ..setConversationId(c.conversationId)
                  ..focusConversation(),
                selectedId: model.conversationId,
                shouldDisplaySpinner: model.shouldDisplaySpinner,
              ),
            ];

            if (model.shouldShowNewConversationForm) {
              stackChildren.addAll(<Widget>[
                new GestureDetector(
                  onTapUp: (_) => model.hideNewConversationForm(),
                  child: new Container(
                    color: Colors.black.withAlpha(180),
                  ),
                ),
                _buildNewConversationForm(context, model),
              ]);
            }

            return new Stack(
              fit: StackFit.passthrough,
              children: stackChildren,
            );
          },
        ),
      ),
    );
  }

  /// Builds a new conversation form using material alert dialog.
  Widget _buildNewConversationForm(
    BuildContext context,
    ChatConversationListModuleModel model,
  ) {
    return new Center(
      child: new NewChatConversationForm(
        onFormCancel: model.hideNewConversationForm,
        onFormSubmit: model.handleNewConversationFormSubmit,
      ),
    );
  }
}
