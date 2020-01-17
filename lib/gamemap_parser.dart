import 'dart:io';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/gamemap.dart';

class GameMapParser {
    Map<String, GameMap> gameMaps;

    GameMapParser({ Map mapList }) {
        gameMaps = {};
        mapList.forEach((key, value) {
            gameMaps[key] = parseMap(RawMap.fromJson(value));
        });
    }

    void export(String path) {
        var maps = <List<String>>[];
        gameMaps.forEach((id, map) {
            maps.add(map.toList());
        });
        maps..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['0', '未知地图'])
            ..insert(0, ['id', 'name']);
        var mapCsv = const ListToCsvConverter().convert(maps);
        File('$path/map.csv').writeAsString(mapCsv);
    }

    GameMap parseMap(RawMap raw) {
        var map = GameMap(id: raw.id, name: raw.displayName);
        return map;
    }
}
