// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:lib.app.dart/app.dart';
import 'package:fuchsia.fidl.component/component.dart';
import 'package:lib.ui.flutter/child_view.dart';
import 'package:fuchsia.fidl.views_v1/views_v1.dart';
import 'package:flutter/widgets.dart';
import 'package:fidl/fidl.dart';
import 'package:meta/meta.dart';

/// A [Widget] that displays the view of the application it launches.
class ApplicationWidget extends StatefulWidget {
  /// The application to launch.
  final String url;

  /// The [ApplicationLauncher] used to launch the application.
  final ApplicationLauncher launcher;

  /// Called if the application terminates.
  final VoidCallback onDone;

  /// Child can be hit tested.
  final bool hitTestable;

  /// Constructor.
  const ApplicationWidget({
    Key key,
    @required this.url,
    @required this.launcher,
    this.onDone,
    this.hitTestable: true,
  })
      : super(key: key);

  @override
  _ApplicationWidgetState createState() => new _ApplicationWidgetState();
}

class _ApplicationWidgetState extends State<ApplicationWidget> {
  ApplicationControllerProxy _applicationController;
  ChildViewConnection _connection;

  @override
  void initState() {
    super.initState();
    _launchApp();
  }

  @override
  void didUpdateWidget(ApplicationWidget old) {
    super.didUpdateWidget(old);
    if (old.url == widget.url && old.launcher == widget.launcher) {
      return;
    }

    _cleanUp();
    _launchApp();
  }

  @override
  void dispose() {
    _cleanUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => new ChildView(
        connection: _connection,
        hitTestable: widget.hitTestable,
      );

  void _cleanUp() {
    _applicationController.ctrl.close();
    _connection = null;
  }

  void _launchApp() {
    _applicationController = new ApplicationControllerProxy();

    Services incomingServices = new Services();
    widget.launcher.createApplication(
      new ApplicationLaunchInfo(
          url: widget.url, directoryRequest: incomingServices.request()),
      _applicationController.ctrl.request(),
    );

    _connection = new ChildViewConnection(
      _consumeViewProvider(
        _consumeServices(incomingServices),
      ),
      onAvailable: (_) {},
      onUnavailable: (_) => widget.onDone?.call(),
    );
  }

  /// Creates a [ViewProviderProxy] from a [Services], closing it in the
  /// process.
  ViewProviderProxy _consumeServices(Services services) {
    ViewProviderProxy viewProvider = new ViewProviderProxy();
    services
      ..connectToService(viewProvider.ctrl)
      ..close();
    return viewProvider;
  }

  /// Creates a handle to a [ViewOwner] from a [ViewProviderProxy], closing it in
  /// the process.
  InterfaceHandle<ViewOwner> _consumeViewProvider(
    ViewProviderProxy viewProvider,
  ) {
    InterfacePair<ViewOwner> viewOwner = new InterfacePair<ViewOwner>();
    viewProvider.createView(viewOwner.passRequest(), null);
    viewProvider.ctrl.close();
    return viewOwner.passHandle();
  }
}
