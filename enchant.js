const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;
const { getEnchantAttributes, getEnchantXinfaType, getEnchantType } = require('./util');

const defaultAttributes = {
    body: 0,
    spirit: 0,
    strength: 0,
    agility: 0,
    spunk: 0,
    physicsShield: 0,
    magicShield: 0,
    dodge: 0,
    parryBase: 0,
    parryValue: 0,
    toughness: 0,
    attack: 0,
    heal: 0,
    crit: 0,
    critEffect: 0,
    overcome: 0,
    acce: 0,
    hit: 0,
    strain: 0,
    huajing: 0,
    threat: 0,
    neihui: 0,
    neili: 0,
    xuehui: 0,
    qixue: 0,
}

function readCsvFile(file, seperator, isObj, idKey) {
  console.time(`reading ${file}`);
  return new Promise((resolve, reject) => {
    let keys = [];
    let keyRead = false;
    const tab = isObj ? {} : [];
    fs.createReadStream(file)
      .pipe(iconv.decodeStream('gb2312'))
      .pipe(iconv.encodeStream('utf8'))
      .pipe(parse({ delimiter: seperator, quote: null }))
      .on('data', function(row) {
        if (!keyRead) {
          // 读取第一行
          keyRead = 1;
          keys = row;
        } else {
          const item = row.reduce((acc, cur, i) => {
            const keyName = keys[i];
            acc[keyName] = cur;
            return acc;
          }, {});
          if (isObj) {
            tab[item[idKey]] = item;
          } else {
            tab.push(item);
          }
        }
      })
      .on('end',function() {
        console.timeEnd(`reading ${file}`);
        resolve(tab);
      });
  });
}

async function init() {
  const enchants = await readCsvFile('./raw/Enchant.tab', '\t', true, 'ID');
  const items = await readCsvFile('./raw/item.txt', '\t',true, 'ItemID');
  const other = await readCsvFile('./raw/Other.tab', '\t');
  const ids = await readCsvFile('./output/enchantId.tab', ',', true, 'ID');
  const maxId = Object.values(ids).reduce((id, item) => {
    if (item.databaseId > id) {
      id = +item.databaseId;
    }
    return id;
  }, 0);

  const rawEnchant = other.filter(o => o.Genre === '7' && o.AucSubType > 0);

  const result = rawEnchant.map(e => {
    const enchant = { name: e.Name };
    const item = items[e.UiID];
    let dataId = item.Desc.match(/<ENCHANT (\d+)>/);
    if (dataId) {
        dataId = dataId[1];
    } else {
        return { originalId: 0 };
    }
    const data = enchants[dataId];
    const { ID, UIID, AttriName } = data;
    if (UIID.indexOf('限时') >= 0) {
      return { originalId: 0 };
    }
    enchant.desc = AttriName;
    enchant.type = getEnchantType(UIID);
    enchant.originalId = `enchant-${ID}`;
    enchant.xinfatype = getEnchantXinfaType(AttriName);
    Object.assign(enchant, defaultAttributes, getEnchantAttributes(rawEnchant));
    return enchant;
  }).filter(e => e.originalId !== 0);

//   const pack = newTab.map((enchant, i) => {
//     let id;
//     if (ids[enchant.originalId] && ids[enchant.originalId].databaseId) {
//         id = ids[enchant.originalId].databaseId;
//     } else {
//         countNew += 1;
//         id = maxId + countNew;
//     }
//     idMap.push({ ID: enchant.originalId, databaseId: id });
//     return { ...enchant, id };
// }).filter(_ => _.id != 'null');
// const idMapWriter = createCsvWriter({
//   path: './output/enchantId.tab',
//   header: [{ id: 'ID', title: 'ID' }, { id: 'databaseId', title: 'databaseId' }],
// });

  const csvWriter = createCsvWriter({
    path: `./output/newenhance.csv`,
    header: [ 
      { id: 'originalId', title: 'P_ID' },
      { id: 'name', title: 'name' },
      { id: 'desc', title: 'desc' },
      { id: 'type', title: 'type' },
      { id: 'realType', title: 'realType' },
      { id: 'xinfatype', title: 'xinfatype' },
      { id: 'body', title: 'body' },
      { id: 'spirit', title: 'spirit' },
      { id: 'strength', title: 'strength' },
      { id: 'agility', title: 'agility' },
      { id: 'spunk', title: 'spunk' },
      { id: 'physicsShield', title: 'physicsShield' },
      { id: 'magicShield', title: 'magicShield' },
      { id: 'dodge', title: 'dodge' },
      { id: 'parryBase', title: 'parryBase' },
      { id: 'parryValue', title: 'parryValue' },
      { id: 'toughness', title: 'toughness' },
      { id: 'attack', title: 'attack' },
      { id: 'heal', title: 'heal' },
      { id: 'crit', title: 'crit' },
      { id: 'critEffect', title: 'critEffect' },
      { id: 'overcome', title: 'overcome' },
      { id: 'acce', title: 'acce' },
      { id: 'hit', title: 'hit' },
      { id: 'strain', title: 'strain' },
      { id: 'huajing', title: 'huajing' },
      { id: 'threat', title: 'threat' },
      { id: 'neihui', title: 'neihui' },
      { id: 'neili', title: 'neili' },
      { id: 'xuehui', title: 'xuehui' },
      { id: 'qixue', title: 'qixue' },
    ],
  });
  csvWriter.writeRecords(result).then(() => {
  //     return idMapWriter.writeRecords(idMap.sort((a, b) => a.databaseId - b.databaseId));
  // }).then(() => {
      console.log(`output enhance done`);
  });
}
  
init();