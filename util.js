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
    atActiveThreatCoefficient: ['threat', '47'], // 威胁
    atAgilityBase: ['agility', '04'], // 身法
    atAllTypeCriticalDamagePowerBase: ['critEffect', '38'], // 会效
    atAllTypeCriticalStrike: ['crit', '37'], // 会心
    atAllTypeHitValue: ['hit', '36'], // 命中
    atDecriticalDamagePowerBase: ['huajing', '52'], // 化劲
    atDodge: ['dodge', '45'], // 闪避
    atHasteBase: ['acce', '51'], // 加速
    atLifeReplenishExt: [null, '05'], // 回血
    atLunarAttackPowerBase: ['attack', '15'], // 阴性攻击
    atLunarCriticalDamagePowerBase: ['critEffect', '25'], // 会效
    atLunarCriticalStrike: ['crit', '07'], // 会心
    atLunarHitValue: ['hit', '54'], // 阴性命中
    atLunarOvercomeBase: ['overcome', '14'], // 阴性破防
    atMagicAttackPowerBase: ['attack', '40'], // 内功攻击
    atMagicCriticalDamagePowerBase: ['critEffect', '31'], // 会效
    atMagicCriticalStrike: ['crit', '10'], // 会心
    atMagicHitValue: ['hit', '20'], // 内功命中
    atMagicOvercome: ['overcome', '27'], // 内功破防
    atMagicShield: ['magicShield', '43'], // 内防
    atManaReplenishExt: [null, '48'], // 回蓝
    atMaxLifeAdditional: [null, '39'], // 气血
    atMaxManaAdditional: [null, '49'], // 内力
    atNeutralAttackPowerBase: ['attack', '16'], // 混元攻击
    atNeutralCriticalDamagePowerBase: ['critEffect', '24'], // 会效
    atNeutralCriticalStrike: ['crit', '23'], // 会心
    atNeutralHitValue: ['hit', '50'], // 混元命中
    atNeutralOvercomeBase: ['overcome', '13'], // 混元破防
    atParryBase: ['parryBase', '46'], // 招架
    atParryValueBase: ['parryValue', '44'], // 拆招
    atPhysicsAttackPowerBase: ['attack', '08'], // 外功攻击
    atPhysicsCriticalDamagePowerBase: ['critEffect', '21'], // 会效
    atPhysicsCriticalStrike: ['crit', '06'], // 会心
    atPhysicsHitValue: ['hit', '09'], // 外功命中
    atPhysicsOvercomeBase: ['overcome', '18'], // 外功破防
    atPhysicsShieldAdditional: ['physicsShield', '42'], // 外防
    atPhysicsShieldBase: ['physicsShield', '42'], // 外防
    atPoisonAttackPowerBase: ['attack', '22'], // 毒性攻击
    atPoisonCriticalDamagePowerBase: ['critEffect', '30'], // 会效
    atPoisonCriticalStrike: ['crit', '29'], // 会心
    atPoisonHitValue: ['hit', '57'], // 毒性命中
    atPoisonOvercomeBase: ['overcome', '28'], // 毒性破防
    atSolarAndLunarAttackPowerBase: ['attack', '33'], // 阴阳攻击
    atSolarAndLunarCriticalDamagePowerBase: ['critEffect', '34'], // 会效
    atSolarAndLunarCriticalStrike: ['crit', '35'], // 会心
    atSolarAndLunarHitValue: ['hit', '56'], // 阴阳命中
    atSolarAndLunarOvercomeBase: ['overcome', '32'], // 阴阳破防
    atSolarAttackPowerBase: ['attack', '19'], // 阳性攻击
    atSolarCriticalDamagePowerBase: ['critEffect', '26'], // 会效
    atSolarCriticalStrike: ['crit', '17'], // 会心
    atSolarHitValue: ['hit', '53'], // 阳性命中
    atSolarOvercomeBase: ['overcome', '12'], // 阳性破防
    atSpiritBase: ['spirit', '00'], // 根骨
    atSpunkBase: ['spunk', '01'], // 元气
    atStrainBase: ['strain', '11'], // 无双
    atStrengthBase: ['strength', '02'], // 力道
    atTherapyPowerBase: ['heal', '41'], // 治疗
    atToughnessBase: ['toughness', '55'], // 御劲
    atVitalityBase: ['body', '03'], // 体质
};

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
        if (typeMap[subType]) {
            const type = typeMap[subType][0];
            if (type === 0 && detailType == '9') {
                // 重剑
                return 12;
            }
            return type;
        }
        return -1;
    },

    getEquipScore(quality, subType, sthengthen) {
        if (typeMap[subType]) {
            let cof = 1.8;
            if (sthengthen > 6) {
                cof = 2.5;
            }
            return Math.floor(quality * cof * typeMap[subType][1]);
        }
        return 0;
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
        Array.from({ length: 12 }).map((key, i) => rawEquip[`Magic${i + 1}Type`])
            .forEach((id) => {
                const attribute = attriTab[id];
                try {
                    const key = attribute.ModifyType;
                    if (attributeKeyMap[key] && attributeKeyMap[key][0]) {
                        if (key === 'atActiveThreatCoefficient') {
                            result[attributeKeyMap[key][0]] += +attribute.Param2Min;
                        } else {
                            result[attributeKeyMap[key][0]] += +attribute.Param1Min;
                        }
                    }
                } catch (e) {
                    console.error(`Equip attributes parse error at ID=${rawEquip.ID}, Name=${rawEquip.Name}`);
                }
            });
        return result;
    },

    getEmbed(rawEquip, attriTab) {
        const result = {
            count: 0,
            attrib: [],
        }
        Array.from({ length: 3 }).map((key, i) => [rawEquip[`DiamondTypeMask${i + 1}`], rawEquip[`DiamondAttributeID${i + 1}`]])
            .forEach(([mask, id]) => {
                if (mask > 0 && id > 0) {
                    const attribute = attriTab[id];
                    try {
                        const key = attribute.ModifyType;
                        result.count += 1;
                        result.attrib.push(attributeKeyMap[key][1])
                    } catch (e) {
                        console.error(`Equip embed info parse error at ID=${rawEquip.ID}, Name=${rawEquip.Name}`);
                    }
                }
            });
        if (result.count === 0) return '';
        return `${result.count}D${result.attrib.join('D')}`;
    }
};
