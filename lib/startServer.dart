import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:math';

var indexHtml = '''
      <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>HTTP Video Stream</title>
  </head>
  <body>
    <video id="videoPlayer" width="650" controls muted="muted" autoplay>
      <source src="/video" type="video/mp4" />
    </video>
  </body>
</html>

      ''';

startServer(filePath) async {
  final info = NetworkInfo();
  var hostAddress = await info.getWifiIP();
  var portNumber = 4655;
  var server = await HttpServer.bind(hostAddress, portNumber, shared: true);
  server.listen((req) async {
    var res = req.response;
    var uri = req.uri.toString();
    if (uri == '/video') {
      final range = req.headers.value('range');
      var videoFile = File(filePath);
      var videoSize = await videoFile.length();
      const CHUNK_SIZE = 1000000;
      final startValue = range!.replaceAllMapped(
          RegExp(
            r'(\D)',
          ),
          (match) => '');
      final start = int.parse(startValue);

      var end = min<int>(start + CHUNK_SIZE, videoSize);

      var videoStream = videoFile.openRead(start, end);
      // Create headers
      final contentLength = end - start;
      print('$start $end $contentLength');

      res.headers
        ..add('Content-Range', 'bytes $start-$end/$videoSize')
        ..add('Accept-Ranges', 'bytes')
        ..add('Content-Length', contentLength)
        ..add('Content-Type', 'video/mp4');
      await videoStream.pipe(res);
      await res.close();
    } else if (uri == '/') {
      res.headers.add('Content-Type', 'text/html');
      res.write(indexHtml);
      await res.close();
    }
  });
  return '$hostAddress:$portNumber';
}
