class Attribute {
    String iD;
    String value;
    String modifyType;
    String param1Min;
    String param1Max;
    String param2Min;
    String param2Max;
    String group1;
    String group2;
    String group3;
    String group4;
    String group5;
    String group6;
    String group7;
    String group8;
    String group9;
    String group10;

    Attribute.fromJson(Map<String, dynamic> json) {
        iD = json['ID'];
        value = json['Value'];
        modifyType = json['ModifyType'];
        param1Min = json['Param1Min'];
        param1Max = json['Param1Max'];
        param2Min = json['Param2Min'];
        param2Max = json['Param2Max'];
        group1 = json['Group1'];
        group2 = json['Group2'];
        group3 = json['Group3'];
        group4 = json['Group4'];
        group5 = json['Group5'];
        group6 = json['Group6'];
        group7 = json['Group7'];
        group8 = json['Group8'];
        group9 = json['Group9'];
        group10 = json['Group10'];
    }
}

const attributeKeyMap = {
    'atActiveThreatCoefficient': ['threat', '47', '技能威胁提高', 1], // 威胁
    'atAddSprintPowerMax': ['sprint', '999', '气力值上限提高', 100], // 气力值上限
    'atAgilityBase': ['agility', '04', '身法提高', 1], // 身法
    'atAllTypeCriticalDamagePowerBase': ['critEffect', '38', '全会心效果等级提高', 1], // 会效
    'atAllTypeCriticalStrike': ['crit', '37', '全会心等级提高', 1], // 会心
    'atAllTypeHitValue': ['hit', '36', '全命中等级提高', 1], // 命中
    'atBasePotentialAdd': ['vitality/spirit/strength/agility/spunk', '999', '全属性提高', 1], // 全属性
    'atDecriticalDamagePowerBase': ['huajing', '52', '化劲等级提高', 1], // 化劲
    'atDodge': ['dodge', '45', '闪避等级提高', 1], // 闪避
    'atHasteBase': ['haste', '51', '加速等级提高', 1], // 加速
    'atLifeReplenishExt': ['healthRecover', '05', '每秒气血回复提高', 1], // 回血
    'atLunarAttackPowerBase': ['attack', '15', '阴性攻击提高', 1], // 阴性攻击
    'atLunarCriticalDamagePowerBase': ['critEffect', '25', '阴性会心效果等级提高', 1], // 会效
    'atLunarCriticalStrike': ['crit', '07', '阴性会心等级提高', 1], // 会心
    'atLunarHitValue': ['hit', '54', '阴性命中等级提高', 1], // 阴性命中
    'atLunarOvercomeBase': ['overcome', '14', '阴性破防等级提高', 1], // 阴性破防
    'atMagicAttackPowerBase': ['attack', '40', '内功攻击提高', 1], // 内功攻击
    'atMagicCriticalDamagePowerBase': ['critEffect', '31', '内功会心效果等级提高', 1], // 会效
    'atMagicCriticalStrike': ['crit', '10', '内功会心等级提高', 1], // 会心
    'atMagicHitValue': ['hit', '20', '内功命中等级提高', 1], // 内功命中
    'atMagicOvercome': ['overcome', '27', '内功破防等级提高', 1], // 内功破防
    'atMagicShield': ['magicShield', '43', '内功防御等级提高', 1], // 内防
    'atManaReplenishExt': ['manaRecover', '48', '每秒内力回复提高', 1], // 回蓝
    'atMaxLifeAdditional': ['health', '39', '最大气血提高', 1], // 气血
    'atMaxLifeBase': ['health', '39', '最大气血提高', 1], // 气血
    'atMaxManaAdditional': ['nama', '49', '最大内力提高', 1], // 内力
    'atMaxManaBase': ['nama', '49', '最大内力提高', 1], // 内力
    'atMeleeWeaponDamageBase': [null, '999', '武器伤害提高', 1], // 武器伤害
    'atMoveSpeedPercent': [null, '999', '移动速度提高', 1], // 移动速度
    'atNeutralAttackPowerBase': ['attack', '16', '混元攻击提高', 1], // 混元攻击
    'atNeutralCriticalDamagePowerBase': ['critEffect', '24', '混元会心效果等级提高', 1], // 会效
    'atNeutralCriticalStrike': ['crit', '23', '混元会心等级提高', 1], // 会心
    'atNeutralHitValue': ['hit', '50', '混元命中等级提高', 1], // 混元命中
    'atNeutralOvercomeBase': ['overcome', '13', '混元破防等级提高', 1], // 混元破防
    'atParryBase': ['parryBase', '46', '招架等级提高', 1], // 招架
    'atParryValueBase': ['parryValue', '44', '拆招等级提高', 1], // 拆招
    'atPhysicsAttackPowerBase': ['attack', '08', '外功攻击提高', 1], // 外功攻击
    'atPhysicsCriticalDamagePowerBase': ['critEffect', '21', '外功会心效果等级提高', 1], // 会效
    'atPhysicsCriticalStrike': ['crit', '06', '外功会心等级提高', 1], // 会心
    'atPhysicsHitValue': ['hit', '09', '外功命中等级提高', 1], // 外功命中
    'atPhysicsOvercomeBase': ['overcome', '18', '外功破防等级提高', 1], // 外功破防
    'atPhysicsShieldAdditional': ['physicsShield', '42', '外功防御等级提高', 1], // 外防
    'atPhysicsShieldBase': ['physicsShield', '42', '外功防御等级提高', 1], // 外防
    'atPoisonAttackPowerBase': ['attack', '22', '毒性攻击提高', 1], // 毒性攻击
    'atPoisonCriticalDamagePowerBase': ['critEffect', '30', '毒性会心效果等级提高', 1], // 会效
    'atPoisonCriticalStrike': ['crit', '29', '毒性会心等级提高', 1], // 会心
    'atPoisonHitValue': ['hit', '57', '毒性命中等级提高', 1], // 毒性命中
    'atPoisonOvercomeBase': ['overcome', '28', '毒性破防等级提高', 1], // 毒性破防
    'atSolarAndLunarAttackPowerBase': ['attack', '33', '阴阳攻击提高', 1], // 阴阳攻击
    'atSolarAndLunarCriticalDamagePowerBase': ['critEffect', '34', '阴阳会心效果等级提高', 1], // 会效
    'atSolarAndLunarCriticalStrike': ['crit', '35', '阴阳会心等级提高', 1], // 会心
    'atSolarAndLunarHitValue': ['hit', '56', '阴阳命中等级提高', 1], // 阴阳命中
    'atSolarAndLunarOvercomeBase': ['overcome', '32', '阴阳破防等级提高', 1], // 阴阳破防
    'atSolarAttackPowerBase': ['attack', '19', '阳性攻击提高', 1], // 阳性攻击
    'atSolarCriticalDamagePowerBase': ['critEffect', '26', '阳性会心效果等级提高', 1], // 会效
    'atSolarCriticalStrike': ['crit', '17', '阳性会心等级提高', 1], // 会心
    'atSolarHitValue': ['hit', '53', '阳性命中等级提高', 1], // 阳性命中
    'atSolarOvercomeBase': ['overcome', '12', '阳性破防等级提高', 1], // 阳性破防
    'atSpiritBase': ['spirit', '00', '根骨提高', 1], // 根骨
    'atSpunkBase': ['spunk', '01', '元气提高', 1], // 元气
    'atStrainBase': ['strain', '11', '无双等级提高', 1], // 无双
    'atStrengthBase': ['strength', '02', '力道提高', 1], // 力道
    'atTherapyPowerBase': ['heal', '41', '治疗量提高', 1], // 治疗
    'atToughnessBase': ['toughness', '55', '御劲等级提高', 1], // 御劲
    'atVitalityBase': ['vitality', '03', '体质提高', 1], // 体质
    'atSurplusValueBase': ['surplus', '58', '破招等级提高', 1], // 破招
};
