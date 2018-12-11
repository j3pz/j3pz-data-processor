const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const { getMenpai, getXinfaType, getEquipType, getEquipScore, getBasicInfo, getAttribute, getEmbed } = require('./util');

global.options = {
    readable: false, // --readable
    'allow-lagacy': false, // --allow-lagacy
}
global.command = 'equip';

function processArguments() {
    const args = process.argv;
    const optionsArray = args.slice(2); // remove node index
    optionsArray.forEach(v => {
        if (v.indexOf('--') === 0) {
            // option
            const optionString = v.slice(2);
            const optionValue = optionString.split('=')
            const key = optionValue[0];
            const value = optionValue[1] || true;
            options[key] = value;
        } else {
            global.command = v;
        }
    });
}
processArguments();

if (global.command === 'equip') {
    console.log('=====parse equips=====');
    console.log('=========init=========');
    const headers = [
        { id: 'uiId', title: 'uiId'}, 
        { id: 'iconID', title: global.options.readable ? '图标' : 'iconID'}, 
        { id: 'name', title: global.options.readable ? '名称' : 'name'}, 
        { id: 'menpai', title: global.options.readable ? '门派' : 'menpai'}, 
        { id: 'xinfa', title: global.options.readable ? '心法类型' : 'xinfa'}, 
        { id: 'type', title: global.options.readable ? '装备类型' : 'type'}, 
        { id: 'quality', title: global.options.readable ? '品质' : 'quality'}, 
        { id: 'score', title: global.options.readable ? '分数' : 'score'}, 
        { id: 'body', title: global.options.readable ? '体质' : 'body'}, 
        { id: 'spirit', title: global.options.readable ? '根骨' : 'spirit'}, 
        { id: 'strength', title: global.options.readable ? '力道' : 'strength'}, 
        { id: 'agility', title: global.options.readable ? '身法' : 'agility'}, 
        { id: 'spunk', title: global.options.readable ? '元气' : 'spunk'}, 
        { id: 'basicPhysicsShield', title: global.options.readable ? '基础外防' : 'basicPhysicsShield'}, 
        { id: 'basicMagicShield', title: global.options.readable ? '基础内防' : 'basicMagicShield'}, 
        { id: 'physicsShield', title: global.options.readable ? '外防' : 'physicsShield'}, 
        { id: 'magicShield', title: global.options.readable ? '内防' : 'magicShield'}, 
        { id: 'dodge', title: global.options.readable ? '闪避' : 'dodge'}, 
        { id: 'parryBase', title: global.options.readable ? '招架' : 'parryBase'}, 
        { id: 'parryValue', title: global.options.readable ? '拆招' : 'parryValue'}, 
        { id: 'toughness', title: global.options.readable ? '御劲' : 'toughness'}, 
        { id: 'attack', title: global.options.readable ? '攻击' : 'attack'}, 
        { id: 'heal', title: global.options.readable ? '治疗' : 'heal'}, 
        { id: 'crit', title: global.options.readable ? '会心' : 'crit'}, 
        { id: 'critEffect', title: global.options.readable ? '会效' : 'critEffect'}, 
        { id: 'overcome', title: global.options.readable ? '破防' : 'overcome'}, 
        { id: 'acce', title: global.options.readable ? '加速' : 'acce'}, 
        { id: 'hit', title: global.options.readable ? '命中' : 'hit'}, 
        { id: 'strain', title: global.options.readable ? '无双' : 'strain'}, 
        { id: 'huajing', title: global.options.readable ? '化劲' : 'huajing'}, 
        { id: 'threat', title: global.options.readable ? '威胁' : 'threat'}, 
        { id: 'texiao', title: global.options.readable ? '特效' : 'texiao'}, 
        { id: 'xiangqian', title: global.options.readable ? '镶嵌' : 'xiangqian'}, 
        { id: 'strengthen', title: global.options.readable ? '可精炼等级' : 'strengthen'}, 
        { id: 'dropSource', title: global.options.readable ? '掉落来源' : 'dropSource'}, 
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
                            maxId = +item.databaseId;
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
            if (!options["allow-lagacy"] && key === 'armor' && rawEquip.ID < 41042) return false;
            if (!options["allow-lagacy"] && key === 'trinket' && rawEquip.ID < 23441) return false;
            if (!options["allow-lagacy"] && key === 'weapon' && rawEquip.ID < 18631) return false;
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
                        let id;
                        if (tabs.id[equip.originalId] && tabs.id[equip.originalId].databaseId) {
                            id = tabs.id[equip.originalId].databaseId;
                        } else {
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
                    csvWriter.writeRecords(pack.sort((a,b) => a.id - b.id)).then(() => {
                        return idMapWriter.writeRecords(idMap.sort((a, b) => a.databaseId - b.databaseId));
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
} else if (global.command === 'enchant') {
    console.log('====parse enchants====');
    console.log('=========init=========');
    console.time(`reading enchant`);
    let firstLineLoaded = false;
    let keys = [];
    const tabs = [];

    function parseEnchant() {
        console.log(tabs.length);
    }


    fs.createReadStream('./raw/Enchant.tab')
        .pipe(iconv.decodeStream('gb2312'))
        .pipe(iconv.encodeStream('utf8'))
        .pipe(parse({ delimiter: '\t' }))
        .on('data', function(row) {
            if (!firstLineLoaded) {
                // 读取第一行
                firstLineLoaded = true;
                keys = row;
            } else {
                const item = row.reduce((acc, cur, i) => {
                    const keyName = keys[i];
                    acc[keyName] = cur;
                    return acc;
                }, {});
                if (isNaN(item.UIID)) {
                    tabs.push(item);
                }
            }
        })
        .on('end',function() {
            console.timeEnd(`reading enchant`);
            parseEnchant();
        });

} else {
    console.log('Wrong command');
}
