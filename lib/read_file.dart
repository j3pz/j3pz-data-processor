import 'dart:convert';
import 'dart:io';
import 'package:fast_gbk/fast_gbk.dart';

Future readFile({ String path, String delimiter = '\t' , String id = 'ID', List<String> ids}) {
    var map = <String, dynamic>{};
    var titleRead = false;
    var titles = <String>[];
    var file = File(path).openRead().transform(gbk.decoder)
        .transform(const LineSplitter())
        .listen((line) {
            if (!titleRead) {
                titles = line.split(delimiter);
                titleRead = true;
            } else {
                var item = <String, dynamic>{};
                line.split(delimiter).asMap().forEach((index, value) {
                    var key  = titles[index];
                    item[key] = value;
                });
                if (ids != null) {
                    var key = ids.map((k) => item[k]).join('-');
                    if (map[key] != null) {
                        print('Warn: $path 的 ID 对：$ids 不唯一, key=$key');
                    }
                    map[key] = item;
                } else {
                    if (map[item[id]] != null) {
                        print('Warn: $path 的 ID：$id 不唯一, key=${item[id]}');
                    }
                    map[item[id]] = item;
                }
            }
        }).asFuture(map);
    return file;
}
