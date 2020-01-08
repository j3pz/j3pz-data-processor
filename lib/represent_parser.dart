import 'dart:io';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/represent.dart';

class RepresentParser {
    Map<int, Represent> represents = {};
    Map<String, RawRepresentInfo> representToExterior;
    Map<String, RepresentBox> exteriorToSet;

    RepresentParser({
        Map representToExterior,
        Map exteriorToSet,
    }) {
        this.representToExterior = { '0-0-0-0': null };
        representToExterior.forEach((key, value) {
            this.representToExterior[key] = RawRepresentInfo.fromJson(value);
        });

        this.exteriorToSet = {};
        exteriorToSet.forEach((key, value) {
            this.exteriorToSet[key] = RepresentBox.fromJson(value);
        });

    }

    void export(String path) {
        var sets = <List<String>>[];
        represents.forEach((id, representSet) {
            sets.add(representSet.toList());
        });
        sets..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, ['id', 'name']);
        var setCsv = const ListToCsvConverter().convert(sets);
        File('$path/represents.csv').writeAsString(setCsv);
    }

    Represent getRepresent(RawEquip raw) {
        var forceId = maskToForceId(raw.belongForceMask);
        var key = '${raw.subType}-${raw.representID}-${raw.colorID}-$forceId';
        var exteriorInfo = representToExterior[key] ?? representToExterior['${raw.subType}-${raw.representID}-${raw.colorID}-0'];
        if (exteriorInfo == null) {
            return null;
        }
        var setId = exteriorInfo.setId;
        var exteriorSet = exteriorToSet['$setId'];
        var represent = Represent(id: setId, name: exteriorSet.setName);
        if (represents[setId] == null) {
            represents[setId] = represent;
        } 
        return represent;
    }

    int maskToForceId(String mask) {
        var maskNum = int.tryParse(mask);
        var list = maskNum.toRadixString(2).split('');
        var isSingle = list.fold(0, (value, element) => value + int.parse(element)) == 1;
        if (isSingle) {
            return list.reversed.toList().indexOf('1');
        }
        return 0;
    }
}
