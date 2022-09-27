import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  altDialog() async {
    bookmarks.add(urlController.text);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("bookmarks"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text("$bookmarks")],
        ),
      ),
    );
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
  );

  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;
  final urlController = TextEditingController();

  String currentUrl = "https://www.google.co.in/";
  double progressState = 0;

  List<String> bookmarks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController!.loadUrl(
            urlRequest: URLRequest(
              url: await webViewController!.getUrl(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web App"),
        actions: [
          IconButton(
            onPressed: () {
              log(currentUrl, name: "URl Controller");
              altDialog();
            },
            icon: Icon(Icons.bookmark_add),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goBack();
            },
            icon: Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () {
              webViewController?.reload();
            },
            icon: Icon(Icons.restart_alt),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goForward();
            },
            icon: Icon(Icons.arrow_forward),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: urlController,
              keyboardType: TextInputType.url,
              onSubmitted: (value) {
                var url = Uri.parse(value);
                if (url.scheme.isEmpty) {
                  url = Uri.parse("https://www.google.com/search?q=" + value);
                }
                webViewController?.loadUrl(urlRequest: URLRequest(url: url));
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(currentUrl),
                    ),
                    initialOptions: options,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    pullToRefreshController: pullToRefreshController,
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        progressState = (progress / 100);
                      });
                    },
                    onLoadStart: (controller, url) {
                      urlController.text = url.toString();
                    },
                    onLoadStop: (controller, url) {
                      pullToRefreshController.endRefreshing();
                      urlController.text = url.toString();
                      currentUrl = urlController.text;
                    },
                  ),
                  (progressState < 1.0)
                      ? LinearProgressIndicator(value: progressState)
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
