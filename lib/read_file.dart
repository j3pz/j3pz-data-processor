import 'dart:convert';
import 'dart:io';
import 'package:fast_gbk/fast_gbk.dart';

Future readFile({ String path, bool isFirstColumnId = false, String delimiter = '\t' , String id = 'ID'}) {
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
                map[item[id]] = item;
            }
        }).asFuture(map);
    return file;
}
