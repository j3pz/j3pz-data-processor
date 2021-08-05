import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/enchant.dart';
import 'package:j3pz_data_preprocessor/item.dart';

const enchantTitle = ['id', 'name', 'category', 'description', 'attribute', 'value', 'decorator', 'deprecated'];
const enchantTypeMap = {
    '上装': 'jacket',
    '上衣': 'jacket',
    '腰带': 'belt',
    '下装': 'bottoms',
    '项链': 'necklace',
    '武器': 'primaryWeapon',
    '手': 'wrist',
    '护手': 'wrist',
    '护腕': 'wrist',
    '头部': 'hat',
    '帽子': 'hat',
    '戒指': 'ring',
    '暗器': 'secondaryWeapon',
    '鞋子': 'shoes',
    '腰坠': 'pendant',
};

class EnchantParser {
    Map<String, int> enchantIds; // { type-id: databaseId }
    Map<String, RawEnchant> raws; // {id: RawEnchant }
    Map<int, Enchant> enchants = {}; // { id: Enchant }
    Map<String, RawItem> items = {}; // { id: RawItem }
    Map<int, List<int>> duplicates = {}; // {id: ids }

    int enchantNext = 0;

    EnchantParser({
        Map ids,
        Map other,
        Map enchant,
        Map item,
    }) {
        enchantIds = {};
        ids.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('enchant')) {
                String databaseIds = value['databaseId'];
                if (databaseIds.contains('|')) {
                    var ids = databaseIds.split('|').map((id) => int.tryParse(id) ?? 0).toList();
                    enchantIds[originalId] = ids[0];
                    duplicates[ids[0]] = ids;
                    enchantNext = max(enchantNext, ids.reduce(max));
                } else {
                    var databaseId = int.tryParse(value['databaseId']) ?? 0;
                    enchantIds[originalId] = databaseId;
                    enchantNext = max(enchantNext, databaseId);
                }
            }
        });

        items = {};
        item.forEach((key, value) {
            var itemInfo = RawItem.fromJson(value);
            items[key] = itemInfo;
        });

        raws = {};
        enchant.forEach((key, value) {
            var raw = RawEnchant.fromJson(value);
            raws[key] = raw;
        });

        other.forEach((key, value) {
            var other = RawOther.fromJson(value);
            if (other.genre == '7' && other.aucSubType > 0) {
                var enchant = parse(other);
                if (enchant != null && enchants[enchant.id] == null) {
                    enchants[enchant.id] = enchant;
                    if (duplicates[enchant.id] != null) {
                        duplicates[enchant.id].skip(1).toList().forEach((id) {
                            var duplicateEnchant = enchant.clone(id);
                            enchants[id] = duplicateEnchant;
                        });
                    }
                }
            }
        });
    }

    void export(String path) {
        var enchants = <List<String>>[];
        this.enchants.forEach((id, enchant) {
            enchants.add(enchant.toList());
        });
        enchants..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, enchantTitle);
        var enchantCsv = const ListToCsvConverter().convert(enchants);
        File('$path/enchant.csv').writeAsString(enchantCsv);

        var enchantIdList = <List<String>>[];
        enchantIds.forEach((key, databaseId) {
            if (databaseId > 0 && duplicates[databaseId] != null) {
                enchantIdList.add([key, '${duplicates[databaseId].join('|')}']);
            } else if (databaseId > 0) {
                enchantIdList.add([key, '$databaseId']);
            } else {
                enchantIdList.add([key, 'null']);
            }
        });
        enchantIdList.insert(0, ['ID', 'databaseId']);
        var enchantIdCsv = const ListToCsvConverter().convert(enchantIdList);
        File('$path/enchantId.tab').writeAsString(enchantIdCsv);
    }

    int getNewId(String identifier) {
        enchantIds[identifier] = ++enchantNext;
        return enchantNext;
    }

    Enchant parse(RawOther other) {
        var item = items[other.uiId];
        var exp = RegExp(r'<ENCHANT (\d+)>');
        var match = exp.firstMatch(item.desc);
        if (match == null) {
            return null;
        }
        var dataId = match[1];
        var data = raws[dataId];
        var identifier = 'enchant-$dataId';
        var databaseId = enchantIds[identifier] ?? getNewId(identifier);
        if (databaseId == 0) {
            return null;
        }
        var category = getCategory(data);
        if (category == null) {
            return null;
        }
        var enchant = Enchant(id: databaseId, name: other.name, category: category);
        enchant.description = data.attriName;
        var key = data.attribute1Id;
        switch (key) {
            // 基础属性
            case 'atVitalityBase': // 体质
                enchant = applyAttribute(enchant, 'vitality', data.attribute1Value1, 'NONE'); break;
            case 'atSpunkBase': // 元气
                enchant = applyAttribute(enchant, 'spunk', data.attribute1Value1, 'NONE'); break;
            case 'atSpiritBase': // 根骨
                enchant = applyAttribute(enchant, 'spirit', data.attribute1Value1, 'NONE'); break;
            case 'atStrengthBase': // 力道
                enchant = applyAttribute(enchant, 'strength', data.attribute1Value1, 'NONE'); break;
            case 'atAgilityBase': // 身法
                enchant = applyAttribute(enchant, 'agility', data.attribute1Value1, 'NONE'); break;
            case 'atMagicAttackPowerBase': // 内功攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'MAGIC'); break;
            case 'atPhysicsAttackPowerBase': // 外功攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'PHYSICS'); break;
            case 'atLunarAttackPowerBase': // 阴性攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'LUNAR'); break;
            case 'atNeutralAttackPowerBase': // 混元攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'NEUTRAL'); break;
            case 'atPoisonAttackPowerBase': // 毒性攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'POISON'); break;
            case 'atSolarAttackPowerBase': // 阳性攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'SOLAR'); break;
            case 'atSolarAndLunarAttackPowerBase': // 阴阳攻击
                enchant = applyAttribute(enchant, 'attack', data.attribute1Value1, 'SOLAR_LUNAR'); break;
            case 'atTherapyPowerBase': // 治疗
                enchant = applyAttribute(enchant, 'heal', data.attribute1Value1, 'NONE'); break;
            case 'atAllTypeCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'ALL'); break;
            case 'atLunarCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'LUNAR'); break;
            case 'atMagicCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'MAGIC'); break;
            case 'atNeutralCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'NEUTRAL'); break;
            case 'atPhysicsCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'PHYSICS'); break;
            case 'atPoisonCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'POISON'); break;
            case 'atSolarAndLunarCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'SOLAR'); break;
            case 'atSolarCriticalStrike': // 会心
                enchant = applyAttribute(enchant, 'crit', data.attribute1Value1, 'SOLAR_LUNAR'); break;
            case 'atAllTypeCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'ALL'); break;
            case 'atLunarCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'LUNAR'); break;
            case 'atMagicCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'MAGIC'); break;
            case 'atNeutralCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'NEUTRAL'); break;
            case 'atPhysicsCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'PHYSICS'); break;
            case 'atPoisonCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'POISON'); break;
            case 'atSolarAndLunarCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'SOLAR_LUNAR'); break;
            case 'atSolarCriticalDamagePowerBase': // 会效
                enchant = applyAttribute(enchant, 'critEffect', data.attribute1Value1, 'SOLAR'); break;
            case 'atAllTypeHitValue': // 命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'ALL'); break;
            case 'atLunarHitValue': // 阴性命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'LUNAR'); break;
            case 'atMagicHitValue': // 内功命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'MAGIC'); break;
            case 'atNeutralHitValue': // 混元命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'NEUTRAL'); break;
            case 'atPhysicsHitValue': // 外功命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'PHYSICS'); break;
            case 'atPoisonHitValue': // 毒性命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'POISON'); break;
            case 'atSolarAndLunarHitValue': // 阴阳命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'SOLAR_LUNAR'); break;
            case 'atSolarHitValue': // 阳性命中
                enchant = applyAttribute(enchant, 'hit', data.attribute1Value1, 'SOLAR'); break;
            case 'atLunarOvercomeBase': // 阴性破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'LUNAR'); break;
            case 'atMagicOvercome': // 内功破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'MAGIC'); break;
            case 'atNeutralOvercomeBase': // 混元破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'NEUTRAL'); break;
            case 'atPhysicsOvercomeBase': // 外功破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'PHYSICS'); break;
            case 'atPoisonOvercomeBase': // 毒性破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'POISON'); break;
            case 'atSolarAndLunarOvercomeBase': // 阴阳破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'SOLAR_LUNAR'); break;
            case 'atSolarOvercomeBase': // 阳性破防
                enchant = applyAttribute(enchant, 'overcome', data.attribute1Value1, 'SOLAR'); break;
            case 'atDodge': // 闪避
                enchant = applyAttribute(enchant, 'dodge', data.attribute1Value1, 'NONE'); break;
            case 'atStrainBase': // 无双
                enchant = applyAttribute(enchant, 'strain', data.attribute1Value1, 'NONE'); break;
            case 'atHasteBase': // 加速
                enchant = applyAttribute(enchant, 'haste', data.attribute1Value1, 'NONE'); break;
            case 'atParryBase': // 招架
                enchant = applyAttribute(enchant, 'parryBase', data.attribute1Value1, 'NONE'); break;
            case 'atParryValueBase': // 拆招
                enchant = applyAttribute(enchant, 'parryValue', data.attribute1Value1, 'NONE'); break;
            case 'atMagicShield': // 内防
                enchant = applyAttribute(enchant, 'magicShield', data.attribute1Value1, 'NONE'); break;
            case 'atPhysicsShieldAdditional': // 外防
            case 'atPhysicsShieldBase': // 外防
                enchant = applyAttribute(enchant, 'physicsShield', data.attribute1Value1, 'NONE'); break;
            case 'atSurplusValueBase': // 破招
                enchant = applyAttribute(enchant, 'surplus', data.attribute1Value1, 'NONE'); break;
            case 'atDecriticalDamagePowerBase': // 化劲
                enchant = applyAttribute(enchant, 'huajing', data.attribute1Value1, 'NONE'); break;
            case 'atActiveThreatCoefficient': // 威胁
                enchant = applyAttribute(enchant, 'threat', data.attribute1Value2, 'NONE'); break;
            case 'atToughnessBase': // 御劲
                enchant = applyAttribute(enchant, 'toughness', data.attribute1Value1, 'NONE'); break;
            case 'atMaxLifeBase': // 生命
            case 'atMaxLifeAdditional': // 生命
                enchant = applyAttribute(enchant, 'health', data.attribute1Value1, 'NONE'); break;
            case 'atMaxManaBase': // 法力
            case 'atMaxManaAdditional': // 法力
                enchant = applyAttribute(enchant, 'mana', data.attribute1Value1, 'NONE'); break;
            case 'atLifeReplenishExt': // 生命回复
                enchant = applyAttribute(enchant, 'healthRecover', data.attribute1Value1, 'NONE'); break;
            case 'atManaReplenishExt': // 法力回复
                enchant = applyAttribute(enchant, 'manaRecover', data.attribute1Value1, 'NONE'); break;
            case 'atMeleeWeaponDamageBase': // 武器伤害
                enchant = applyAttribute(enchant, 'damageBase', data.attribute1Value1, 'NONE'); break;
            case 'atMoveSpeedPercent': // 移动速度
                enchant = applyAttribute(enchant, 'moveSpeed', data.attribute1Value1, 'NONE'); break;
        };
        enchant.deprecated = false;
        return enchant;
    }

    String getCategory(RawEnchant raw) {
        var value = enchantTypeMap[raw.uiid];
        if (raw.uiid.contains('限时') || value == null) {
            return null;
        }
        return value;
    }

    Enchant applyAttribute(Enchant enchant, String key, String value, String decorator) {
        enchant.attribute = key;
        enchant.value = int.tryParse(value) ?? 0;
        enchant.decorator = decorator;
        return enchant;
    }
}
