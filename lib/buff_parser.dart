import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/buff.dart';
import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/skill.dart';

class BuffParser {
    Map<int, Buff> buffMap;
    Map<String, RawBuff> rawBuffs;
    Map<String, RawSkillInfo> skillInfo;
    Map<String, int> buffIds;

    EffectParser effectParser;

    int buffNext = 0;

    BuffParser({
        Map formations,
        Map ids,
        Map skills,
        Map buffs,
        this.effectParser,
    }) {
        rawBuffs = {};
        buffs.forEach((key, value) {
            var raw = RawBuff.fromJson(value);
            rawBuffs[key] = raw;
        });

        skillInfo = {};
        skills.forEach((key, value) {
            var raw = RawSkillInfo.fromJson(value);
            skillInfo[key] = raw;
        });

        buffIds = {};
        ids.forEach((key, value) {
            String originalId = value['ID'];
            if (originalId.contains('buff')) {
                var databaseId = int.tryParse(value['databaseId']) ?? 0;
                buffIds[originalId] = databaseId;
                buffNext = max(buffNext, databaseId);
            }
        });

        buffMap = {};
        formations.forEach((key, value) {
            var raw = RawFormationInfo.fromJson(value);
            var formation = parseFormation(raw);
            if (formation != null) {
                buffMap[formation.id] = formation;
            }

        });

    }

    int getNewId(String identifier) {
        buffIds[identifier] = ++buffNext;
        return buffNext;
    }

    void export(String path) {
        var buffs = <List<String>>[];
        buffMap.forEach((id, b) {
            buffs.add(b.toList());
        });
        buffs..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['id', 'name', 'icon', 'type', 'conflict', 'version', 'kungfuLimit', 'effectId']);
        var buffCsv = const ListToCsvConverter().convert(buffs);
        File('$path/buff.csv').writeAsString(buffCsv);
    }

    Buff parseFormation(RawFormationInfo raw) {
        var identifier = 'formation-${raw.skillId}';
        var databaseId = buffIds[identifier] ?? getNewId(identifier);
        var buff = Buff();
        buff.id = databaseId;
        buff.name = raw.name;
        buff.type = 'Formation';
        buff.conflict = 1;
        buff.version = '奉天证道';

        var skill1 = skillInfo['${raw.skillId}-1'];
        var skill2 = skillInfo['${raw.skillId}-2'];
        var skill3 = skillInfo['${raw.skillId}-3'];
        var skill4 = skillInfo['${raw.skillId}-4'];
        var skill5 = skillInfo['${raw.skillId}-5'];
        var skill6 = skillInfo['${raw.skillId}-6'];

        buff.icon = int.tryParse(skill1.iconId);

        var rawBuff = rawBuffs[raw.level3];
        var keys = <String>[];
        var values = <int>[];
        var decorators = <String>[];

        var apply = (String k, int v, String d) {
            keys.add(k);
            values.add(v);
            decorators.add(d);
        };

        [
            [rawBuff.beginAttrib1, rawBuff.beginValue1A],
            [rawBuff.beginAttrib2, rawBuff.beginValue2A],
            [rawBuff.beginAttrib3, rawBuff.beginValue3A],
            [rawBuff.beginAttrib4, rawBuff.beginValue4A],
            [rawBuff.beginAttrib5, rawBuff.beginValue5A],
            [rawBuff.beginAttrib6, rawBuff.beginValue6A],
            [rawBuff.beginAttrib7, rawBuff.beginValue7A],
            [rawBuff.beginAttrib8, rawBuff.beginValue8A],
            [rawBuff.beginAttrib9, rawBuff.beginValue9A],
            [rawBuff.beginAttrib10, rawBuff.beginValue10A],
            [rawBuff.beginAttrib11, rawBuff.beginValue11A],
            [rawBuff.beginAttrib12, rawBuff.beginValue12A],
            [rawBuff.beginAttrib13, rawBuff.beginValue13A],
            [rawBuff.beginAttrib14, rawBuff.beginValue14A],
            [rawBuff.beginAttrib15, rawBuff.beginValue15A],
        ].forEach((tuple) {
            var key = tuple[0];
            var value = int.tryParse(tuple[1]);

            switch (key) {
                case 'atSkillEventHandler':
                case 'atAddExpPercent':
                case 'atAddReputationPercent':
                case 'atGlobalResistPercent':
                case 'atFormationEffect':
                case 'atDamageToLifeForSelf':
                case 'atBeTherapyCoefficient':
                case 'atTransferTherapy':
                case 'atRepulsedRate':
                case 'atKnockedBackRate':
                case 'atMaxSkillRadiusAdd':
                case 'atAllShieldIgnorePercent':
                case 'atPhysicsDamageCoefficient':
                case 'atMoveSpeedPercent':
                case 'atLunarMagicShieldPercent':
                case 'atSolarMagicShieldPercent':
                case 'atPoisonMagicShieldPercent':
                case '': break;
                // 基础属性
                case 'atVitalityBase': // 体质
                    apply('vitality', value, 'NONE'); break;
                case 'atVitalityBasePercentAdd': // 体质
                    apply('vitalityPercent', value, 'NONE'); break;
                case 'atSpunkBase': // 元气
                    apply('spunk', value, 'NONE'); break;
                case 'atSpunkBasePercentAdd': // 元气
                    apply('spunkPercent', value, 'NONE'); break;
                case 'atSpiritBase': // 根骨
                    apply('spirit', value, 'NONE'); break;
                case 'atSpiritBasePercentAdd': // 根骨
                    apply('spiritPercent', value, 'NONE'); break;
                case 'atStrengthBase': // 力道
                    apply('strength', value, 'NONE'); break;
                case 'atStrengthBasePercentAdd': // 力道
                    apply('strengthPercent', value, 'NONE'); break;
                case 'atAgilityBase': // 身法
                    apply('agility', value, 'NONE'); break;
                case 'atAgilityBasePercentAdd': // 身法
                    apply('agilityPercent', value, 'NONE'); break;
                case 'atMagicAttackPowerBase': // 内功攻击
                    apply('attack', value, 'MAGIC'); break;
                case 'atMagicAttackPowerPercent': // 内功攻击
                    apply('attackPercent', value, 'MAGIC'); break;
                case 'atPhysicsAttackPowerBase': // 外功攻击
                    apply('attack', value, 'PHYSICS'); break;
                case 'atPhysicsAttackPowerPercent': // 外功攻击
                    apply('attackPercent', value, 'PHYSICS'); break;
                case 'atLunarAttackPowerBase': // 阴性攻击
                    apply('attack', value, 'LUNAR'); break;
                case 'atNeutralAttackPowerBase': // 混元攻击
                    apply('attack', value, 'NEUTRAL'); break;
                case 'atPoisonAttackPowerBase': // 毒性攻击
                    apply('attack', value, 'POISON'); break;
                case 'atSolarAttackPowerBase': // 阳性攻击
                    apply('attack', value, 'SOLAR'); break;
                case 'atSolarAndLunarAttackPowerBase': // 阴阳攻击
                    apply('attack', value, 'SOLAR_LUNAR'); break;
                case 'atTherapyPowerBase': // 治疗
                    apply('heal', value, 'NONE'); break;
                case 'atTherapyPowerPercent': // 治疗
                case 'atTherapyCoefficient': // 治疗
                    apply('healPercent', value, 'NONE'); break;
                case 'atAllTypeCriticalStrike': // 会心
                    apply('crit', value, 'ALL'); break;
                case 'atAllTypeCriticalStrikeBaseRate': // 会心
                    apply('critPercent', value, 'ALL'); break;
                case 'atLunarCriticalStrike': // 会心
                    apply('crit', value, 'LUNAR'); break;
                case 'atLunarCriticalStrikeBaseRate': // 会心
                    apply('critPercentage', value, 'LUNAR'); break;
                case 'atMagicCriticalStrike': // 会心
                    apply('crit', value, 'MAGIC'); break;
                case 'atMagicCriticalStrikeBaseRate': // 会心
                    apply('critPercent', value, 'MAGIC'); break;
                case 'atNeutralCriticalStrike': // 会心
                    apply('crit', value, 'NEUTRAL'); break;
                case 'atNeutralCriticalStrikeBaseRate': // 会心
                    apply('critPercent', value, 'NEUTRAL'); break;
                case 'atPhysicsCriticalStrike': // 会心
                    apply('crit', value, 'PHYSICS'); break;
                case 'atPhysicsCriticalStrikeBaseRate': // 会心
                    apply('critPercentage', value, 'PHYSICS'); break;
                case 'atPoisonCriticalStrike': // 会心
                    apply('crit', value, 'POISON'); break;
                case 'atPoisonCriticalStrikeBaseRate': // 会心
                    apply('critPercentage', value, 'POISON'); break;
                case 'atSolarAndLunarCriticalStrike': // 会心
                    apply('crit', value, 'SOLAR'); break;
                case 'atSolarAndLunarCriticalStrikeBaseRate': // 会心
                    apply('critPercentage', value, 'SOLAR'); break;
                case 'atSolarCriticalStrike': // 会心
                    apply('crit', value, 'SOLAR_LUNAR'); break;
                case 'atSolarCriticalStrikeBaseRate': // 会心
                    apply('critPercentage', value, 'SOLAR_LUNAR'); break;
                case 'atAllTypeCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'ALL'); break;
                case 'atAllTypeCriticalDamagePowerBaseeKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'ALL'); break;
                case 'atLunarCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'LUNAR'); break;
                case 'atLunarCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'LUNAR'); break;
                case 'atMagicCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'MAGIC'); break;
                case 'atMagicCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'MAGIC'); break;
                case 'atNeutralCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'NEUTRAL'); break;
                case 'atNeutralCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'NEUTRAL'); break;
                case 'atPhysicsCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'PHYSICS'); break;
                case 'atPhysicsCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'PHYSICS'); break;
                case 'atPoisonCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'POISON'); break;
                case 'atPoisonCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'POISON'); break;
                case 'atSolarAndLunarCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'SOLAR_LUNAR'); break;
                case 'atSolarAndLunarCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'SOLAR_LUNAR'); break;
                case 'atSolarCriticalDamagePowerBase': // 会效
                    apply('critEffect', value, 'SOLAR'); break;
                case 'atSolarCriticalDamagePowerBaseKiloNumRate': // 会效
                    apply('critEffectPercent', value, 'SOLAR'); break;
                case 'atLunarOvercomeBase': // 阴性破防
                    apply('overcome', value, 'LUNAR'); break;
                case 'atLunarOvercomePercent': // 阴性破防
                    apply('overcomePercent', value, 'LUNAR'); break;
                case 'atMagicOvercome': // 内功破防
                    apply('overcome', value, 'MAGIC'); break;
                case 'atNeutralOvercomeBase': // 混元破防
                    apply('overcome', value, 'NEUTRAL'); break;
                case 'atNeutralOvercomePercent': // 混元破防
                    apply('overcomePercent', value, 'NEUTRAL'); break;
                case 'atPhysicsOvercomeBase': // 外功破防
                    apply('overcome', value, 'PHYSICS'); break;
                case 'atPhysicsOvercomePercent': // 外功破防
                    apply('overcomePercent', value, 'PHYSICS'); break;
                case 'atPoisonOvercomeBase': // 毒性破防
                    apply('overcome', value, 'POISON'); break;
                case 'atPoisonOvercomePercent': // 毒性破防
                    apply('overcomePercent', value, 'POISON'); break;
                case 'atSolarAndLunarOvercomeBase': // 阴阳破防
                    apply('overcome', value, 'SOLAR_LUNAR'); break;
                case 'atSolarAndLunarOvercomePercent': // 阴阳破防
                    apply('overcomePercent', value, 'SOLAR_LUNAR'); break;
                case 'atSolarOvercomeBase': // 阳性破防
                    apply('overcome', value, 'SOLAR'); break;
                case 'atSolarOvercomePercent': // 阳性破防
                    apply('overcomePercent', value, 'SOLAR'); break;
                case 'atDodge': // 闪避
                    apply('dodge', value, 'NONE'); break;
                case 'atDodgeBaseRate': // 闪避
                    apply('dodgePercentage', value, 'NONE'); break;
                case 'atStrainBase': // 无双
                    apply('strain', value, 'NONE'); break;
                case 'atStrainRate': // 无双
                    apply('strainPercentage', value, 'NONE'); break;
                case 'atHasteBase': // 加速
                    apply('haste', value, 'NONE'); break;
                case 'atParryBase': // 招架
                    apply('parryBase', value, 'NONE'); break;
                case 'atParryPercent': // 招架
                    apply('parryBasePercent', value, 'NONE'); break;
                case 'atParryValueBase': // 拆招
                    apply('parryValue', value, 'NONE'); break;
                case 'atParryValuePercent': // 拆招
                    apply('parryValuePercent', value, 'NONE'); break;
                case 'atMagicShield': // 内防
                    apply('magicShield', value, 'NONE'); break;
                case 'atNeutralMagicShieldPercent': // 内防
                    apply('magicShieldPercent', value, 'NONE'); break;
                case 'atPhysicsShieldAdditional': // 外防
                case 'atPhysicsShieldBase': // 外防
                    apply('physicsShield', value, 'NONE'); break;
                case 'atPhysicsShieldPercent': // 外防
                    apply('physicsShieldPercent', value, 'NONE'); break;
                case 'atSurplusValueBase': // 破招
                    apply('surplus', value, 'NONE'); break;
                case 'atDecriticalDamagePowerBase': // 化劲
                    apply('huajing', value, 'NONE'); break;
                case 'atDecriticalDamagePowerBaseKiloNumRate': // 化劲
                    apply('huajingPercent', value, 'NONE'); break;
                case 'atActiveThreatCoefficient': // 威胁
                    apply('threat', value, 'NONE'); break;
                case 'atToughnessBase': // 御劲
                    apply('toughness', value, 'NONE'); break;
                case 'atToughnessBaseRate': // 御劲
                    apply('toughnessPercent', value, 'NONE'); break;
                case 'atMaxLifeBase': // 生命
                case 'atMaxLifeAdditional': // 生命
                    apply('health', value, 'NONE'); break;
                case 'atMaxLifePercentAdd': // 生命
                    apply('healthPercent', value, 'NONE'); break;
                case 'atMaxManaBase': // 法力
                case 'atMaxManaAdditional': // 法力
                    apply('mana', value, 'NONE'); break;
                case 'atLifeReplenishExt': // 生命回复
                    apply('healthRecover', value, 'NONE'); break;
                case 'atManaReplenishExt': // 法力回复
                    apply('manaRecover', value, 'NONE'); break;
                case 'atMeleeWeaponDamageBase': // 武器伤害
                    apply('damageBase', value, 'NONE'); break;
                default:
                    print('未识别的属性 $key from ${rawBuff.name}');
            }
        });

        var effect = effectParser.getBuffEffect(
            id: rawBuff.id,
            keys: keys,
            values: values,
            decorators: decorators,
            description: [skill1.desc, skill2.desc, skill3.desc, skill4.desc, skill5.desc, skill6.desc],
        );
        buff.effectId = effect.id;
        return buff;
    }
}
