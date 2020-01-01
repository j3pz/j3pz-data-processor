import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/set.dart';

class SetParser {
    int setNext = 0;

    Map<String, RawSet> sets;
    Map<String, int> setIds; // { type-id: databaseId }
    Map<int, EquipSet> generatedSets; // { databaseId: EquipSet }

    EffectParser effectParser;

    SetParser({
        Map equipSet,
        Map setId,
        this.effectParser,
    }) {
        sets = {};
        equipSet.forEach((key, value) {
            var setInfo = RawSet.fromJson(value);
            sets[key] = setInfo;
        });

        setIds = {};
        setId.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('set')) {
                var databaseId = int.tryParse(value['databaseId']) ?? 0;
                setIds[originalId] = databaseId;
                setNext = max(setNext, databaseId);
            }
        });

        generatedSets = {};
    }

    void export(String path) {
        var sets = <List<String>>[];
        generatedSets.forEach((id, equipSet) {
            sets.add(equipSet.toList());
        });
        sets..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, ['id', 'name']);
        var setCsv = const ListToCsvConverter().convert(sets);
        File('$path/equip_set.csv').writeAsString(setCsv);
    }

    int getNewId(RawSet setInfo) {
        setIds['set-${setInfo.id}'] = ++setNext;
        return setNext;
    }

    EquipSet getNewEquipSet(int id) {
        var equipSet = EquipSet(
            id: id,
            name: '',
        );
        generatedSets[id] = equipSet;
        return equipSet;
    }

    EquipSet getEquipSet(RawEquip raw) {
        var setInfo = sets['${raw.setID}'];
        var databaseId = setIds['set-${setInfo.id}'] ?? getNewId(setInfo);

        var equipSet = generatedSets[databaseId] ?? getNewEquipSet(databaseId);
        if (raw.subType != 0) {
            equipSet.addName(raw.name.trim());
        }
        return equipSet;
    }
}
