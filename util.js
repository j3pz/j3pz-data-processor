const menpaiList = ['通用', '精简', '万花', '少林', '唐门', '明教', '七秀', '五毒', '纯阳', '天策', '丐帮', '藏剑', '苍云', '长歌', '霸刀', '蓬莱'];
const xinfaType = ['内功', '外功', '元气', '根骨', '力道', '身法', '治疗', '防御'];

const spunkXinfa = ['万花', '少林', '唐门', '明教'];
const spiritXinfa = ['七秀', '五毒', '纯阳', '长歌'];
const strengthXinfa = ['唐门', '天策', '丐帮', '霸刀'];
const agilityXinfa = ['纯阳', '藏剑', '苍云', '蓬莱'];

const typeMap = {
    0: [11, 1.2], // 武器
    1: [4, 0.6], // 暗器
    4: [0, 0.5], // 项链
    5: [2, 0.5], // 戒指
    7: [1, 0.5], // 腰坠
    2: [8, 1], // 上衣
    3: [9, 0.9], // 帽子
    6: [10, 0.7], // 腰带
    8: [7, 1], // 下装
    9: [5, 0.7], // 鞋子
    10: [6, 0.7], // 护腕
}
// atSetEquipmentRecipe	event	
// atSkillEventHandler	texiao	特效
const attributeKeyMap = {
    'atActiveThreatCoefficient': 'threat', // 威胁
    'atAgilityBase': 'agility', // 身法
    'atAllTypeCriticalDamagePowerBase': 'critEffect', // 会效
    'atAllTypeCriticalStrike': 'crit', // 会心
    'atAllTypeHitValue': 'hit', // 命中
    'atDecriticalDamagePowerBase': 'huajing', // 化劲
    'atDodge': 'dodge', // 闪避
    'atHasteBase': 'acce', // 加速
    'atLunarAttackPowerBase': 'attack', // 阴性攻击
    'atLunarCriticalDamagePowerBase': 'critEffect', // 会效
    'atLunarCriticalStrike': 'crit', // 会心
    'atLunarHitValue': 'hit', // 阴性命中
    'atLunarOvercomeBase': 'overcome', // 阴性破防
    'atMagicAttackPowerBase': 'attack', // 内功攻击
    'atMagicCriticalDamagePowerBase': 'critEffect', // 会效
    'atMagicCriticalStrike': 'crit', // 会心
    'atMagicHitValue': 'hit', // 内功命中
    'atMagicOvercome': 'overcome', // 内功破防
    'atMagicShield': 'magicShield', // 内防
    'atNeutralAttackPowerBase': 'attack', // 混元攻击
    'atNeutralCriticalDamagePowerBase': 'critEffect', // 会效
    'atNeutralCriticalStrike': 'crit', // 会心
    'atNeutralHitValue': 'hit', // 混元命中
    'atNeutralOvercomeBase': 'overcome', // 混元破防
    'atParryBase': 'parryBase', // 招架
    'atParryValueBase': 'parryValue', // 拆招
    'atPhysicsAttackPowerBase': 'attack', // 外功攻击
    'atPhysicsCriticalDamagePowerBase': 'critEffect', // 会效
    'atPhysicsCriticalStrike': 'crit', // 会心
    'atPhysicsHitValue': 'hit', // 外功命中
    'atPhysicsOvercomeBase': 'overcome', // 外功破防
    'atPhysicsShieldAdditional': 'physicsShield', // 外防
    'atPhysicsShieldBase': 'physicsShield', // 外防
    'atPoisonAttackPowerBase': 'attack', // 毒性攻击
    'atPoisonCriticalDamagePowerBase': 'critEffect', // 会效
    'atPoisonCriticalStrike': 'crit', // 会心
    'atPoisonHitValue': 'hit', // 毒性命中
    'atPoisonOvercomeBase': 'overcome', // 毒性破防
    'atSolarAndLunarAttackPowerBase': 'attack', // 阴阳攻击
    'atSolarAndLunarCriticalDamagePowerBase': 'critEffect', // 会效
    'atSolarAndLunarCriticalStrike': 'crit', // 会心
    'atSolarAndLunarHitValue': 'hit', // 阴阳命中
    'atSolarAndLunarOvercomeBase': 'overcome', // 阴阳破防
    'atSolarAttackPowerBase': 'attack', // 阳性攻击
    'atSolarCriticalDamagePowerBase': 'critEffect', // 会效
    'atSolarCriticalStrike': 'crit', // 会心
    'atSolarHitValue': 'hit', // 阳性命中
    'atSolarOvercomeBase': 'overcome', // 阳性破防
    'atSpiritBase': 'spirit', // 根骨
    'atSpunkBase': 'spunk', // 元气
    'atStrainBase': 'strain', // 无双
    'atStrengthBase': 'strength', // 力道
    'atTherapyPowerBase': 'heal', // 治疗
    'atToughnessBase': 'toughness', // 御劲
    'atVitalityBase': 'body', // 体质
}

module.exports = {
    getMenpai(rawText) {
        return menpaiList.indexOf(rawText);
    },

    getXinfaType(rawText, menpai) {
        const xinfa = xinfaType.indexOf(rawText);
        if (xinfa === 0 && menpai > 1) {
            if (spunkXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return 2;
            }
            if (spiritXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return 3;
            }
        }
        if (xinfa === 1 && menpai > 1) {
            if (strengthXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return 4;
            }
            if (agilityXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return 5;
            }
        }
        return xinfa;
    },

    getEquipType(subType, detailType) {
        const type = typeMap[subType][0];
        if (type === 0 && detailType == '9') {
            // 重剑
            return 12;
        }
        return type;
    },

    getEquipScore(quality, subType, sthengthen) {
        let cof = 1.8;
        if (sthengthen > 6) {
            cof = 2.5;
        }
        return Math.floor(quality * cof * typeMap[subType][1]);
    },

    getBasicInfo(rawEquip) {
        const result = { physicsShield: 0, magicShield: 0 };
        [1, 2, 3, 4, 5, 6].map(key => [rawEquip[`Base${key}Type`], rawEquip[`Base${key}Min`], rawEquip[`Base${key}Max`]])
            .forEach(([key, min, max]) => {
                if (key === 'atPhysicsShieldBase') {
                    result.physicsShield = +min;
                }
                if (key === 'atMagicShield') {
                    result.magicShield = +min;
                }
            });
        return result;
    },

    getAttribute(rawEquip, attriTab) {
        const attributes = ['body','spirit','strength','agility','spunk','physicsShield','magicShield','dodge','parryBase','parryValue','toughness','attack','heal','crit','critEffect','overcome','acce','hit','strain','huajing','threat'];
        const result = attributes.reduce((acc, cur) => {acc[cur] = 0; return acc;}, {});
        Array.from({length: 12}).map((key, i) => rawEquip[`Magic${i + 1}Type`])
            .forEach((id) => {
                const attribute = attriTab[id];
                if (attribute) {
                    const key = attribute.ModifyType;
                    if (attributeKeyMap[key]) {
                        result[attributeKeyMap[key]] += +attribute.Param1Min;
                    }
                }
            });
        return result;
    }
};
