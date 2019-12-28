import 'dart:math';
import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/set.dart';

class SetParser {
    int setNext = 0;

    Map<String, RawSet> sets;
    Map<String, int> setIds; // { type-id: databaseId }

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
    }

    EquipSet getEquipSet(RawEquip raw) {
        var equipSet = EquipSet(
            id: 0,
            name: '',
        );
        return equipSet;
    }
}
