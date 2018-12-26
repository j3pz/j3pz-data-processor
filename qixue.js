const { parse } = require('csv');
const fs = require('fs');
const iconv = require('iconv-lite');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

const schoolMap = {
  0: '江湖',
  1: '少林',
  2: '万花',
  3: '天策',
  4: '纯阳',
  5: '七秀',
  6: '五毒',
  7: '唐门',
  8: '藏剑',
  9: '丐帮',
  10: '明教',
  21: '苍云',
  22: '长歌',
  23: '霸刀',
  24: '蓬莱',
};

const kungfuMap = {
  1: '洗髓经',
  2: '易筋经',
  3: '紫霞功',
  4: '太虚剑意',
  5: '花间游',
  6: '傲血战意',
  7: '离经易道',
  8: '铁牢律',
  9: '云裳心经',
  10: ' 冰心诀',
  11: '问水诀',
  12: '山居剑意',
  13: '毒经',
  14: '补天诀',
  15: '惊羽诀',
  16: '天罗诡道',
  17: '焚影圣诀',
  18: '明尊琉璃体',
  19: '笑尘诀',
  20: '铁骨衣',
  21: '分山劲',
  22: '莫问',
  23: '相知',
  24: '北傲诀',
  25: '凌海诀',
};

function readCsvFile(file, isObj) {
  console.time(`reading ${file}`);
  return new Promise((resolve, reject) => {
    let keys = [];
    let keyRead = false;
    const tab = isObj ? {} : [];
    fs.createReadStream(file)
      .pipe(iconv.decodeStream('gb2312'))
      .pipe(iconv.encodeStream('utf8'))
      .pipe(parse({ delimiter: '\t', quote: null }))
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
            tab[`${item.SkillID}-${item.Level}`] = item;
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
  const skills = await readCsvFile('./raw/skill.txt', true);
  const points = await readCsvFile('./raw/TenExtraPoint.tab');
  // const result = {};
  const result = [];
  for (const point of points) {
    const school = schoolMap[point.ForceID];
    const kungfu = kungfuMap[point.KungFuID];
    // if (!result[school]) {
    //   result[school] = {};
    // }
    // if (!result[school][kungfu]) {
    //   result[school][kungfu] = [];
    // }
    // const info = {
    //   skills: [],
    //   position: (point.PointID - 1) % 12 + 1,
    // };
    [1, 2, 3, 4, 5].map(v => [`SkillID${v}`, `SkillLevel${v}`]).forEach(([id, level]) => {
      const skillId = `${point[id]}-${point[level]}`;
      const skill = skills[skillId];
      if (skill) {
        // info.skills.push({
        //   name: skill.Name,
        //   desc: skill.Desc,
        // });
        result.push({
          name: skill.Name,
          desc: skill.Desc,
          position: (point.PointID - 1) % 12 + 1,
          school,
          kungfu,
        });
      }
    });
    // result[school][kungfu].push(info);
  }
  // fs.writeFile('./output/qixue.json', JSON.stringify(result, null, 2), 'utf8', () => {
  //   console.log('done');
  // });

  const csvWriter = createCsvWriter({
    path: `./output/qixue.csv`,
    header: [ 
        { id: 'school', title: '门派' },
        { id: 'kungfu', title: '心法' },
        { id: 'position', title: '奇穴位置' },
        { id: 'name', title: '奇穴名' },
        { id: 'desc', title: '描述' },
    ],
  });
  csvWriter.writeRecords(result).then(() => {
    console.log(`done`);
  });
}

init();
