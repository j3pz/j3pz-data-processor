import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/effect.dart';

const effectTitle = [
    'id',
    'attribute',
    'decorator',
    'value',
    'trigger',
    'description',
];

class EffectParser {
    Map<String, int> effectIds; // { type-id: databaseId }
    Map<String, String> events; // { id: description }
    Map<String, String> recipes; // { id-level: description }

    Map<String, Effect> effects = {}; // { id: Effect }

    int effectNext = 0;

    EffectParser({
        Map event,
        Map recipe,
        Map effectId,
    }) {
        events = {};
        event.forEach((key, value) {
            String desc = value['Desc'];
            events[key] = desc;
        });

        recipes = {};
        recipe.forEach((key, value) {
            var id = '${value['ID']}-${value['Level']}';
            String desc = value['Desc'];
            recipes[id] = desc;
        });

        effectIds = {};
        effectId.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('skill') || originalId.contains('event')) {
                var databaseId = int.tryParse(value['databaseId']) ?? 0;
                effectIds[originalId] = databaseId;
                effectNext = max(effectNext, databaseId);
            }
        });
    }

    void export(String path) {
        var effects = <List<String>>[];
        this.effects.forEach((id, effect) {
            effects.add(effect.toList());
        });
        effects..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, effectTitle);
        var effectCsv = const ListToCsvConverter().convert(effects);
        File('$path/effect.csv').writeAsString(effectCsv);

        var effectIdList = <List<String>>[];
        effectIds.forEach((key, databaseId) {
            effectIdList.add([key, '$databaseId']);
        });
        effectIdList.insert(0, ['ID', 'databaseId']);
        var effectIdCsv = const ListToCsvConverter().convert(effectIdList);
        File('$path/effectId.tab').writeAsString(effectIdCsv);
    }

    int getNewId(String identifier) {
        effectIds[identifier] = ++effectNext;
        return effectNext;
    }

    Effect getEffect(List<List<String>> ids) {
        var skillIds = <String>[];
        var skillDescs = <String>[];
        var trigger = 'Passive';
        ids.forEach((entry) {
            var type = entry[0];
            var id = entry[1];
            var level = entry[2];
            var reg = RegExp('"(.*)"');
            if (type == 'event') {
                var desc = reg.stringMatch(events[id].replaceAll('\n', ''))
                    .replaceAll('\\', '').replaceAll('"', '');
                skillIds.add(id);
                skillDescs.add(desc);
            } else if (type == 'recipe') {
                var desc = reg.stringMatch(recipes['$id-$level'].replaceAll('\n', ''))
                    .replaceAll('\\', '').replaceAll('"', '');
                skillIds.add(id);
                skillDescs.add(desc);
            }
        });
        var identifier = 'event-${skillIds.join('-')}';
        var databaseId = effectIds[identifier] ?? getNewId(identifier);
        var effect = Effect(
            id: databaseId,
            trigger: trigger,
            description: skillDescs.join(';'),
        );
        if (effects['${effect.id}'] == null) {
            effects['${effect.id}'] = effect;
        }
        return effect;
    }
}
