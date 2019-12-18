import 'package:j3pz_data_preprocessor/attrib.dart';
import 'package:j3pz_data_preprocessor/equip.dart';

const spunkKungfu = ['万花', '少林', '唐门', '明教'];
const spiritKungfu = ['七秀', '五毒', '纯阳', '长歌'];
const strengthKungfu = ['唐门', '天策', '丐帮', '霸刀'];
const agilityKungfu = ['纯阳', '藏剑', '苍云', '蓬莱', '凌雪'];

const typeMap = {
    0: [1.2, 'primaryWeapon'],
    1: [0.6, 'secondaryWeapon'],
    4: [0.5, 'necklace'],
    5: [0.5, 'ring'],
    7: [0.5, 'pendant'],
    2: [1, 'jacket'],
    3: [0.9, 'hat'],
    6: [0.7, 'belt'],
    8: [1, 'bottoms'],
    9: [0.7, 'shoes'],
    10: [0.7, 'wrist'],
};

class EquipParser {
    Map<String, Equip> armors;
    Map<String, Equip> trinkets;
    Map<String, Equip> weapons;
    Map<String, Attribute> attributes;

    EquipParser({ Map armor, Map trinket, Map weapon, Map attribute }) {
        attributes = {};
        attribute.forEach((key, value) {
            var attrib = Attribute.fromJson(value);
            attributes[key] = attrib;
        });

        armors = {};
        armor.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 41042)) {
                return;
            }
            armors[key] = parse(equip);
        });
        trinkets = {};
        trinket.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 23441)) {
                return;
            }
            trinkets[key] = parse(equip);
        });
        weapons = {};
        weapon.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 18631)) {
                return;
            }
            weapons[key] = parse(equip);
        });

        print('${armors.length} ${trinkets.length} ${weapons.length}');
    }

    bool shouldTruncate(RawEquip raw, int minId) {
        return (raw.subType > 10 // 非装备
            || raw.quality < 4 // 低品质
            || raw.magicType == '' // 无属性
            || raw.level < 1000 // 低品级
            || raw.require1Value < 95 // 低等级
            || raw.magicKind == '通用' // 纯通用装备，无用
            || raw.id < minId // 老装备
        );
    }

    Equip parse(RawEquip raw) {
        var equip = Equip();
        equip.name = raw.name;
        equip.quality = raw.level;
        equip.strengthen = int.tryParse(raw.maxStrengthLevel) ?? 0;
        equip.school = raw.belongSchool;
        equip.primaryAttribute = parsePrimaryAttrib(raw);
        equip.category = parseEquipCategory(raw);
    }

    String parsePrimaryAttrib(RawEquip raw) {
        // 基于门派心法判断属性
        if (raw.belongSchool != '通用') {
            if (raw.magicKind == '内功') {
                if (spunkKungfu.contains(raw.belongSchool)) {
                    return 'spunk';
                }
                if (spiritKungfu.contains(raw.belongSchool)) {
                    return 'spirit';
                }
                return 'magic';
            }
            if (raw.magicKind == '外功') {
                if (strengthKungfu.contains(raw.belongSchool)) {
                    return 'strength';
                }
                if (agilityKungfu.contains(raw.belongSchool)) {
                    return 'agility';
                }
                return 'physics';
            }
        }
        switch (raw.magicKind) {
            case '元气': return 'spunk';
            case '根骨': return 'spirit';
            case '力道': return 'strength';
            case '身法': return 'agility';
            case '治疗': return 'spirit';
            case '防御': return 'vitality';
            default:
                print('该装备的主属性解析异常: name=${raw.name}, magicKind=${raw.magicKind}, school=${raw.belongSchool}');
                return '';
        }
    }

    String parseEquipCategory(RawEquip raw) {
        if (typeMap[raw.subType] != null) {
            var category = typeMap[raw.subType][1];
            if (category == 'primaryWeapon' && raw.detailType == '9') {
                category = 'tertiaryWeapon';
            }
            return category;
        }
        print('该装备的类型解析异常: name=${raw.name}, subType=${raw.subType}, detailType=${raw.detailType}');
        return '';
    }
}
