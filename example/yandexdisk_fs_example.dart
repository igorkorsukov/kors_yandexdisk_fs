import 'dart:convert';
import 'package:kors_yandexdisk_fs/yandexdisk_fs.dart';

void main() async {
  final token = 'YA_DISK_TOKEN';
  final ydfs = YandexDiskFS('https://cloud-api.yandex.net', token);

  try {
    print("removig example dir...");
    await ydfs.remove('app:/example');
    var exists = await ydfs.exists('app:/example');
    print("example dir exists: $exists");

    print("make example dir...");
    await ydfs.makeDir('app:/example');

    exists = await ydfs.exists('app:/example');
    print("example dir exists: $exists");

    print("write file...");
    await ydfs.writeFile('app:/example/file1.json', '{"a": "b"}');

    print("read file...");
    var data = await ydfs.readFile('app:/example/file1.json');
    var str = utf8.decode(data);
    print("read data: $str");

    print("override file...");
    await ydfs.writeFile('app:/example/file1.json', '{"a": "c"}', overwrite: true);

    print("read file again...");
    var data2 = await ydfs.readFile('app:/example/file1.json');
    var str2 = utf8.decode(data2);
    print("read data: $str2");
  } catch (e) {
    print("catch: $e");
  }
}
