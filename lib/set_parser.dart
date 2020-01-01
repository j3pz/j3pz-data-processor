import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/attrib.dart';
import 'package:j3pz_data_preprocessor/effect.dart';
import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/set.dart';

class SetParser {
    int setNext = 0;

    Map<String, RawSet> sets;
    Map<String, int> setIds; // { type-id: databaseId }
    Map<int, EquipSet> generatedSets; // { databaseId: EquipSet }
    Map<String, Attribute> attributes; // { id: Attribute }

    EffectParser effectParser;

    SetParser({
        Map equipSet,
        Map setId,
        Map attribute,
        this.effectParser,
    }) {
        sets = {};
        equipSet.forEach((key, value) {
            var setInfo = RawSet.fromJson(value);
            sets[key] = setInfo;
        });

        attributes = {};
        attribute.forEach((key, value) {
            var attrib = Attribute.fromJson(value);
            attributes[key] = attrib;
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
            // 武器名称特殊，不参与名称解析
            equipSet.addName(raw.name.trim());
        }

        parseSet(equipSet, setInfo);
        return equipSet;
    }

    void parseSet(EquipSet equipSet, RawSet raw) {
        [
            [2, [raw.require2Effect1, raw.require2Effect2]],
            [3, [raw.require3Effect1, raw.require3Effect2]],
            [4, [raw.require4Effect1, raw.require4Effect2]],
            [5, [raw.require5Effect1, raw.require5Effect2]],
            [6, [raw.require6Effect1, raw.require6Effect2]],
        ].forEach((entry) {
            int requirement = entry[0];
            List<int> attributeIds = entry[1];
            var attributeKeys = <String>[];
            var attributeValues = <num>[];
            var attributeDecorators = <String>[];
            var descriptions = <String>[];
            void addAttribute(String key, num value, String decorator, [String descPrefix]) {
                attributeKeys.add(key);
                attributeValues.add(value);
                attributeDecorators.add(decorator);
                if (descPrefix != null) {
                    descriptions.add('${descPrefix}提高 $value');
                }
            }
            attributeIds.forEach((attributeId) {
                if (attributeId != null) {
                    var attribute = attributes['$attributeId'];
                    var key = attribute.modifyType;

                    switch (key) {
                        case 'atBasePotentialAdd': // 全属性
                            addAttribute('vitality', int.tryParse(attribute.param1Min) ?? 0, 'NONE');
                            addAttribute('spunk', int.tryParse(attribute.param1Min) ?? 0, 'NONE');
                            addAttribute('spirit', int.tryParse(attribute.param1Min) ?? 0, 'NONE');
                            addAttribute('strength', int.tryParse(attribute.param1Min) ?? 0, 'NONE');
                            addAttribute('agility', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '全属性');
                            descriptions.add('全属性提高 ${int.tryParse(attribute.param1Min) ?? 0}');
                            break;
                        case 'atVitalityBase': // 体质
                            addAttribute('vitality', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '体质'); break;
                        case 'atSpunkBase': // 元气
                            addAttribute('spunk', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '元气'); break;
                        case 'atSpiritBase': // 根骨
                            addAttribute('spirit', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '根骨'); break;
                        case 'atStrengthBase': // 力道
                            addAttribute('strength', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '力道'); break;
                        case 'atAgilityBase': // 身法
                            addAttribute('agility', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '身法'); break;

                        case 'atMagicAttackPowerBase': // 内功攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'MAGIC', '内功攻击'); break;
                        case 'atPhysicsAttackPowerBase': // 外功攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'PHYSICS', '外功攻击'); break;
                        case 'atLunarAttackPowerBase': // 阴性攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'LUNAR', '阴性攻击'); break;
                        case 'atNeutralAttackPowerBase': // 混元攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'NEUTRAL', '混元攻击'); break;
                        case 'atPoisonAttackPowerBase': // 毒性攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'POISON', '毒性攻击'); break;
                        case 'atSolarAttackPowerBase': // 阳性攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR', '阳性攻击'); break;
                        case 'atSolarAndLunarAttackPowerBase': // 阴阳攻击
                            addAttribute('attack', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR_LUNAR', '阴阳攻击'); break;

                        case 'atTherapyPowerBase': // 治疗
                            addAttribute('heal', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '治疗成效'); break;

                        case 'atAllTypeCriticalStrike': // 全会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'ALL', '全会心等级'); break;
                        case 'atLunarCriticalStrike': // 阴性会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'LUNAR', '阴性会心等级'); break;
                        case 'atMagicCriticalStrike': // 内功会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'MAGIC', '内功会心等级'); break;
                        case 'atNeutralCriticalStrike': // 混元会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'NEUTRAL', '混元会心等级'); break;
                        case 'atPhysicsCriticalStrike': // 外功会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'PHYSICS', '外功会心等级'); break;
                        case 'atPoisonCriticalStrike': // 毒性会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'POISON', '毒性会心等级'); break;
                        case 'atSolarAndLunarCriticalStrike': // 阴阳会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR_LUNAR', '阴阳会心等级'); break;
                        case 'atSolarCriticalStrike': // 阳性会心
                            addAttribute('crit', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR', '阳性会心等级'); break;

                        case 'atAllTypeCriticalDamagePowerBase': // 全会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'ALL', '全会效等级'); break;
                        case 'atLunarCriticalDamagePowerBase': // 阴性会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'LUNAR', '阴性会效等级'); break;
                        case 'atMagicCriticalDamagePowerBase': // 内功会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'MAGIC', '内功会效等级'); break;
                        case 'atNeutralCriticalDamagePowerBase': // 混元会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'NEUTRAL', '混元会效等级'); break;
                        case 'atPhysicsCriticalDamagePowerBase': // 外功会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'PHYSICS', '外功会效等级'); break;
                        case 'atPoisonCriticalDamagePowerBase': // 毒性会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'POISON', '毒性会效等级'); break;
                        case 'atSolarAndLunarCriticalDamagePowerBase': // 阴阳会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR_LUNAR', '阴阳会效等级'); break;
                        case 'atSolarCriticalDamagePowerBase': // 阳性会效
                            addAttribute('critEffect', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR', '阳性会效等级'); break;

                        case 'atAllTypeHitValue': // 全命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'ALL', '全命中等级'); break;
                        case 'atLunarHitValue': // 阴性命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'LUNAR', '阴性命中等级'); break;
                        case 'atMagicHitValue': // 内功命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'MAGIC', '内功命中等级'); break;
                        case 'atNeutralHitValue': // 混元命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'NEUTRAL', '混元命中等级'); break;
                        case 'atPhysicsHitValue': // 外功命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'PHYSICS', '外功命中等级'); break;
                        case 'atPoisonHitValue': // 毒性命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'POISON', '毒性命中等级'); break;
                        case 'atSolarAndLunarHitValue': // 阴阳命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR_LUNAR', '阴阳命中等级'); break;
                        case 'atSolarHitValue': // 阳性命中
                            addAttribute('hit', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR', '阳性命中等级'); break;

                        case 'atLunarOvercomeBase': // 阴性破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'LUNAR', '阴性破防等级'); break;
                        case 'atMagicOvercome': // 内功破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'MAGIC', '内功破防等级'); break;
                        case 'atNeutralOvercomeBase': // 混元破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'NEUTRAL', '混元破防等级'); break;
                        case 'atPhysicsOvercomeBase': // 外功破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'PHYSICS', '外功破防等级'); break;
                        case 'atPoisonOvercomeBase': // 毒性破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'POISON', '毒性破防等级'); break;
                        case 'atSolarAndLunarOvercomeBase': // 阴阳破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR_LUNAR', '阴阳破防等级'); break;
                        case 'atSolarOvercomeBase': // 阳性破防
                            addAttribute('overcome', int.tryParse(attribute.param1Min) ?? 0, 'SOLAR', '阳性破防等级'); break;

                        case 'atDodge': // 闪避
                            addAttribute('dodge', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '闪避等级'); break;
                        case 'atStrainBase': // 无双
                            addAttribute('strain', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '无双等级'); break;
                        case 'atHasteBase': // 加速
                            addAttribute('haste', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '加速等级'); break;
                        case 'atParryBase': // 招架
                            addAttribute('parryBase', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '招架等级'); break;
                        case 'atParryValueBase': // 拆招
                            addAttribute('parryValue', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '拆招等级'); break;
                        case 'atMagicShield': // 内防
                            addAttribute('magicShield', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '内功防御等级'); break;
                        case 'atPhysicsShieldAdditional': // 外防
                        case 'atPhysicsShieldBase': // 外防
                            addAttribute('physicsShield', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '外功防御等级'); break;
                        case 'atDecriticalDamagePowerBase': // 化劲
                            addAttribute('huajing', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '化劲等级'); break;
                        case 'atToughnessBase': // 御劲
                            addAttribute('toughness', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '御劲等级'); break;
                        case 'atSkillEventHandler': // 被动特效1
                            // skillIds.add(['event', attribute.param1Min, '0']);
                            break;
                        case 'atSetEquipmentRecipe': // 被动特效2
                            // skillIds.add(['recipe', attribute.param1Min, attribute.param2Min]);
                            break;
                        case 'atAddSprintPowerMax': // 气力上限
                            addAttribute('sprint', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '气力值上限'); break;
                        case 'atAddHorseSprintPowerMax': // 骑术气力上限
                            addAttribute('horseSprint', int.tryParse(attribute.param1Min) ?? 0, 'NONE', '马术气力值上限'); break;
                        default:
                            print('套装特效解析异常，setId=${raw.id}, name=${raw.name}'); break;
                    }
                }
            });
            var setEffect = effectParser.getAttributeEffect(
                id: attributeIds.join('-'),
                keys: attributeKeys,
                values: attributeValues,
                decorators: attributeDecorators,
                description: descriptions,
            );
        });
    }
}
