const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');
const { getMenpai, getXinfaType, getEquipType, getEquipScore, getBasicInfo, getAttribute } = require('./util');

console.log('init');

const flags = { armor: 0, trinket: 0, weapon: 0, attrib: 0, set: 0 };
const keys = { armor: [], trinket: [], weapon: [], attrib: [], set: [] };
const tabs = { armor: [], trinket: [], weapon: [], attrib: {}, set: {} };

function readCsvFile(file, key, isObj, callback) {
    console.time(`reading ${key}`);
    fs.createReadStream(file)
        .pipe(iconv.decodeStream('gb2312'))
        .pipe(iconv.encodeStream('utf8'))
        .pipe(parse({ delimiter: '\t' }))
        .on('data', function(row) {
            if (flags[key] === 0) {
                // 读取第一行
                flags[key] += 1;
                keys[key] = row;
            } else {
                const item = row.reduce((acc, cur, i) => {
                    const keyName = keys[key][i];
                    acc[keyName] = cur;
                    return acc;
                }, {});
                if (isObj) {
                    tabs[key][item.ID] = item;
                } else {
                    tabs[key].push(item);
                }
            }
        })
        .on('end',function() {
            console.timeEnd(`reading ${key}`);
            callback(key);
        });
}

function parseEquip(rawEquip) {
    const { UiID, Name, ID, Level, MaxStrengthLevel } = rawEquip;
    const equip = { uiId: UiID, name: Name, originalId: ID, quality: +Level, strengthen: +MaxStrengthLevel };
    equip.menpai = getMenpai(rawEquip.BelongSchool);
    equip.xinfatype = getXinfaType(rawEquip.MagicKind, equip.menpai);
    if (equip.xinfatype > 5 && equip.menpai === 1) {
        // 治疗或防御装备
        equip.menpai =  0;
    }
    equip.type = getEquipType(rawEquip.SubType);
    equip.score = getEquipScore(Level, rawEquip.SubType, MaxStrengthLevel);
    const basicInfo = getBasicInfo(rawEquip);
    equip.basicPhysicsShield = basicInfo.physicsShield;
    equip.basicMagicShield = basicInfo.magicShield;
    const attributes = getAttribute(rawEquip, tabs.attrib);
    Object.assign(equip, attributes);
    return equip;
}

function parseTab(tab, key) {
    const newTab = tab.map(parseEquip);
    console.log(newTab[43258]);
    console.log(newTab[42116]);
    console.log(newTab[42117]);
}

function readCallback(key) {
    flags[key] += 1;
    const sum = Object.values(flags).reduce((acc, cur) => acc + cur, 0);
    if (sum === 6) {
        // 全部读取完成后，启动解析器
        console.log('init finished');
        const equipTabs = ['armor'];
        equipTabs.forEach(key => {
            const tab = tabs[key];
            parseTab(tab, key);
        });
    }
}

readCsvFile('./raw/Custom_Armor.tab', 'armor', false, readCallback);
// readCsvFile('./raw/Custom_Trinket.tab', 'trinket', false, readCallback);
// readCsvFile('./raw/Custom_Weapon.tab', 'weapon', false, readCallback);
readCsvFile('./raw/Attrib.tab', 'attrib', true, readCallback);
readCsvFile('./raw/Set.tab', 'set', true, readCallback);

