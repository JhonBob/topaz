// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apps.maxwell.services.context/context_publisher.fidl.dart';
import 'package:apps.maxwell.services.context/context_reader.fidl.dart';
import 'package:apps.maxwell.services.suggestion/proposal_publisher.fidl.dart';
import 'package:apps.maxwell.services.suggestion/suggestion_provider.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:apps.modular.services.story/story_provider.fidl.dart';
import 'package:apps.modular.services.user/focus.fidl.dart';
import 'package:apps.modular.services.user/user_shell.fidl.dart';
import 'package:lib.widgets/model.dart';
import 'package:meta/meta.dart';

export 'package:lib.widgets/model.dart' show ScopedModel, ScopedModelDescendant;

/// The [Model] that provides services provided to this app's [UserShell].
class UserShellModel extends Model {
  UserShellContext _userShellContext;
  FocusProvider _focusProvider;
  FocusController _focusController;
  VisibleStoriesController _visibleStoriesController;
  StoryProvider _storyProvider;
  SuggestionProvider _suggestionProvider;
  ContextReader _contextReader;
  ContextPublisher _contextPublisher;
  ProposalPublisher _proposalPublisher;
  Link _link;

  /// Indicates whether the [LinkWatcher] should watch for all changes including
  /// the changes made by this [UserShell]. If [true], it calls [Link.watchAll]
  /// to register the [LinkWatcher], and [Link.watch] otherwise. Only takes
  /// effect when the [onNotify] callback is also provided. Defaults to false.
  final bool watchAll;

  /// Creates a new instance of [UserShellModel].
  UserShellModel({bool watchAll}) : watchAll = watchAll ?? false;

  /// The [UserShellContext] given to this app's [UserShell].
  UserShellContext get userShellContext => _userShellContext;

  /// The [FocusProvider] given to this app's [UserShell].
  FocusProvider get focusProvider => _focusProvider;

  /// The [FocusController] given to this app's [UserShell].
  FocusController get focusController => _focusController;

  /// The [VisibleStoriesController] given to this app's [UserShell].
  VisibleStoriesController get visibleStoriesController =>
      _visibleStoriesController;

  /// The [StoryProvider] given to this app's [UserShell].
  StoryProvider get storyProvider => _storyProvider;

  /// The [SuggestionProvider] given to this app's [UserShell].
  SuggestionProvider get suggestionProvider => _suggestionProvider;

  /// The [ContextReader] given to this app's [UserShell].
  ContextReader get contextReader => _contextReader;

  /// The [ContextPublisher] given to this app's [UserShell].
  ContextPublisher get contextPublisher => _contextPublisher;

  /// The [ProposalPublisher] given to this app's [UserShell].
  ProposalPublisher get proposalPublisher => _proposalPublisher;

  /// The [Link] given to this [UserShell].
  Link get link => _link;

  /// Called when this app's [UserShell] is given its services.
  @mustCallSuper
  void onReady(
    UserShellContext userShellContext,
    FocusProvider focusProvider,
    FocusController focusController,
    VisibleStoriesController visibleStoriesController,
    StoryProvider storyProvider,
    SuggestionProvider suggestionProvider,
    ContextReader contextReader,
    ContextPublisher contextPublisher,
    ProposalPublisher proposalPublisher,
    Link link,
  ) {
    _userShellContext = userShellContext;
    _focusProvider = focusProvider;
    _focusController = focusController;
    _visibleStoriesController = visibleStoriesController;
    _storyProvider = storyProvider;
    _suggestionProvider = suggestionProvider;
    _contextReader = contextReader;
    _contextPublisher = contextPublisher;
    _proposalPublisher = proposalPublisher;
    _link = link;
    notifyListeners();
  }

  /// Called when the app's [UserShell] stops.
  void onStop() => null;

  /// Called when [LinkWatcher.notify] is called.
  void onNotify(String json) => null;
}
