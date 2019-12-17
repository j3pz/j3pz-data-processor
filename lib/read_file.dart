import 'dart:convert';
import 'dart:io';
import 'package:fast_gbk/fast_gbk.dart';

void readFile({ String path, bool isFirstColumnId = false, String delimiter = '\t' , String id = 'ID'}) {
    var map = {};
    var titleRead = false;
    var titles = [];
    File(path).openRead().transform(gbk.decoder)
        .transform(const LineSplitter())
        .listen((line) {
            if (!titleRead) {
                titles = line.split(delimiter);
                titleRead = true;
            } else {
                var item = {};
                line.split(delimiter).asMap().forEach((index, value) {
                    var key  = titles[index];
                    item[key] = value;
                });
                map[item[id]] = item;
            }
        })
        .onDone(() {
            print(map['164']);
        });
}
