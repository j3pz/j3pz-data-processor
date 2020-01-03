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
                    map[key] = item;
                } else {
                    map[item[id]] = item;
                }
            }
        }).asFuture(map);
    return file;
}
