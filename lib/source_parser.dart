import 'dart:io';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/gamemap_parser.dart';
import 'package:j3pz_data_preprocessor/source.dart';

const typeToTab = {
    'weapon': 6,
    'armor': 7,
    'trinket': 8,
};

const typeMap = {
    '任务': ['other', '任务'],
    '掉落': ['other', ''],
    '声望': ['reputation', ''],
    '副本': ['raid', ''],
    '贡献度': ['redeem', 'contribution'],
    '生活技能': ['other', '生活技能'],
    '套装兑换': ['redeem', ''],
    '侠义值': ['redeem', 'chivalry'],
    '野外boss': ['other', '野外boss'],
    '商店': ['redeem', 'store'],
    '竞技场': ['redeem', 'arena'],
    '威望': ['redeem', 'prestige'],
    '龙门寻宝商店': ['redeem', 'store'],
    '奇宝之争': ['activity', '奇宝之争'],
    '名剑大会': ['redeem', 'arena'],
    '活动': ['activity', ''],
    '道具换取': ['redeem', ''],
    '阵营拍卖': ['activity', '阵营拍卖'],
    '帮贡': ['redeem', 'contribution'],
    '任务装备': ['other', '任务'],
    '神兵试炼': ['other', '神兵试炼'],
    '神兵试炼_拭剑园': ['other', '神兵试炼'],
    '会心': ['other', '神兵试炼'],
    '命中': ['other', '神兵试炼'],
    '伤害': ['other', '神兵试炼'],
    '破防': ['other', '神兵试炼'],
    '加速': ['other', '神兵试炼'],
    '拆招': ['other', '神兵试炼'],
    '无双': ['other', '神兵试炼'],
    '招架': ['other', '神兵试炼'],
    '外防': ['other', '神兵试炼'],
    '内防': ['other', '神兵试炼'],
    '治疗': ['other', '神兵试炼'],
};

const prestigeType = {
    '2': 'prestige_virtue',
    '4': 'prestige_fiend',
};

const sourceTitle = ['id', 'type', 'comment', 'activity', 'limitedTime', 'redeem', 'reputationId', 'bossId'];
const reputationTitle = ['id', 'name', 'level'];
const bossTitle = ['id', 'name', 'mapid'];

class SourceParser {
    Map<String, RawSource> rawSources;
    Map<String, int> ids = {};
    Map<String, int> reputationIds = {};
    Map<String, int> bossIds = {};
    Map<int, Source> sources = {};
    Map<String, int> types = {};
    Map<int, Reputation> reputations = {};
    Map<int, Boss> bosses = {};

    GameMapParser mapParser;

    int sourceNext = 0;
    int reputationNext = 0;
    int bossNext = 0;

    SourceParser({
        Map equipDb,
        this.mapParser,
    }) {
        rawSources = {};
        equipDb.forEach((key, value) {
            rawSources[key] = RawSource.fromJson(value);
        });
    }

    void export(String path) {
        var sources = <List<String>>[];
        this.sources.forEach((id, source) {
            sources.add(source.toList());
        });
        sources..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, sourceTitle);
        var sourcetCsv = const ListToCsvConverter().convert(sources);
        File('$path/source.csv').writeAsString(sourcetCsv);

        var reputations = <List<String>>[];
        this.reputations.forEach((id, reputation) {
            reputations.add(reputation.toList());
        });
        reputations..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, reputationTitle);
        var reputationCsv = const ListToCsvConverter().convert(reputations);
        File('$path/reputation.csv').writeAsString(reputationCsv);

        var bosses = <List<String>>[];
        this.bosses.forEach((id, boss) {
            bosses.add(boss.toList());
        });
        bosses..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))..insert(0, bossTitle);
        var bossCsv = const ListToCsvConverter().convert(bosses);
        File('$path/boss.csv').writeAsString(bossCsv);
    }

    int getNewId(String identifier) {
        ids[identifier] = ++sourceNext;
        return sourceNext;
    }

    int getNewReputationId(String identifier) {
        reputationIds[identifier] = ++reputationNext;
        return reputationNext;
    }

    int getNewBossId(String identifier) {
        bossIds[identifier] = ++bossNext;
        return bossNext;
    }

    List<Source> getSource(RawEquip raw, String type) {
        var tabid = typeToTab[type];
        var rawSource = rawSources['$tabid-${raw.id}'];
        if (rawSource == null) {
            // print('解析来源出错, name=${raw.name}, id=${raw.id}, tab=$tabid');
            return null;
        }
        var types = (rawSource.getType == '' ? raw.getType : rawSource.getType).split(',');
        var sources = <RawSource>[];
        if (types.length > 1) {
            sources = splitRawSource(rawSource);
        } else {
            sources = [rawSource];
        }
        var i = 0;
        var sourceList = <Source>[];
        types.forEach((typeIdentifier) {
            var source = sources[i];
            var list = parseSource(raw, source, typeIdentifier);
            sourceList.addAll(list);
            i += 1;
        });
        return sourceList;
    }

    List<RawSource> splitRawSource(RawSource raw) {
        var types = raw.getType.split(',');
        var descs = raw.getDesc.split('},{');
        if (types.length != descs.length) {
            return List.filled(types.length, raw);
        }
        var sources = <RawSource>[];
        var i = 0;
        types.forEach((type) {
            var source = RawSource.clone(raw);
            var desc = descs[i];
            source.getType = type;
            source.getDesc = desc;
            if (source.getType != '副本') {
                source.belongMapId = '';
            }
            sources.add(source);
            i += 1;
        });
        return sources;
    }

    List<Source> parseSource(RawEquip equip, RawSource raw, String type) {
        var getType = typeMap[type];
        Source source;
        var sources = <Source>[];
        if (getType[0] == 'other') {
            source = parseOtherSource(equip, raw, type);
            recordSource(source);
            sources.add(source);
        } else if (getType[0] == 'activity') {
            source = parseActivitySource(equip, raw, type);
            recordSource(source);
            sources.add(source);
        } else if (getType[0] == 'redeem') {
            source = parseRedeemSource(equip, raw, type);
            recordSource(source);
            sources.add(source);
        } else if (getType[0] == 'reputation') {
            source = parseReputationSource(equip, raw, type);
            recordSource(source);
            sources.add(source);
        } else if (getType[0] == 'raid') {
            var sourceList = parseRaidSource(equip, raw, type);
            sourceList.forEach(recordSource);
            sources = sourceList;
        }
        return sources;
    }

    void recordSource(Source source) {
        if (source != null && sources[source.id] == null) {
            sources[source.id] = source;
        }
    }

    List<Source> parseRaidSource(RawEquip equip, RawSource raw, String getType) {
        var sources = <Source>[];
        var desc = raw.getDesc.replaceAll(RegExp('{|}'), '');
        var maps = raw.belongMapId.split(',');
        var bossGroups = desc.split('],[');
        while (maps.length < bossGroups.length) {
            maps.add('4');
        }
        var i = 0;

        maps.forEach((mapId) {
            var bosses = bossGroups[i].replaceAll(RegExp(r'\[|\]'), '').split(',');
            var map = mapParser.gameMaps[mapId];
            bosses.forEach((name) {
                var bossIdentifier = '$map-${name.trim()}';
                var bossId = bossIds[bossIdentifier] ?? getNewBossId(bossIdentifier);
                var boss = Boss(id: bossId, name: name, map: map);
                var identifier = 'raid-$bossId';
                var databaseId = ids[identifier] ?? getNewId(identifier);
                if (boss != null && this.bosses[boss.id] == null) {
                    this.bosses[boss.id] = boss;
                }
                var source = Source(id: databaseId, type: 'raid');
                source.boss = boss;
                sources.add(source);
            });
            i += 1;
        });
        return sources;
    }

    Source parseReputationSource(RawEquip equip, RawSource raw, String getType) {
        var name = raw.getDesc.replaceAll(RegExp('{|}'), '').replaceAll('·声望商', '').replaceAll('·装备', '');
        if (name == '') {
            name = '未知';
        }
        var level = raw.prestigeRequire;
        var reputationIdentifier = 'reputation-$name-$level';
        var reputationId = reputationIds[reputationIdentifier] ?? getNewReputationId(reputationIdentifier);
        var reputation = Reputation(id: reputationId);
        reputation.name = name;
        reputation.level = level;
        if (reputations[reputationId] == null) {
            reputations[reputationId] = reputation;
        }
        var identifier = 'reputation-$reputationId';
        var databaseId = ids[identifier] ?? getNewId(identifier);
        var source = Source(id: databaseId, type: 'reputation');
        source.reputation = reputation;
        return source;
    }

    Source parseRedeemSource(RawEquip equip, RawSource raw, String getType) {
        var type = typeMap[getType];
        String redeem;
        var desc = '';
        if (type[1] != '' && type[1] != 'prestige') {
            redeem = type[1];
            if (type[1] == 'store') {
                desc = equip.getType;
            }
        } else if (type[1] == 'prestige') {
            redeem = prestigeType[equip.requireCamp];
        } else if (raw.getType.contains('侠义值')) {
            redeem = 'chivalry';
        } else if (raw.getDesc.contains('兑换牌')) {
            redeem = 'set';
        }
        var identifier = 'redeem-$redeem-$desc';
        var databaseId = ids[identifier] ?? getNewId(identifier);
        var source = Source(id: databaseId, type: 'redeem');
        source.redeem = redeem ?? 'unknown';
        source.description = desc;
        return source;
    }

    Source parseActivitySource(RawEquip equip, RawSource raw, String getType) {
        var type = typeMap[getType];
        String activity;
        var isLimitedTime = false;
        if (type[1] != '') {
            activity = type[1];
        } else if (equip.name.contains('无界')) {
            activity = '试炼之地';
        } else {
            isLimitedTime = true;
        }
        var identifier = 'other-$activity';
        var databaseId = ids[identifier] ?? getNewId(identifier);
        var source = Source(id: databaseId, type: 'activity');
        source.activity = activity ?? '限时活动';
        source.limitedTime = isLimitedTime;
        return source;
    }

    Source parseOtherSource(RawEquip equip, RawSource raw, String getType) {
        var type = typeMap[getType];
        String description;
        var details = raw.getDesc.replaceAll(RegExp('{|}'), '');
        if (details != '') {
            description = '${type[1]}•$details';
        } else {
            description = type[1];
        }
        var identifier = 'other-$description';
        var databaseId = ids[identifier] ?? getNewId(identifier);
        var source = Source(id: databaseId, type: 'other');
        source.description = description ?? '';
        return source;
    }
}
