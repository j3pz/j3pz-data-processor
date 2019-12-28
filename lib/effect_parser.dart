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

const usageEffects = {
    '6800': '获得风特效',
    '22009-1': '大幅度提升自身外功攻击(630点)，同时降低受到的治疗成效(75%)。',
    '22009-2': '大幅度提升自身内功攻击(756点)，同时降低受到的治疗成效(75%)。',
    '22009-3': '大幅度提升自身外功攻击(820点)，同时降低受到的治疗成效(75%)。',
    '22009-4': '大幅度提升自身内功攻击(984点)，同时降低受到的治疗成效(75%)。',
    '22035': '获得霸刀变身效果',
    '22096': '启动不动明王阵',
    '21308': '吹奏凛冬踏雪曲',
    '5216': '获得炎枪重黎效果',
    '23106': '获得腾空效果',
    '23318': '绫罗红波扇子舞',
    '23570': '获得画影效果',
    '22851': '召唤蝎心忘情宠物',
    '22438': '启动八相连珠箭台',
    '22395': '获得狡猫身法',
    '22288': '施展岚尘金蛇',
    '22961': '施展九龙升景',
    '5210': '获得圆月双角效果',
    '23291': '获得斩马刑天效果',
    '23232': '获得风雷瑶琴剑效果',
};

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

    Effect getPassiveEffect(List<List<String>> ids) {
        var skillIds = <String>[];
        var skillDescs = <String>[];
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
            trigger: 'Passive',
            description: skillDescs.join(';'),
        );
        if (effects['${effect.id}'] == null) {
            effects['${effect.id}'] = effect;
        }
        return effect;
    }

    Effect getUsageEffect(int id, int level, String name) {
        String desc;
        if (usageEffects['$id-$level'] != null) {
            desc = usageEffects['$id-$level'];
        } else if (usageEffects['$id'] != null) {
            desc = usageEffects['$id'];
        } else {
            desc = '$name 装备特效';
            print('该装备的主动特效技能解析异常: name=$name, skillId=$id, skillLevel=$level');
        }
        var identifier = 'skill-$id-$level';
        var databaseId = effectIds[identifier] ?? getNewId(identifier);
        var effect = Effect(
            id: databaseId,
            trigger: 'Usage',
            description: desc,
        );
        if (effects['${effect.id}'] == null) {
            effects['${effect.id}'] = effect;
        }
        return effect;
    }
}
