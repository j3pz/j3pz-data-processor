const axios = require('axios');
const fs = require('fs');
const path = require('path');
const { parse } = require('csv');
const iconv = require('iconv-lite');

const url = 'http://dl.pvp.xoyo.com/prod/icons/';

const start = 11220;

async function download(link, name) {
    const response = await axios({
        method: 'GET',
        url: link,
        responseType: 'stream'
    });
    
    // pipe the result stream into a file on disc
    response.data.pipe(fs.createWriteStream(path.resolve(__dirname, 'icons', name)));

    // return a promise and resolve when download finishes
    return new Promise((resolve, reject) => {
        response.data.on('end', () => {
            console.log(`${name} success`)
            resolve()
        });

        response.data.on('error', () => {
            console.log(`${name} error`)
            resolve()
        });
    })
}

let firstLineLoaded = false;
let keys = [];
const paths = [];

function readTab() {
    console.time(`reading icons`);
    fs.createReadStream('./raw/icon.txt')
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
                paths.push(item);
            }
        })
        .on('end',function() {
            console.timeEnd(`reading icons`);
            (async function() {
                for (let link of paths) {
                    if (link.ID < start) {
                        continue;
                    }
                    const pngUrl = url + link.FileName.replace('UITex', 'png');
                    const fileName = `${link.ID}.png`;
                    try {
                        await download(pngUrl, fileName);
                    } catch (e) {
                        console.log(`${link.ID} : ${fileName} error`)
                        // do nothing
                    }
                }
            })();
        });
}
readTab();


