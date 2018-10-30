const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');

console.log('init');

const flags = { armor: 0, trinket: 0, weapon: 0, attrib: 0, set: 0 };
const keys = { armor: [], trinket: [], weapon: [], attrib: [], set: [] };
const tabs = { armor: [], trinket: [], weapon: [], attrib: [], set: [] };

function readCsvFile(file, key, callback) {
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
                tabs[key].push(item)
            }
        })
        .on('end',function() {
            console.timeEnd(`reading ${key}`);
            callback(key);
        });
}

function readCallback(key) {
    flags[key] += 1;
    const sum = Object.values(flags).reduce((acc, cur) => acc + cur, 0);
    if (sum === 10) {
        console.log('init finished');
    }
}

readCsvFile('./raw/Custom_Armor.tab', 'armor', readCallback);
readCsvFile('./raw/Custom_Trinket.tab', 'trinket', readCallback);
readCsvFile('./raw/Custom_Weapon.tab', 'weapon', readCallback);
readCsvFile('./raw/Attrib.tab', 'attrib', readCallback);
readCsvFile('./raw/Set.tab', 'set', readCallback);

