
A simple wrapper for the Yandex Disk API, making the interface similar to FS.

## Features

At the moment implemented base features:   
* check exists dir or file
* remove dir or file
* write file
* read file
* make dir
* scan files

## Usage

```
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
  } catch (e) {
    print("catch: $e");
  }
}
```

## Additional information

Under development...
