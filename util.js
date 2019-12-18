const menpaiList = ['通用', '精简', '万花', '少林', '唐门', '明教', '七秀', '五毒', '纯阳', '天策', '丐帮', '藏剑', '苍云', '长歌', '霸刀', '蓬莱', '凌雪'];
const xinfaType = ['内功', '外功', '元气', '根骨', '力道', '身法', '治疗', '防御'];

const spunkXinfa = ['万花', '少林', '唐门', '明教'];
const spiritXinfa = ['七秀', '五毒', '纯阳', '长歌'];
const strengthXinfa = ['唐门', '天策', '丐帮', '霸刀'];
const agilityXinfa = ['纯阳', '藏剑', '苍云', '蓬莱', '凌雪'];

const typeMap = {
    0: [11, 1.2, '武器'],
    1: [4, 0.6, '暗器'],
    4: [0, 0.5, '项链'],
    5: [2, 0.5, '戒指'],
    7: [1, 0.5, '腰坠'],
    2: [8, 1, '上衣'],
    3: [9, 0.9, '帽子'],
    6: [10, 0.7, '腰带'],
    8: [7, 1, '下装'],
    9: [5, 0.7, '鞋子'],
    10: [6, 0.7, '护腕'],
}
const enchantTypeMap = {
    上装: 8,
    上衣: 8,
    腰带: 10,
    下装: 7,
    项链: 0,
    武器: 11,
    手: 6,
    护手: 6,
    护腕: 6,
    头部: 9,
    帽子: 9,
    戒指: 2,
    暗器: 4,
    鞋子: 5,
    腰坠: 1,
}
// atSetEquipmentRecipe	event
// atSkillEventHandler	texiao	特效
const attributeKeyMap = {
    atActiveThreatCoefficient: ['threat', '47', '技能威胁提高', 1], // 威胁
    atAddSprintPowerMax: ['sprint', '999', '气力值上限提高', 100], // 气力值上限
    atAgilityBase: ['agility', '04', '身法提高', 1], // 身法
    atAllTypeCriticalDamagePowerBase: ['critEffect', '38', '全会心效果等级提高', 1], // 会效
    atAllTypeCriticalStrike: ['crit', '37', '全会心等级提高', 1], // 会心
    atAllTypeHitValue: ['hit', '36', '全命中等级提高', 1], // 命中
    atBasePotentialAdd: ['body/spirit/strength/agility/spunk', '999', '全属性提高', 1], // 全属性
    atDecriticalDamagePowerBase: ['huajing', '52', '化劲等级提高', 1], // 化劲
    atDodge: ['dodge', '45', '闪避等级提高', 1], // 闪避
    atHasteBase: ['acce', '51', '加速等级提高', 1], // 加速
    atLifeReplenishExt: ['xuehui', '05', '每秒气血回复提高', 1], // 回血
    atLunarAttackPowerBase: ['attack', '15', '阴性攻击提高', 1], // 阴性攻击
    atLunarCriticalDamagePowerBase: ['critEffect', '25', '阴性会心效果等级提高', 1], // 会效
    atLunarCriticalStrike: ['crit', '07', '阴性会心等级提高', 1], // 会心
    atLunarHitValue: ['hit', '54', '阴性命中等级提高', 1], // 阴性命中
    atLunarOvercomeBase: ['overcome', '14', '阴性破防等级提高', 1], // 阴性破防
    atMagicAttackPowerBase: ['attack', '40', '内功攻击提高', 1], // 内功攻击
    atMagicCriticalDamagePowerBase: ['critEffect', '31', '内功会心效果等级提高', 1], // 会效
    atMagicCriticalStrike: ['crit', '10', '内功会心等级提高', 1], // 会心
    atMagicHitValue: ['hit', '20', '内功命中等级提高', 1], // 内功命中
    atMagicOvercome: ['overcome', '27', '内功破防等级提高', 1], // 内功破防
    atMagicShield: ['magicShield', '43', '内功防御等级提高', 1], // 内防
    atManaReplenishExt: ['neihui', '48', '每秒内力回复提高', 1], // 回蓝
    atMaxLifeAdditional: ['qixue', '39', '最大气血提高', 1], // 气血
    atMaxLifeBase: ['qixue', '39', '最大气血提高', 1], // 气血
    atMaxManaAdditional: ['neili', '49', '最大内力提高', 1], // 内力
    atMaxManaBase: ['neili', '49', '最大内力提高', 1], // 内力
    atMeleeWeaponDamageBase: [null, '999', '武器伤害提高', 1], // 武器伤害
    atMoveSpeedPercent: [null, '999', '移动速度提高', 1], // 移动速度
    atNeutralAttackPowerBase: ['attack', '16', '混元攻击提高', 1], // 混元攻击
    atNeutralCriticalDamagePowerBase: ['critEffect', '24', '混元会心效果等级提高', 1], // 会效
    atNeutralCriticalStrike: ['crit', '23', '混元会心等级提高', 1], // 会心
    atNeutralHitValue: ['hit', '50', '混元命中等级提高', 1], // 混元命中
    atNeutralOvercomeBase: ['overcome', '13', '混元破防等级提高', 1], // 混元破防
    atParryBase: ['parryBase', '46', '招架等级提高', 1], // 招架
    atParryValueBase: ['parryValue', '44', '拆招等级提高', 1], // 拆招
    atPhysicsAttackPowerBase: ['attack', '08', '外功攻击提高', 1], // 外功攻击
    atPhysicsCriticalDamagePowerBase: ['critEffect', '21', '外功会心效果等级提高', 1], // 会效
    atPhysicsCriticalStrike: ['crit', '06', '外功会心等级提高', 1], // 会心
    atPhysicsHitValue: ['hit', '09', '外功命中等级提高', 1], // 外功命中
    atPhysicsOvercomeBase: ['overcome', '18', '外功破防等级提高', 1], // 外功破防
    atPhysicsShieldAdditional: ['physicsShield', '42', '外功防御等级提高', 1], // 外防
    atPhysicsShieldBase: ['physicsShield', '42', '外功防御等级提高', 1], // 外防
    atPoisonAttackPowerBase: ['attack', '22', '毒性攻击提高', 1], // 毒性攻击
    atPoisonCriticalDamagePowerBase: ['critEffect', '30', '毒性会心效果等级提高', 1], // 会效
    atPoisonCriticalStrike: ['crit', '29', '毒性会心等级提高', 1], // 会心
    atPoisonHitValue: ['hit', '57', '毒性命中等级提高', 1], // 毒性命中
    atPoisonOvercomeBase: ['overcome', '28', '毒性破防等级提高', 1], // 毒性破防
    atSolarAndLunarAttackPowerBase: ['attack', '33', '阴阳攻击提高', 1], // 阴阳攻击
    atSolarAndLunarCriticalDamagePowerBase: ['critEffect', '34', '阴阳会心效果等级提高', 1], // 会效
    atSolarAndLunarCriticalStrike: ['crit', '35', '阴阳会心等级提高', 1], // 会心
    atSolarAndLunarHitValue: ['hit', '56', '阴阳命中等级提高', 1], // 阴阳命中
    atSolarAndLunarOvercomeBase: ['overcome', '32', '阴阳破防等级提高', 1], // 阴阳破防
    atSolarAttackPowerBase: ['attack', '19', '阳性攻击提高', 1], // 阳性攻击
    atSolarCriticalDamagePowerBase: ['critEffect', '26', '阳性会心效果等级提高', 1], // 会效
    atSolarCriticalStrike: ['crit', '17', '阳性会心等级提高', 1], // 会心
    atSolarHitValue: ['hit', '53', '阳性命中等级提高', 1], // 阳性命中
    atSolarOvercomeBase: ['overcome', '12', '阳性破防等级提高', 1], // 阳性破防
    atSpiritBase: ['spirit', '00', '根骨提高', 1], // 根骨
    atSpunkBase: ['spunk', '01', '元气提高', 1], // 元气
    atStrainBase: ['strain', '11', '无双等级提高', 1], // 无双
    atStrengthBase: ['strength', '02', '力道提高', 1], // 力道
    atTherapyPowerBase: ['heal', '41', '治疗量提高', 1], // 治疗
    atToughnessBase: ['toughness', '55', '御劲等级提高', 1], // 御劲
    atVitalityBase: ['body', '03', '体质提高', 1], // 体质
};

module.exports = {
    getMenpai(rawText) {
        return global.options.readable ? rawText : menpaiList.indexOf(rawText);
    },

    getXinfaType(rawText, menpai) {
        const xinfa = xinfaType.indexOf(rawText);
        if (xinfa === 0 && menpai > 1) {
            if (spunkXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return global.options.readable ? '元气' : 2;
            }
            if (spiritXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return global.options.readable ? '根骨' : 3;
            }
        }
        if (xinfa === 1 && menpai > 1) {
            if (strengthXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return global.options.readable ? '力道' : 4;
            }
            if (agilityXinfa.indexOf(menpaiList[menpai]) >= 0) {
                return global.options.readable ? '身法' : 5;
            }
        }
        return global.options.readable ? rawText : xinfa;
    },

    getEquipType(subType, detailType) {
        if (typeMap[subType]) {
            const type = typeMap[subType][global.options.readable ? 2 : 0];
            if (type == (global.options.readable ? '武器' : 11) && detailType == '9') {
                return global.options.readable ? '重剑' : 12;
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
        const result = { basicPhysicsShield: 0, basicMagicShield: 0, damageBase: 0, damageRange: 0, attackSpeed: 0 };
        [1, 2, 3, 4, 5, 6].map(key => [rawEquip[`Base${key}Type`], rawEquip[`Base${key}Min`], rawEquip[`Base${key}Max`]])
            .forEach(([key, min, max]) => {
                if (key === 'atPhysicsShieldBase') {
                    result.basicPhysicsShield = +min;
                }
                if (key === 'atMagicShield') {
                    result.basicMagicShield = +min;
                }
                if (key === 'atMeleeWeaponDamageBase') {
                    result.damageBase = +min;
                }
                if (key === 'atMeleeWeaponDamageRand') {
                    result.damageRange = +min;
                }
                if (key === 'atMeleeWeaponAttackSpeedBase') {
                    result.attackSpeed = +min;
                }
            });
        return result;
    },

    getAttribute(rawEquip, attriTab, recipeTab, eventTab, setTab) {
        const attributes = ['body','spirit','strength','agility','spunk','physicsShield','magicShield','dodge','parryBase','parryValue','toughness','attack','heal','crit','critEffect','overcome','acce','hit','strain','huajing','threat'];
        const result = attributes.reduce((acc, cur) => {acc[cur] = 0; return acc;}, {});
        let texiao = [];
        let eventId = [];
        let hasSet = false;
        const setObj = { effects: {} };
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
                    } else if (key === 'atSkillEventHandler') {
                        // console.log(`Unknown equip attribute ${key}=${attribute.Param1Min} at ID=${rawEquip.ID}, Name=${rawEquip.Name}`);
                        // result.texiao = attribute.Param1Min;
                        const event = eventTab[attribute.Param1Min];
                        if (event) {
                            eventId.push(attribute.Param1Min);
                            const regarr = /"(.*)"/.exec(event.Desc.replace('\n', ''));
                            if (regarr) {
                                texiao.push(regarr[1].replace(/\\/g, ''));
                            }
                        }
                    } else if (key === 'atSetEquipmentRecipe') {
                        const event = recipeTab[`${attribute.Param1Min}-${attribute.Param2Min}`];
                        if (event) {
                            eventId.push(attribute.Param1Min);
                            const regarr = /"(.*)"/.exec(event.Desc.replace('\n', ''));
                            if (regarr) {
                                texiao.push(regarr[1].replace(/\\/g, ''));
                            }
                        }
                    }
                } catch (e) {
                    console.error(`Equip attributes parse error at ID=${rawEquip.ID}, Name=${rawEquip.Name}, Type=${rawEquip.SubType}`);
                }
            });
        if (rawEquip.SetID > 0) {
            const setInfo = setTab[rawEquip.SetID];
            if (setInfo) {
                setObj.id = setInfo.ID;
                setObj.name = setInfo.Name;
                Array.from({ length: 3 }).map((key, i) => ({
                    i: i + 2,
                    ids: [setInfo[`${i + 2}_1`], setInfo[`${i + 2}_2`]],
                })).forEach(({i, ids}) => {
                    setObj.effects[i] = [];
                    ids.forEach(id => {
                        const attribute = attriTab[id];
                        if (!id) {
                            return;
                        }
                        try {
                            const key = attribute.ModifyType;
                            let value;
                            if (attributeKeyMap[key] && attributeKeyMap[key][0]) {
                                if (key === 'atActiveThreatCoefficient') {
                                    value = +attribute.Param2Min;
                                } else {
                                    value = +attribute.Param1Min;
                                }
                                value /=  attributeKeyMap[key][3];
                                setObj.effects[i].push([key, value, attributeKeyMap[key][0], attributeKeyMap[key][2]]);
                                hasSet = true;
                            } else if (key === 'atSkillEventHandler') {
                                const event = eventTab[attribute.Param1Min];
                                if (event) {
                                    const regarr = /"(.*)"/.exec(event.Desc.replace('\n', ''));
                                    if (regarr) {
                                        value = regarr[1].replace(/\\/g, '');
                                        setObj.effects[i].push([key, value]);
                                    }
                                }
                            } else if (key === 'atSetEquipmentRecipe') {
                                const event = recipeTab[`${attribute.Param1Min}-${attribute.Param2Min}`];
                                hasSet = true;
                                if (event) {
                                    const regarr = /"(.*)"/.exec(event.Desc.replace('\n', ''));
                                    if (regarr) {
                                        value = regarr[1].replace(/\\/g, '');
                                        setObj.effects[i].push([key, value]);
                                    }
                                }
                            }
                        } catch (e) {
                            console.error(`Set attributes parse error at ID=${rawEquip.ID}, Name=${rawEquip.Name}, id=${id}`);
                        }
                    })
                });
            }
        }
        const ret = { attributes: result };
        if (eventId.length > 0) {
            ret.event = { desc: texiao, id: eventId };
        }
        if (hasSet) {
            ret.set = setObj;
        }
        if (rawEquip.SkillID && rawEquip.SkillLevel) {
            ret.skill = {
                id: `${rawEquip.SkillID}-${rawEquip.SkillLevel}`,
                desc: '使用：获得风特效',
            };
        }
        return ret;
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
    },

    getDropSource(equipId, db, mapList) {
        const info = db[equipId];
        const ret = [];
        if (info && info.GetType) {
            const types = info.GetType.split(',');
            const desc = info.Get_Desc.split('},{').map(v => v.replace(/[{}]/g, ''));
            types.forEach((type, i) => {
                const dropInfo = {};
                if (type === '副本') {
                    const mapBossArray = desc[i].split('],[').map(v => v.replace(/[\[\]]/g, '').split(','));
                    const mapArray = info.BelongMapID.split(',');
                    dropInfo.type = type;
                    dropInfo.desc = '';
                    mapArray.map((mapId, j) => {
                        const mapName = mapList[mapId] ? mapList[mapId].DisplayName : '未知';
                        const bosses = mapBossArray[j] ? mapBossArray[j].join(', ') : mapBossArray[j - 1].join(', ');
                        return  [mapId, `/${type}·${mapName.replace('_', '·')}: ${bosses}`];
                    }).sort((a, b) => b[0] - a[0]).forEach(([mapId, desc]) => {
                        dropInfo.desc += desc;
                    })
                } else if (type === '掉落' || type === '地图掉落') {
                    dropInfo.type = '掉落';
                    dropInfo.desc = `/掉落: ${desc}`.replace(/[\[\]]/g, '');
                } else if (type === '声望') {
                    dropInfo.type = type;
                    dropInfo.desc = `/声望:${info.Get_Force}(${info.PrestigeRequire})`;
                }
                if (dropInfo.desc && dropInfo.desc.startsWith('/')) {
                    dropInfo.desc = dropInfo.desc.substr(1);
                }
                if (dropInfo.type) {
                    ret.push(dropInfo);
                }
            });
        }
        return ret.map(v => `/${v.desc}`).join('/');
    },

    getEnchantType(type) {
        const value = enchantTypeMap[type];
        if (value !== undefined) return value;
        return 999;
    },

    getEnchantAttributes(rawEnchant) {
        const key = rawEnchant.Attribute1ID;
        let value;
        if (attributeKeyMap[key] && attributeKeyMap[key][0]) {
            if (key === 'atActiveThreatCoefficient') {
                value = +rawEnchant.Attribute1Value2;
            } else {
                value = +rawEnchant.Attribute1Value1;
            }
            return { [attributeKeyMap[key][0]]: value };
        }
        return {};
    },

    getEnchantXinfaType(desc) {
        if (desc.indexOf('内功会心') >= 0 || desc.indexOf('内功命中') >= 0) {
            // 通用内功
            return 0;
        }
        if (desc.indexOf('外功攻击') >= 0 || desc.indexOf('外功破防') >= 0) {
            // 通用外功
            return 1;
        }
        if (desc.indexOf('元气') >= 0) {
            // 元气
            return 2;
        }
        if (desc.indexOf('根骨') >= 0) {
            // 根骨
            return 3;
        }
        if (desc.indexOf('力道') >= 0) {
            // 力道
            return 4;
        }
        if (desc.indexOf('身法') >= 0) {
            // 身法
            return 5;
        }
        if (desc.indexOf('疗') >= 0) {
            // 治疗
            return 6;
        }
        if (desc.indexOf('防御') >= 0 || desc.indexOf('招架') >= 0 || desc.indexOf('闪避') >= 0 || desc.indexOf('拆招') >= 0 || desc.indexOf('仇恨') >= 0 || desc.indexOf('威胁提高') >= 0) {
            // 防御
            return 7;
        }
        if (desc.indexOf('内功攻击') >= 0 || desc.indexOf('内功破防') >= 0) {
            // 田螺
            return 8;
        }
        if (desc.indexOf('外功会心') >= 0 || desc.indexOf('外功命中') >= 0) {
            // 田螺
            return 9;
        }
        return 10;
    },

    getCommonName(names) {
        let longestSubstring = '';
        let isSame = true;
        const processingNames = names.map(name => [...name]);
        while(isSame) {
            let pre = '';
            processingNames.forEach((name, i) => {
                const c = name.shift();
                if (i === 0) {
                    pre = c;
                } else if (c !== pre) {
                    isSame = false;
                }
            });
            if (isSame) {
                longestSubstring += pre;
            }
            if (pre === undefined) {
                break;
            }
        }

        return longestSubstring;
    }
};
