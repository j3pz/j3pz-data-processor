import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/attribute_stone.dart';
import 'package:j3pz_data_preprocessor/enchant.dart';
import 'package:j3pz_data_preprocessor/item.dart';

class StoneParser {
    Map<String, AttributeStone> attributeStones = {};
    Map<String, StoneAttribute> attributes = {};
    Map<String, int> stoneIds; // { stone-id: databaseId }
    Map<String, RawItem> rawItems; // { id: RawItem }
    Map<String, RawEnchant> rawEnchant; // {id: RawEnchant }
    Map<int, List<int>> relations;

    int stoneNext = 0;
    int attributeNext = 0;
    
    StoneParser({
        Map others,
        Map<String, dynamic> items,
        Map ids,
        Map enchants,
    }) {
        stoneIds = {};
        ids.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('stone')) {
                var databaseId = int.tryParse(value['databaseId']) ?? 0;
                stoneIds[originalId] = databaseId;
                stoneNext = max(stoneNext, databaseId);
            }
        });

        rawItems = {};
        items.forEach((key, value) {
            var itemInfo = RawItem.fromJson(value);
            rawItems[key] = itemInfo;
        });

        rawEnchant = {};
        enchants.forEach((key, value) {
            var raw = RawEnchant.fromJson(value);
            rawEnchant[key] = raw;
        });

        relations = {};

        others.forEach((key, value) {
            var other = RawOther.fromJson(value);
            if (other.category == '五彩石' && other.detailType > 3) {
                parseAttributeStone(other);
            }
        });
    }

    void export(String path) {
        var stones = <List<String>>[];
        attributeStones.forEach((id, stone) {
            stones.add(stone.toList());
        });
        stones..sort((a,b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['id', 'name', 'icon', 'level', 'deprecated']);

        var stoneCsv = const ListToCsvConverter().convert(stones);
        File('$path/stone.csv').writeAsString(stoneCsv);

        var attribute = <List<String>>[];
        attributes.forEach((id, attrib) {
            attribute.add(attrib.toList());
        });
        attribute..sort((a,b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['id', 'name', 'decorator', 'key', 'value', 'requiredQuantity', 'requiredLevel']);
        var attributeCsv = const ListToCsvConverter().convert(attribute);
        File('$path/stone_attributes.csv').writeAsString(attributeCsv);

        var relation = <List<String>>[];
        relations.forEach((stoneId, attributeIds) {
            attributeIds.forEach((attributeId) {
                relation.add(['$stoneId', '$attributeId']);
            });
        });
        relation..sort((a,b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['stoneId', 'stoneAttributeId']);
        var relationCsv = const ListToCsvConverter().convert(relation);
        File('$path/stone_attributes_stone_attribute.csv').writeAsString(relationCsv);
    }

    int getNewId(String identifier) {
        stoneIds[identifier] = ++stoneNext;
        return stoneNext;
    }

    void parseAttributeStone(RawOther raw) {
        var identifier = 'stone-${raw.id}';
        var stone = AttributeStone(
            id: stoneIds[identifier] ?? getNewId(identifier), 
            name: raw.name,
            level: raw.detailType,
        );
        stone.deprecated = false;
        stone.icon = rawItems[raw.uiId]?.icon ?? 1434;
        attributeStones[identifier] = stone;

        relations[stone.id] = [];

        var enchant = rawEnchant[raw.enchantId];
        if (enchant != null) {
            parseAttribute(stone, '${enchant.attribute1Id}-${enchant.attribute1Value1}-${enchant.attribute1Value2}-${enchant.diamondCount1}-${enchant.diamondIntensity1}');
            parseAttribute(stone, '${enchant.attribute2Id}-${enchant.attribute2Value1}-${enchant.attribute2Value2}-${enchant.diamondCount2}-${enchant.diamondIntensity2}');
            parseAttribute(stone, '${enchant.attribute3Id}-${enchant.attribute3Value2}-${enchant.attribute3Value2}-${enchant.diamondCount3}-${enchant.diamondIntensity3}');
        }
    }

    void parseAttribute(AttributeStone stone, String identifier) {
        if (attributes[identifier] == null) {
            var attribute = StoneAttribute();
            var info = identifier.split('-');
            var key = info[0];
            var value1 = double.tryParse(info[1]) ?? 0;
            var value2 = double.parse(((double.tryParse(info[2]) ?? 0) / 1024).toStringAsFixed(2));
            switch (key) {
                // 基础属性
                case 'atVitalityBase': // 体质
                    attribute = applyAttribute(attribute, 'vitality', value1, 'NONE', '体质'); break;
                case 'atVitalityBasePercentAdd': // 体质
                    attribute = applyAttribute(attribute, 'vitality', value2, 'NONE', '体质'); break;
                case 'atSpunkBase': // 元气
                    attribute = applyAttribute(attribute, 'spunk', value1, 'NONE', '元气'); break;
                case 'atSpunkBasePercentAdd': // 元气
                    attribute = applyAttribute(attribute, 'spunk', value2, 'NONE', '元气'); break;
                case 'atSpiritBase': // 根骨
                    attribute = applyAttribute(attribute, 'spirit', value1, 'NONE', '根骨'); break;
                case 'atSpiritBasePercentAdd': // 根骨
                    attribute = applyAttribute(attribute, 'spirit', value2, 'NONE', '根骨'); break;
                case 'atStrengthBase': // 力道
                    attribute = applyAttribute(attribute, 'strength', value1, 'NONE', '力道'); break;
                case 'atStrengthBasePercentAdd': // 力道
                    attribute = applyAttribute(attribute, 'strength', value2, 'NONE', '力道'); break;
                case 'atAgilityBase': // 身法
                    attribute = applyAttribute(attribute, 'agility', value1, 'NONE', '身法'); break;
                case 'atAgilityBasePercentAdd': // 身法
                    attribute = applyAttribute(attribute, 'agility', value2, 'NONE', '身法'); break;
                case 'atBasePotentialAdd': // 全属性
                    attribute = applyAttribute(attribute, 'vitality|spunk|spirit|strength|agility', value1, 'NONE', '全属性'); break;
                case 'atMagicAttackPowerBase': // 内功攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'MAGIC', '内功·攻击'); break;
                case 'atPhysicsAttackPowerBase': // 外功攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'PHYSICS', '外功·攻击'); break;
                case 'atLunarAttackPowerBase': // 阴性攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'LUNAR', '阴性·攻击'); break;
                case 'atNeutralAttackPowerBase': // 混元攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'NEUTRAL', '混元·攻击'); break;
                case 'atPoisonAttackPowerBase': // 毒性攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'POISON', '毒性·攻击'); break;
                case 'atSolarAttackPowerBase': // 阳性攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'SOLAR', '阳性·攻击'); break;
                case 'atSolarAndLunarAttackPowerBase': // 阴阳攻击
                    attribute = applyAttribute(attribute, 'attack', value1, 'SOLAR_LUNAR', '阴阳·攻击'); break;
                case 'atTherapyPowerBase': // 治疗
                    attribute = applyAttribute(attribute, 'heal', value1, 'NONE', '治疗成效'); break;
                case 'atTherapyCoefficient': // 治疗
                    attribute = applyAttribute(attribute, 'heal', value2, 'NONE', '治疗成效'); break;
                case 'atAllTypeCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'ALL', '全会心'); break;
                case 'atLunarCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'LUNAR', '阴性·会心'); break;
                case 'atMagicCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'MAGIC', '内功·会心'); break;
                case 'atNeutralCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'NEUTRAL', '混元·会心'); break;
                case 'atPhysicsCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'PHYSICS', '外功·会心'); break;
                case 'atPoisonCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'POISON', '毒性·会心'); break;
                case 'atSolarAndLunarCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'SOLAR', '阳性·会心'); break;
                case 'atSolarCriticalStrike': // 会心
                    attribute = applyAttribute(attribute, 'crit', value1, 'SOLAR_LUNAR', '阴阳·会心'); break;
                case 'atAllTypeCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'ALL', '全会效'); break;
                case 'atLunarCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'LUNAR', '阴性·会效'); break;
                case 'atMagicCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'MAGIC', '内功·会效'); break;
                case 'atNeutralCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'NEUTRAL', '混元·会效'); break;
                case 'atPhysicsCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'PHYSICS', '外功·会效'); break;
                case 'atPoisonCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'POISON', '毒性·会效'); break;
                case 'atSolarAndLunarCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'SOLAR_LUNAR', '阴阳·会效'); break;
                case 'atSolarCriticalDamagePowerBase': // 会效
                    attribute = applyAttribute(attribute, 'critEffect', value1, 'SOLAR', '阳性·会效'); break;
                case 'atAllTypeHitValue': // 命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'ALL', '全命中'); break;
                case 'atLunarHitValue': // 阴性命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'LUNAR', '阴性·命中'); break;
                case 'atMagicHitValue': // 内功命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'MAGIC', '内功·命中'); break;
                case 'atNeutralHitValue': // 混元命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'NEUTRAL', '混元·命中'); break;
                case 'atPhysicsHitValue': // 外功命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'PHYSICS', '外功·命中'); break;
                case 'atPoisonHitValue': // 毒性命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'POISON', '毒性·命中'); break;
                case 'atSolarAndLunarHitValue': // 阴阳命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'SOLAR_LUNAR', '阴阳·命中'); break;
                case 'atSolarHitValue': // 阳性命中
                    attribute = applyAttribute(attribute, 'hit', value1, 'SOLAR', '阳性·命中'); break;
                case 'atLunarOvercomeBase': // 阴性破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'LUNAR', '阴性·破防'); break;
                case 'atMagicOvercome': // 内功破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'MAGIC', '内功·破防'); break;
                case 'atNeutralOvercomeBase': // 混元破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'NEUTRAL', '混元·破防'); break;
                case 'atPhysicsOvercomeBase': // 外功破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'PHYSICS', '外功·破防'); break;
                case 'atPoisonOvercomeBase': // 毒性破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'POISON', '毒性·破防'); break;
                case 'atSolarAndLunarOvercomeBase': // 阴阳破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'SOLAR_LUNAR', '阴阳·破防'); break;
                case 'atSolarOvercomeBase': // 阳性破防
                    attribute = applyAttribute(attribute, 'overcome', value1, 'SOLAR', '阳性·破防'); break;
                case 'atDodge': // 闪避
                    attribute = applyAttribute(attribute, 'dodge', value1, 'NONE', '闪避'); break;
                case 'atStrainBase': // 无双
                    attribute = applyAttribute(attribute, 'strain', value1, 'NONE', '无双'); break;
                case 'atHasteBase': // 加速
                    attribute = applyAttribute(attribute, 'haste', value1, 'NONE', '加速'); break;
                case 'atParryBase': // 招架
                    attribute = applyAttribute(attribute, 'parryBase', value1, 'NONE', '招架'); break;
                case 'atParryValueBase': // 拆招
                    attribute = applyAttribute(attribute, 'parryValue', value1, 'NONE', '拆招'); break;
                case 'atMagicShield': // 内防
                    attribute = applyAttribute(attribute, 'magicShield', value1, 'NONE', '内防'); break;
                case 'atPhysicsShieldAdditional': // 外防
                case 'atPhysicsShieldBase': // 外防
                    attribute = applyAttribute(attribute, 'physicsShield', value1, 'NONE', '外防'); break;
                case 'atSurplusValueBase': // 破招
                    attribute = applyAttribute(attribute, 'surplus', value1, 'NONE', '破招'); break;
                case 'atDecriticalDamagePowerBase': // 化劲
                    attribute = applyAttribute(attribute, 'huajing', value1, 'NONE', '化劲'); break;
                case 'atActiveThreatCoefficient': // 威胁
                    attribute = applyAttribute(attribute, 'threat', value2, 'NONE', '威胁'); break;
                case 'atToughnessBase': // 御劲
                    attribute = applyAttribute(attribute, 'toughness', value1, 'NONE', '御劲'); break;
                case 'atMaxLifeBase': // 生命
                case 'atMaxLifeAdditional': // 生命
                    attribute = applyAttribute(attribute, 'health', value1, 'NONE', '血上限'); break;
                case 'atMaxManaBase': // 法力
                case 'atMaxManaAdditional': // 法力
                    attribute = applyAttribute(attribute, 'mana', value1, 'NONE', '内力上限'); break;
                case 'atLifeReplenishExt': // 生命回复
                    attribute = applyAttribute(attribute, 'healthRecover', value1, 'NONE', '回血'); break;
                case 'atManaReplenishExt': // 法力回复
                    attribute = applyAttribute(attribute, 'manaRecover', value1, 'NONE', '回蓝'); break;
                case 'atMeleeWeaponDamageBase': // 武器伤害
                    attribute = applyAttribute(attribute, 'damageBase', value1, 'NONE', '武器伤害'); break;
                case 'atMoveSpeedPercent': // 移动速度
                    attribute = applyAttribute(attribute, 'moveSpeed', value1, 'NONE', '移动速度'); break;
                case 'atDamageToLifeForSelf': // 抽血
                    attribute = applyAttribute(attribute, 'stealHealth', value1, 'NONE', '抽血'); break;
                case 'atGlobalResistPercent': // 免伤
                    attribute = applyAttribute(attribute, 'resist', value2, 'NONE', '免伤'); break;
                case 'atBeTherapyCoefficient': // 被疗成效
                    attribute = applyAttribute(attribute, 'beTherapy', value2, 'NONE', '被疗成效'); break;
                case 'atModifyCostManaPercent': // 减蓝耗
                    attribute = applyAttribute(attribute, 'manaCost', value2, 'NONE', '减蓝耗'); break;
                default: 
                    return;
            }
            attribute.requiredQuantity = int.tryParse(info[3]) ?? 0;
            attribute.requiredLevel = int.tryParse(info[4]) ?? 0;
            attribute.id = ++attributeNext;
            attributes[identifier] = attribute;
        }
        relations[stone.id].add(attributes[identifier].id);
    }

    StoneAttribute applyAttribute(StoneAttribute attribute, String key, double value, String decorator, String name) {
        attribute.key = key;
        attribute.name = name;
        attribute.value = value;
        attribute.decorator = decorator;
        return attribute;
    }
}