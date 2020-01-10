import 'dart:io';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/equip.dart';
import 'package:j3pz_data_preprocessor/source.dart';

const typeToTab = {
    'weapon': 6,
    'armor': 7,
    'trinket': 8,
};

const typeMap = {
    '任务': ['other', '任务'],
    '掉落': ['raid', ''],
    '声望': ['reputation', ''],
    '副本': ['raid', ''],
    '帮贡': ['redeem', 'contribution'],
    '生活技能': ['other', '生活技能'],
    '道具换取': ['redeem', 'contribution'],
    '野外boss': ['raid', ''],
    '竞技场': ['redeem', 'arena'],
    '威望': ['redeem', 'prestige'],
    '龙门寻宝商店': ['redeem', 'store'],
    '奇宝之争': ['activity', '奇宝之争'],
    '活动': ['activity'],
    '阵营拍卖': ['activity', '阵营拍卖'],
    '任务装备': ['other', '任务'],
    '神兵试炼': ['other', '神兵试炼'],
    '神兵试炼_拭剑园': ['other', '神兵试炼-拭剑园'],
};

const sourceTitle = ['id', 'type', 'description'];

class SourceParser {
    Map<String, RawSource> rawSources;
    Map<String, int> ids = {};
    Map<int, Source> sources = {};

    int sourceNext = 1;

    SourceParser({
        Map equipDb,
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
    }

    int getNewId(String identifier) {
        ids[identifier] = ++sourceNext;
        return sourceNext;
    }

    Source getSource(RawEquip raw, String type) {
        var tabid = typeToTab[type];
        var rawSource = rawSources['$tabid-${raw.id}'];
        // print(rawSource.getDesc);
        if (rawSource == null) {
            // print('解析来源出错, name=${raw.name}, id=${raw.id}, tab=$tabid');
            return null;
        }
        var getType = typeMap[raw.getType];
        Source source;
        if (getType[0] == 'other') {
            source = parseOtherSource(raw, rawSource);
        }
        if (source != null && sources[source.id] == null ) {
            sources[source.id] = source;
        }
        return source;
    }

    Source parseOtherSource(RawEquip equip, RawSource raw) {
        var type = typeMap[equip.getType];
        String description;
        if (raw.getDesc.contains('夜狼山宝箱')) {
            description = '${type[1]}•挖宝';
        } else if (raw.getDesc.contains('浑浑噩噩的魂灵')) {
            description = '${type[1]}•方士';
        } else {
            var details = raw.getDesc.replaceAll(RegExp('{|}'), '');
            if (details != '') {
                description = '${type[1]}•$details';
            } else {
                description = type[1];
            }
        }
        var identifier = 'other-$description';
        var databaseId = ids[identifier] ?? getNewId(identifier);
        var source = Source(id: databaseId, type: 'other');
        source.description = description ?? '';
        return source;
    }
}
