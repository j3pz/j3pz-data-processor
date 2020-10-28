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
    '22035': '青帝太皡，威御五行；惟尘身在，仪象万方。',
    '22096': '威德普渡，万法皈依',
    '21308': '吹奏凛冬踏雪曲',
    '23955': '吹奏凛冬踏雪曲',
    '5216': '红莲出业火，铁胆荡英魂。',
    '23106': '晴日上孤鹤，腾空坐忘我。',
    '23318': '起舞！血雨中的公主……',
    '23570': '剑过不留痕，残月分断魂。',
    '22851': '断肠忘情，引魂唤灵。',
    '22438': '置地后待千机匣变形立起，亲自操控之。',
    '22395': '瞄准目标扔出十字刃。',
    '22288': '用力挥舞手上的巨剑。若双剑合璧，可使用金蛇剑法。',
    '22961': '绿林掠影，九龙升景。',
    '5210': '风起月圆夜，沙掩大漠心。',
    '23291': '此盾似乎并非真正御敌所用，可放出被控制后的怪异苍炎般斗气……',
    '23232': '声色可悠扬动听，可沉稳厚重，若奏出风雨招雷，可引其最佳特质。',
    '23824': '声色可悠扬动听，可沉稳厚重，若奏出风雨招雷，可引其最佳特质。',
    '23588': '获得随时间增长的风沙护盾效果，5秒后达到最大吸收量。护盾结束后或再次使用武器将对前方矩形范围内目标造成伤害（伤害值取决于风沙护盾吸收的伤害），同时击飞范围内的非玩家目标。',
    '25449': '伞内暗藏玄机，可梅洒四方，可仿云飘然，若御敌护友，可使出最佳特制',
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
            if (originalId.contains('skill') || originalId.contains('event') || originalId.contains('attribute')) {
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
        var exception = false;
        ids.forEach((entry) {
            var type = entry[0];
            var id = entry[1];
            var level = entry[2];
            var reg = RegExp('"(.*)"');
            if (type == 'event' && events[id] != null) {
                var desc = reg.stringMatch(events[id].replaceAll('\n', ''))
                    .replaceAll('\\', '').replaceAll('"', '');
                skillIds.add(id);
                skillDescs.add(desc);
            } else if (type == 'recipe' && recipes['$id-$level'] != null) {
                var desc = reg.stringMatch(recipes['$id-$level'].replaceAll('\n', ''))
                    .replaceAll('\\', '').replaceAll('"', '');
                skillIds.add(id);
                skillDescs.add(desc);
            } else {
                exception = true;
            }
        });
        if (exception) {
            return null;
        }
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

    Effect getAttributeEffect({ String id, List<String>keys, List<num> values, List<String> decorators, List<String> description }) {
        var identifier = 'attribute-$id';
        var databaseId = effectIds[identifier] ?? getNewId(identifier);
        var effect = Effect(
            id: databaseId,
            trigger: 'Passive',
            description: description.join(';'),
        );
        effect.attribute = keys;
        effect.value = values;
        effect.decorator = decorators;
        if (effects['${effect.id}'] == null) {
            effects['${effect.id}'] = effect;
        }
        return effect;
    }

    Effect getBuffEffect({ String id, List<String>keys, List<num> values, List<String> decorators, List<String> description }) {
        var identifier = 'buff-$id';
        var databaseId = effectIds[identifier] ?? getNewId(identifier);
        var effect = Effect(
            id: databaseId,
            trigger: 'Passive',
            description: description.join(';'),
        );
        effect.attribute = keys;
        effect.value = values;
        effect.decorator = decorators;
        if (effects['${effect.id}'] == null) {
            effects['${effect.id}'] = effect;
        }
        return effect;
    }
}
