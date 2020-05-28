import 'dart:io';

import 'package:csv/csv.dart';
import 'package:j3pz_data_preprocessor/furniture.dart';

class FurnitureParser {
    Map<String, Furniture> furnitureMaps = {};
    Map<String, RawFurnitureUi> uiMap = {};
    Map<String, RawFurnitureInfo> itemMap = {};

    FurnitureParser({ Map furnitures, Map uis, Map<String, dynamic> items }) {
        items.forEach((String key, item) {
            if (key.endsWith('-')) {
                key = '${key}0';
            }
            itemMap[key] = RawFurnitureInfo.fromJson(item);
        });

        uis.forEach((key, ui) {
            uiMap[key] = RawFurnitureUi.fromJson(ui);
        });

        furnitures.forEach((key, furniture) {
            var raw = RawFurniture.fromJson(furniture);
            if (raw.levelLimit >= 20) {
                return;
            }
            furnitureMaps[key] = parseFurniture(raw);
        });
    }

    void export(String path) {
        var furnitures = <List<String>>[];
        furnitureMaps.forEach((id, furniture) {
            if (furniture != null) {
                furnitures.add(furniture.toList());
            }
        });
        furnitures..sort((a, b) => int.parse(a[0]) - int.parse(b[0]))
            ..insert(0, ['id', 'category', 'name', 'quality', 'level', 'interact', 'scaleRange', 'source', 'img', 'desc', 'limit', 'price', 'environment', 'beauty', 'practicality', 'robustness', 'fun']);
        var csv = const ListToCsvConverter().convert(furnitures);
        File('$path/furniture.csv').writeAsString(csv);
    }

    Furniture parseFurniture(RawFurniture raw) {
        var furniture = Furniture(
            id: raw.id,
            category: raw.category1 * 10000 + raw.category2 * 100,
        );
        RawFurnitureInfo info;
        if (itemMap['1-${furniture.id}-0'] != null) {
            info = itemMap['1-${furniture.id}-0'];
        } else if (itemMap['1-${furniture.id}-2'] != null) {
            info = itemMap['1-${furniture.id}-2'];
        } else {
            return null;
        }
        furniture.name = info.name;
        furniture.quality = raw.quality;
        furniture.level = raw.qualityLevel;
        furniture.scaleRange = info.scaleRange;
        furniture.interact = info.interact;
        furniture.limit = raw.levelLimit;
        furniture.price = raw.architecture;
        furniture.desc = uiMap['${raw.id + 100000000}'].desc;
        furniture.source = getSource(uiMap['${raw.id + 100000000}'].source);
        furniture.img = getImagePath(uiMap['${raw.id + 100000000}'].img);
        furniture.beauty = raw.attribute1;
        furniture.practicality = raw.attribute2;
        furniture.robustness = raw.attribute3;
        furniture.environment = raw.attribute4;
        furniture.fun = raw.attribute5;
        return furniture;
    }

    String getImagePath(String rawPath) {
        return rawPath.toLowerCase()
            .replaceFirst('ui\\image\\homeland\\data\\source\\', '')
            .replaceAll('\\', '/')
            .replaceFirst('.tga', '.png');
    }

    String getSource(String source) {
        if (source.contains('园宅')
            || source.contains('活动')
            || source.contains('隐藏')
            || source.contains('生活技能')
            || source.contains('声望')
            || source.contains('奇遇')
            || source.contains('侠义值')
            || source.contains('飞沙令')
            || source.contains('名剑大会')
            || source.contains('战阶')
            || source.contains('师徒值')
            || source.contains('管家')
            || source.contains('宠物游历')
            || source.contains('小区')
            || source.contains('监本印文')
            || source.contains('雀神点数')
            || source.contains('江湖贡献值')
            || source.contains('入住家园赠送')
            || source.contains('商城')
            || source.contains('未知')
            || source.isEmpty
        ) {
            return source;
        } else {
            return '副本∙$source';
        }
    }
}
