// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:concert_api/api.dart';
import 'package:concert_models/concert_models.dart';
import 'package:concert_widgets/concert_widgets.dart';
import 'package:lib.app.fidl/service_provider.fidl.dart';
import 'package:lib.logging/logging.dart';
import 'package:lib.module.fidl/module_context.fidl.dart';
import 'package:lib.module.fidl/module_controller.fidl.dart';
import 'package:lib.story.fidl/link.fidl.dart';
import 'package:lib.surface.fidl/surface.fidl.dart';
import 'package:lib.user.fidl/device_map.fidl.dart';
import 'package:lib.widgets/modular.dart';

import 'event_selector.dart';

/// [ModuleModel] that manages the state of the Event Module.
class EventListModuleModel extends ModuleModel {
  final EventSelector _eventSelector = new EventSelector();

  /// Constructor
  EventListModuleModel({this.apiKey}) : super() {
    _fetchEvents();
  }

  /// API key for Songkick APIs
  final String apiKey;

  final ModuleControllerProxy _eventPageModuleController =
      new ModuleControllerProxy();

  /// Link meant to be used by the event page module
  /// This link contains the ID of the event that is focused
  final LinkProxy _eventLink = new LinkProxy();
  final LinkWatcherBinding _eventLinkWatcherBinding = new LinkWatcherBinding();

  bool _startedEventModule = false;

  /// The current device mode
  String get deviceMode => _deviceMode;
  String _deviceMode;

  /// List of upcoming nearby events
  List<Event> get events =>
      _events != null ? new UnmodifiableListView<Event>(_events) : null;
  List<Event> _events = <Event>[];

  /// Get the current loading status
  LoadingStatus get loadingStatus => _loadingStatus;
  LoadingStatus _loadingStatus = LoadingStatus.inProgress;

  /// Get the currently selected event
  Event get selectedEvent {
    if (events == null) {
      return null;
    } else {
      return _events.firstWhere(
        (Event event) => event.id == _selectedEventId,
        orElse: () => null,
      );
    }
  }

  int _selectedEventId;

  /// Retrieves the events
  Future<Null> _fetchEvents() async {
    try {
      _events = await Api.searchEventsByArtist(null, apiKey);
      if (_events != null) {
        _loadingStatus = LoadingStatus.completed;
      } else {
        _loadingStatus = LoadingStatus.failed;
      }
    } on Exception catch (exception) {
      log.severe('Failed to Retrieve Concert Events', exception);
      _loadingStatus = LoadingStatus.failed;
    }
    notifyListeners();
  }

  /// Mark the given [Event] as selected
  void selectEvent(Event event) {
    Map<String, dynamic> data = <String, dynamic>{
      'songkick:eventId': event.id,
    };
    _eventLink.set(null, JSON.encode(data));
  }

  Future<Null> _onNotifyChild(String json) async {
    Map<String, dynamic> decoded = JSON.decode(json);
    if (decoded != null && decoded['songkick:eventId'] is int) {
      _selectedEventId = decoded['songkick:eventId'];

      // Start the Event Module if it hasn't been started
      if (!_startedEventModule) {
        moduleContext.startModuleInShell(
          'event_module',
          'file:///system/apps/concert_event_page',
          'event_link',
          null, // outgoingServices,
          null, // incomingServices,
          _eventPageModuleController.ctrl.request(),
          new SurfaceRelation()
            ..arrangement = SurfaceArrangement.copresent
            ..emphasis = 1.5
            ..dependency = SurfaceDependency.dependent,
          true,
        );

        _startedEventModule = true;
      }

      _eventPageModuleController.focus();
      notifyListeners();
    }
  }

  @override
  void onReady(
    ModuleContext moduleContext,
    Link link,
    ServiceProvider incomingServices,
  ) {
    super.onReady(moduleContext, link, incomingServices);
    moduleContext.getLink('event_link', _eventLink.ctrl.request());
    _eventLink.watchAll(
      _eventLinkWatcherBinding.wrap(
        new LinkWatcherImpl(onNotify: _onNotifyChild),
      ),
    );
    _eventSelector.start(moduleContext);
  }

  @override
  void onStop() {
    _eventPageModuleController.ctrl.close();
    _eventLink?.ctrl?.close();
    _eventSelector.stop();
  }

  @override
  void onDeviceMapChange(DeviceMapEntry entry) {
    Map<String, dynamic> profileMap = JSON.decode(entry.profile);
    if (_deviceMode != profileMap['mode']) {
      _deviceMode = profileMap['mode'];
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    // Deregister all old artists as selectable w.r.t. hotwords.
    _eventSelector.deregisterAllEvents();

    // Register all new artists as selectable w.r.t. hotwords.
    for (Event event in events) {
      String artistName = event.performances.first.artist?.name;
      if (artistName != null) {
        _eventSelector.registerEvent(
          event.id.toString(),
          artistName,
          () => selectEvent(event),
        );
      }
    }

    super.notifyListeners();
  }
}
