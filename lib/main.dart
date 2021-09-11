import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videotream/startServer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

pickingFile() async {
  await Permission.location.request();
  // await Permission.locationAlways.request();
  FilePickerResult? res = await FilePicker.platform.pickFiles(
    type: FileType.video,
  );
  return res!.paths[0];
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? videoPath;
  String? videoAddress;
  @override
  void dispose() {
    FilePicker.platform.clearTemporaryFiles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('videostream'),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(26.0),
                child: Text(
                  'Select a video to host that video in your local network',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: videoAddress),
                  );
                },
                child: videoAddress == null
                    ? Text('Error')
                    : Text('address = $videoAddress click to copy url'),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    pickingFile().then((e) {
                      videoPath = e;
                      return startServer(videoPath);
                    }).then((e) {
                      setState(() {
                        videoAddress = e;
                      });
                    }).catchError((e) {
                      setState(() {
                        videoAddress = null;
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'pick a file',
                      style: Theme.of(context).accentTextTheme.headline6,
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
