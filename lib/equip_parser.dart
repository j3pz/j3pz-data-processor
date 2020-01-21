import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/attrib.dart';
import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/item.dart';
import 'package:j3pz_data_preprocessor/represent.dart';
import 'package:j3pz_data_preprocessor/represent_parser.dart';
import 'package:j3pz_data_preprocessor/set_parser.dart';
import 'package:j3pz_data_preprocessor/source_parser.dart';

import 'source.dart';

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

const equipTitle = [
    'id',
    'name',
    'icon',
    'category',
    'quality',
    'school',
    'primaryAttribute',
    'score',
    'vitality',
    'spirit',
    'strength',
    'agility',
    'spunk',
    'basicPhysicsShield',
    'basicMagicShield',
    'damageBase',
    'damageRange',
    'attackSpeed',
    'physicsShield',
    'magicShield',
    'dodge',
    'parryBase',
    'parryValue',
    'toughness',
    'attack',
    'heal',
    'crit',
    'critEffect',
    'overcome',
    'haste',
    'hit',
    'strain',
    'huajing',
    'threat',
    'effectId',
    'embed',
    'strengthen',
    'setId',
    'representId',
    'deprecated',
];

class EquipParser {
    List<List<String>> armors;
    List<List<String>> trinkets;
    List<List<String>> weapons;
   
    List<List<String>> sourceList = []; // [equipId, sourceId]

    Map<String, Attribute> attributes; // { id: Attribute }
    Map<String, RawItem> items; // { id: RawItem }
    Map<String, int> equipIds; // { type-id: databaseId }

    int equipNext = 0;

    EffectParser effectParser;
    SetParser setParser;
    RepresentParser representParser;
    SourceParser sourceParser;

    EquipParser({
        Map armor,
        Map trinket,
        Map weapon,
        Map attribute,
        Map item,
        Map equipId,
        this.effectParser,
        this.setParser,
        this.representParser,
        this.sourceParser,
    }) {
        attributes = {};
        attribute.forEach((key, value) {
            var attrib = Attribute.fromJson(value);
            attributes[key] = attrib;
        });

        equipIds = {};
        equipId.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('armor') || originalId.contains('weapon') || originalId.contains('trinket')) {
                var databaseId = int.tryParse(value['databaseId']) ?? 0;
                equipIds[originalId] = databaseId;
                equipNext = max(equipNext, databaseId);
            }
        });

        items = {};
        item.forEach((key, value) {
            var itemInfo = RawItem.fromJson(value);
            items[key] = itemInfo;
        });

        armors = [];
        armor.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 41042)) {
                return;
            }
            armors.add(parse(equip, 'armor').toList());
        });
        trinkets = [];
        trinket.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 23441)) {
                return;
            }
            trinkets.add(parse(equip, 'trinket').toList());
        });
        weapons = [];
        weapon.forEach((key, value) {
            var equip = RawEquip.fromJson(value);
            if (shouldTruncate(equip, 18631)) {
                return;
            }
            weapons.add(parse(equip, 'weapon').toList());
        });
    }

    void export(String path) {
        var equips = (armors + trinkets + weapons)..sort((a, b) => int.parse(a[0]) - int.parse(b[0]));
        equips.insert(0, equipTitle);
        var equipCsv = const ListToCsvConverter().convert(equips);
        File('$path/equip.csv').writeAsString(equipCsv);

        var equipIdList = <List<String>>[];
        equipIds.forEach((key, databaseId) {
            equipIdList.add([key, '$databaseId']);
        });
        equipIdList.insert(0, ['ID', 'databaseId']);
        var equipIdCsv = const ListToCsvConverter().convert(equipIdList);
        File('$path/equipId.tab').writeAsString(equipIdCsv);

        sourceList.insert(0, ['equipId', 'sourceId']);
        var sourceCsv = const ListToCsvConverter().convert(sourceList);
        File('$path/equip_source.csv').writeAsString(sourceCsv);
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

    int getNewId(RawEquip raw, String type) {
        equipIds['$type-${raw.id}'] = ++equipNext;
        return equipNext;
    }

    Equip parse(RawEquip raw, String type) {
        var equip = Equip();
        equip.id = equipIds['$type-${raw.id}'] ?? getNewId(raw, type);
        equip.name = raw.name;
        equip.quality = raw.level;
        equip.strengthen = int.tryParse(raw.maxStrengthLevel) ?? 0;
        equip.school = raw.belongSchool;
        equip.primaryAttribute = parsePrimaryAttrib(raw);
        equip.category = parseEquipCategory(raw);
        equip.score = parseScore(raw);
        equip = parseBasic(raw, equip);
        equip = parseAttribute(raw, equip);
        equip = parseEmbed(raw, equip);
        equip.icon = items[raw.uiID].icon;
        if (raw.setID != 0) {
            equip.equipSet = setParser.getEquipSet(raw);
        }
        if (type == 'armor' && raw.representID != null && raw.representID != '0') {
            equip.represent = parseRepresent(raw);
        }
        parseSource(raw, type, equip);
        return equip;
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

    int parseScore(RawEquip raw) {
        if (typeMap[raw.subType] != null) {
            var cof = 1.8;
            if (int.tryParse(raw.maxStrengthLevel) > 6) cof = 2.5;
            return (raw.level * cof * typeMap[raw.subType][0]).floor();
        }
        return 0;
    }

    Equip parseBasic(RawEquip raw, Equip equip) {
        [
            [raw.base1Type, raw.base1Min],
            [raw.base2Type, raw.base2Min],
            [raw.base3Type, raw.base3Min],
            [raw.base4Type, raw.base4Min],
            [raw.base5Type, raw.base5Min],
            [raw.base6Type, raw.base6Min],
        ].forEach((entry) {
            var key = entry[0];
            var min = entry[1];
            if (key == 'atPhysicsShieldBase') {
                equip.basicPhysicsShield = int.parse(min) ?? 0;
            }
            if (key == 'atMagicShield') {
                equip.basicMagicShield = int.parse(min) ?? 0;
            }
            if (key == 'atMeleeWeaponDamageBase') {
                equip.damageBase = int.parse(min) ?? 0;
            }
            if (key == 'atMeleeWeaponDamageRand') {
                equip.damageRange = int.parse(min) ?? 0;
            }
            if (key == 'atMeleeWeaponAttackSpeedBase') {
                equip.attackSpeed = int.parse(min) ?? 0;
            }
        });
        return equip;
    }

    Equip parseAttribute(RawEquip raw, Equip equip) {
        var skillIds = <List<String>>[];
        [
            raw.magic1Type,
            raw.magic2Type,
            raw.magic3Type,
            raw.magic4Type,
            raw.magic5Type,
            raw.magic6Type,
            raw.magic7Type,
            raw.magic8Type,
            raw.magic9Type,
            raw.magic10Type,
            raw.magic11Type,
            raw.magic12Type,
        ].forEach((String attributeId) {
            var attribute = attributes[attributeId];
            var key = attribute.modifyType;
            switch (key) {
                // 基础属性
                case 'atVitalityBase': // 体质
                    equip.vitality = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atSpunkBase': // 元气
                    equip.spunk = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atSpiritBase': // 根骨
                    equip.spirit = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atStrengthBase': // 力道
                    equip.strength = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atAgilityBase': // 身法
                    equip.agility = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atMagicAttackPowerBase': // 内功攻击
                case 'atPhysicsAttackPowerBase': // 外功攻击
                case 'atLunarAttackPowerBase': // 阴性攻击
                case 'atNeutralAttackPowerBase': // 混元攻击
                case 'atPoisonAttackPowerBase': // 毒性攻击
                case 'atSolarAttackPowerBase': // 阳性攻击
                case 'atSolarAndLunarAttackPowerBase': // 阴阳攻击
                    equip.attack = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atTherapyPowerBase': // 治疗
                    equip.heal = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atAllTypeCriticalStrike': // 会心
                case 'atLunarCriticalStrike': // 会心
                case 'atMagicCriticalStrike': // 会心
                case 'atNeutralCriticalStrike': // 会心
                case 'atPhysicsCriticalStrike': // 会心
                case 'atPoisonCriticalStrike': // 会心
                case 'atSolarAndLunarCriticalStrike': // 会心
                case 'atSolarCriticalStrike': // 会心
                    equip.crit = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atAllTypeCriticalDamagePowerBase': // 会效
                case 'atLunarCriticalDamagePowerBase': // 会效
                case 'atMagicCriticalDamagePowerBase': // 会效
                case 'atNeutralCriticalDamagePowerBase': // 会效
                case 'atPhysicsCriticalDamagePowerBase': // 会效
                case 'atPoisonCriticalDamagePowerBase': // 会效
                case 'atSolarAndLunarCriticalDamagePowerBase': // 会效
                case 'atSolarCriticalDamagePowerBase': // 会效
                    equip.critEffect = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atAllTypeHitValue': // 命中
                case 'atLunarHitValue': // 阴性命中
                case 'atMagicHitValue': // 内功命中
                case 'atNeutralHitValue': // 混元命中
                case 'atPhysicsHitValue': // 外功命中
                case 'atPoisonHitValue': // 毒性命中
                case 'atSolarAndLunarHitValue': // 阴阳命中
                case 'atSolarHitValue': // 阳性命中
                    equip.hit = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atLunarOvercomeBase': // 阴性破防
                case 'atMagicOvercome': // 内功破防
                case 'atNeutralOvercomeBase': // 混元破防
                case 'atPhysicsOvercomeBase': // 外功破防
                case 'atPoisonOvercomeBase': // 毒性破防
                case 'atSolarAndLunarOvercomeBase': // 阴阳破防
                case 'atSolarOvercomeBase': // 阳性破防
                    equip.overcome = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atDodge': // 闪避
                    equip.dodge = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atStrainBase': // 无双
                    equip.strain = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atHasteBase': // 加速
                    equip.haste = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atParryBase': // 招架
                    equip.parryBase = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atParryValueBase': // 拆招
                    equip.parryValue = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atMagicShield': // 内防
                    equip.magicShield = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atPhysicsShieldAdditional': // 外防
                case 'atPhysicsShieldBase': // 外防
                    equip.physicsShield = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atDecriticalDamagePowerBase': // 化劲
                    equip.huajing = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atActiveThreatCoefficient': // 威胁
                    equip.threat = int.tryParse(attribute.param2Min) ?? 0; break;
                case 'atToughnessBase': // 御劲
                    equip.toughness = int.tryParse(attribute.param1Min) ?? 0; break;
                case 'atSkillEventHandler': // 被动特效1
                    skillIds.add(['event', attribute.param1Min, '0']); break;
                case 'atSetEquipmentRecipe': // 被动特效2
                    skillIds.add(['recipe', attribute.param1Min, attribute.param2Min]); break;
            }
        });
        if (skillIds.isNotEmpty) {
            equip.effect = effectParser.getPassiveEffect(skillIds);
        }
        if (raw.skillID != null) {
            equip.effect = effectParser.getUsageEffect(raw.skillID, raw.skillLevel, raw.name);
        }
        return equip;
    }

    Equip parseEmbed(RawEquip raw, Equip equip) {
        var count = 0;
        var attrib = <String>[];
        [
            [raw.diamondTypeMask1, raw.diamondAttributeID1],
            [raw.diamondTypeMask2, raw.diamondAttributeID2],
            [raw.diamondTypeMask3, raw.diamondAttributeID3],
        ].forEach((entry) {
            var mask = int.tryParse(entry[0]) ?? 0;
            var id = entry[1];
            var attribute = attributes[id];
            if (mask > 0 && attribute != null) {
                var key = attribute.modifyType;
                count += 1;
                attrib.add(attributeKeyMap[key][1]);
            }
        });
        if (count == 0) {
            equip.embed = '';
        } else {
            equip.embed = '${count}D${attrib.join('D')}';
        }
        return equip;
    }

    Represent parseRepresent(RawEquip raw) {
        return representParser.getRepresent(raw);
    }

    void parseSource(RawEquip raw, String type, Equip equip) {
        var list = sourceParser.getSource(raw, type) ?? [];
        list.forEach((Source source) {
            sourceList.add(['${equip.id}', '${source.id}']);
        });
    }
}
