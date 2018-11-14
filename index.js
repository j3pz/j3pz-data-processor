const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const { getMenpai, getXinfaType, getEquipType, getEquipScore, getBasicInfo, getAttribute, getEmbed } = require('./util');

console.log('init');
const headers = [
    { id: 'uiId', title: 'uiId'}, 
    { id: 'iconID', title: 'iconID'}, 
    { id: 'name', title: 'name'}, 
    { id: 'menpai', title: 'menpai'}, 
    { id: 'xinfa', title: 'xinfa'}, 
    { id: 'type', title: 'type'}, 
    { id: 'quality', title: 'quality'}, 
    { id: 'score', title: 'score'}, 
    { id: 'body', title: 'body'}, 
    { id: 'spirit', title: 'spirit'}, 
    { id: 'strength', title: 'strength'}, 
    { id: 'agility', title: 'agility'}, 
    { id: 'spunk', title: 'spunk'}, 
    { id: 'basicPhysicsShield', title: 'basicPhysicsShield'}, 
    { id: 'basicMagicShield', title: 'basicMagicShield'}, 
    { id: 'physicsShield', title: 'physicsShield'}, 
    { id: 'magicShield', title: 'magicShield'}, 
    { id: 'dodge', title: 'dodge'}, 
    { id: 'parryBase', title: 'parryBase'}, 
    { id: 'parryValue', title: 'parryValue'}, 
    { id: 'toughness', title: 'toughness'}, 
    { id: 'attack', title: 'attack'}, 
    { id: 'heal', title: 'heal'}, 
    { id: 'crit', title: 'crit'}, 
    { id: 'critEffect', title: 'critEffect'}, 
    { id: 'overcome', title: 'overcome'}, 
    { id: 'acce', title: 'acce'}, 
    { id: 'hit', title: 'hit'}, 
    { id: 'strain', title: 'strain'}, 
    { id: 'huajing', title: 'huajing'}, 
    { id: 'threat', title: 'threat'}, 
    { id: 'texiao', title: 'texiao'}, 
    { id: 'xiangqian', title: 'xiangqian'}, 
    { id: 'strengthen', title: 'strengthen'}, 
    { id: 'dropSource', title: 'dropSource'}, 
    // { id: 'set', title: 'set'}, 
    // { id: 'originalId', title: 'originalId'}, 
];

const flags = { armor: 0, trinket: 0, weapon: 0, attrib: 0, set: 0, id: 0 };
const keys = { armor: [], trinket: [], weapon: [], attrib: [], set: [], id: [] };
const tabs = { armor: [], trinket: [], weapon: [], attrib: {}, set: {}, id: {} };

let maxId = 32276;

function readCsvFile(file, key, isObj, callback) {
    console.time(`reading ${key}`);
    fs.createReadStream(file)
        .pipe(iconv.decodeStream('gb2312'))
        .pipe(iconv.encodeStream('utf8'))
        .pipe(parse({ delimiter: key === 'id' ? ',' : '\t' }))
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
                    if (key === 'id' && item.databaseId > maxId) {
                        maxId = item;
                    }
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

function parseEquip(rawEquip, key) {
    const { UiID, Name, ID, Level, MaxStrengthLevel } = rawEquip;
    const equip = { uiId: UiID, name: Name, originalId: `${key}-${ID}`, quality: +Level, strengthen: +MaxStrengthLevel, iconID: 99999 };
    equip.menpai = getMenpai(rawEquip.BelongSchool);
    equip.xinfa = getXinfaType(rawEquip.MagicKind, equip.menpai);
    if (equip.xinfa > 5 && equip.menpai === 1) {
        // 治疗或防御装备
        equip.menpai =  0;
    }
    equip.type = getEquipType(rawEquip.SubType, rawEquip.DetailType);
    equip.score = getEquipScore(Level, rawEquip.SubType, MaxStrengthLevel);
    const basicInfo = getBasicInfo(rawEquip);
    equip.basicPhysicsShield = basicInfo.physicsShield;
    equip.basicMagicShield = basicInfo.magicShield;
    const attributes = getAttribute(rawEquip, tabs.attrib);
    Object.assign(equip, attributes);
    equip.xiangqian = getEmbed(rawEquip, tabs.attrib);
    equip.dropSource = rawEquip.GetType;
    return equip;
}

function parseTab(tab, key, callback) {
    const newTab = tab.filter((rawEquip) => {
        if (rawEquip.SubType > 10 || rawEquip.Quality < 4 || rawEquip.Magic1Type === '' || rawEquip.Level < 1000) return false;
        if (rawEquip.Require1Value < 95) return false;
        if (key === 'armor' && rawEquip.ID < 41042) return false;
        if (key === 'trinket' && rawEquip.ID < 23441) return false;
        if (key === 'weapon' && rawEquip.ID < 18631) return false;
        return true;
    }).map((rawEquip) => parseEquip(rawEquip, key));
    // console.table([newTab[42116], newTab[43258], newTab[43004]]);
    const csvWriter = createCsvWriter({
        path: `./output/${key}.csv`,
        header: [ ...headers, /* { id: 'set', title: 'set'}, */ { id: 'originalId', title: 'originalId'} ],
    });
    csvWriter.writeRecords(newTab).then(() => {
        console.log(`output ${key} done`);
        callback(newTab);
    });
}

function readCallback(key) {
    flags[key] += 1;
    const sum = Object.values(flags).reduce((acc, cur) => acc + cur, 0);
    if (sum === 12) {
        // 全部读取完成后，启动解析器
        console.log('init finished');
        let count = 0;
        let result = [];
        const equipTabs = ['armor', 'trinket', 'weapon'];

        function generateUpdatePack(newTab) {
            result = result.concat(newTab);
            count += 1;
            if (count === equipTabs.length) {
                const idMap = [];
                let countNew = 0;
                const pack = result.map((equip, i) => {
                    let id = tabs.id[equip.originalId];
                    if (!id) {
                        countNew += 1;
                        id = maxId + countNew;
                    }
                    idMap.push({ ID: equip.originalId, databaseId: id });
                    return { ...equip, id };
                });
                const csvWriter = createCsvWriter({
                    path: './output/equips.csv',
                    header: [{ id: 'id', title: 'P_ID'}, ...headers],
                });
                const idMapWriter = createCsvWriter({
                    path: './output/originalId.tab',
                    header: [{ id: 'ID', title: 'ID' }, { id: 'databaseId', title: 'databaseId' }],
                });
                csvWriter.writeRecords(pack).then(() => {
                    return idMapWriter.writeRecords(idMap);
                }).then(() => {
                    console.log(`output all result done`);
                });
            }
        }
        equipTabs.forEach(key => {
            const tab = tabs[key];
            parseTab(tab, key, generateUpdatePack);
        });
    }
}

readCsvFile('./raw/Custom_Armor.tab', 'armor', false, readCallback);
readCsvFile('./raw/Custom_Trinket.tab', 'trinket', false, readCallback);
readCsvFile('./raw/Custom_Weapon.tab', 'weapon', false, readCallback);
readCsvFile('./raw/Attrib.tab', 'attrib', true, readCallback);
readCsvFile('./raw/Set.tab', 'set', true, readCallback);
readCsvFile('./output/originalId.tab', 'id', true, readCallback);
