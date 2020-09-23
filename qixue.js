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
  25: '凌雪',
  211: '衍天',
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
  26: '隐龙诀',
  27: '太玄经',
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
            tab[`${item.SkillID || item.BuffID || item.ID}-${item.Level}`] = item;
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
  const buffUi = await readCsvFile('./raw/buff.txt', true);
  const buffSetting = await readCsvFile('./raw/Buff.tab', true);
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

      let skillId = `${point[id]}-${point[level]}`;
      let _skillId = `${point[id]}-0`;    //取level为0
      let skill = skills[skillId];
      if(!skill) skill = skills[_skillId]   //特殊主动技能不存在level为1时，技能取level为0的项

      /* if(!skills[skillId]){
        skill = skills[`${point[id]}-0}`];
      } */

      if (skill) {
        let desc = skill.Desc;
        if (desc.indexOf('<') >= 0) {
          desc = desc.replace(/<SUB[\s\w]+>/g, '');
          desc = desc.replace(/<SKILL[\s\w\u4e00-\u9fa5%_{;}\[\]+,\-.>\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]+\(\+<SKILLEx[%_{;\[\]}+,\-.\s\w\u4e00-\u9fa5\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]+>\)/g, '');
          desc = desc.replace(/<SKILLEx[\s\w\u4e00-\u9fa5%_.{;}\[\],+\-\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]+>/g, '');
          desc = desc.replace(/<EnchantID[\s\w\u4e00-\u9fa5%_.{;},\[\]+\-\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]+>/g, '');
          desc = desc.replace(/<TALENT[\s\w\u4e00-\u9fa5"%_.{;},\[\]+\-\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]+>/g, '');
          desc = desc.replace(/<PARRY (\d+)>%的/g, '');

          while (/<BUFF (\d+) (\d) desc>/.test(desc)) {
            const match = desc.match(/<BUFF (\d+) (\d) desc>/);
            const buffId = match[1];
            const buffLevel = match[2];
            const desiredBuff = buffUi[`${buffId}-${buffLevel}`];
            const fallbackBuff0 = buffUi[`${buffId}-0`];
            const fallbackBuff1 = buffUi[`${buffId}-1`];
            const buff = desiredBuff || fallbackBuff0 || fallbackBuff1;
            if (buff) {
              desc = desc.replace(/<BUFF (\d+) (\d) desc>/, buff.Desc);
              while (/BUFF (\w+)>/.test(desc)) {
                const match = desc.match(/<BUFF (\w+)>/);
                const desiredBuff = buffSetting[`${buffId}-${buffLevel}`];
                const fallbackBuff0 = buffSetting[`${buffId}-0`];
                const fallbackBuff1 = buffSetting[`${buffId}-1`];
                const buff = desiredBuff || fallbackBuff0 || fallbackBuff1;
                if (buff) {
                  const idx = [buff.ActiveAttrib1, buff.ActiveAttrib2].indexOf(match[1]);
                  if (idx >= 0) {
                    const value = buff[`ActiveValue${idx + 1}A`] || buff[`ActiveValue${idx + 1}B`] || 0;
                    desc = desc.replace(/<BUFF (\w+)>/, value);
                  }
                } else {
                  console.log(desc);
                  console.log(`failed to read: ${buffId}-${buffLevel}`);
                }
              }
            } else {
              console.log(desc);
              console.log(`failed to read: ${buffId}-${buffLevel}`);
            }
          }
          while (/<BUFF (\d+) (\d) time>/.test(desc)) {
            const match = desc.match(/<BUFF (\d+) (\d) time>/);
            const buffId = match[1];
            const buffLevel = match[2];
            const desiredBuff = buffSetting[`${buffId}-${buffLevel}`];
            const fallbackBuff0 = buffSetting[`${buffId}-0`];
            const fallbackBuff1 = buffSetting[`${buffId}-1`];
            const buff = desiredBuff || fallbackBuff0 || fallbackBuff1;
            if (buff) {
              desc = desc.replace(/<BUFF (\d+) (\d) time>/, buff.Interval / 16 + '秒');
            } else {
              console.log(desc);
              console.log(`failed to read: ${buffId}-${buffLevel}`);
            }
          }
        }
        desc = desc.replace('(+)', '');
        desc = desc.replace(',', '，');
        if (desc.indexOf('"') >= 0) {
          console.log(skill.Desc);
        }
        if (desc.indexOf('<') >= 0) {
          console.log(skill.Desc);
        }
        // info.skills.push({
        //   name: skill.Name,
        //   desc: skill.Desc,
        // });
        result.push({
          name: skill.Name,
          desc: desc,
          position: (point.PointID - 1) % 12 + 1,
          school,
          kungfu,
          skillID : point[id],
          icon: skill.IconID,
          version: '1.0.0.3931',
          effect: '',
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
        // { id: 'school', title: '门派' },
        { id: 'kungfu', title: 'kungfu' },
        { id: 'position', title: 'index' },
        { id: 'name', title: 'name' },
        { id: 'desc', title: 'description' },
        // { id: 'skillID', title: '技能ID' },
        { id: 'icon', title: 'icon' },
        { id: 'version', title: 'version' },
        { id: 'effect', title: 'effectId' },
    ],
  });
  csvWriter.writeRecords(result).then(() => {
    console.log(`done`);
  });
}

init();
