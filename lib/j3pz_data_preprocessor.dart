import 'dart:convert';

import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/enchant_parser.dart';
import 'package:j3pz_data_preprocessor/equip_parser.dart';
import 'package:j3pz_data_preprocessor/furniture_parser.dart';
import 'package:j3pz_data_preprocessor/gamemap_parser.dart';
import 'package:j3pz_data_preprocessor/represent_parser.dart';
import 'package:j3pz_data_preprocessor/set_parser.dart';
import 'package:j3pz_data_preprocessor/source_parser.dart';
import 'package:j3pz_data_preprocessor/stone_parser.dart';

import './read_file.dart';

void equips() async {
    print('reading files');
    var armor = await readFile(path: './raw/Custom_Armor.tab');
    var trinket = await readFile(path: './raw/Custom_Trinket.tab');
    var weapon = await readFile(path: './raw/Custom_Weapon.tab');
    var attribute = await readFile(path: './raw/Attrib.tab');
    var item = await readFile(path: './raw/item.txt', id: 'ItemID');
    var event = await readFile(path: './raw/skillevent.txt');
    var recipe = await readFile(path: './raw/equipmentrecipe.txt', ids: ['ID', 'Level']);
    var savedEquipId = await readFile(path: './output/equipId.tab', delimiter: ',');
    var savedEffectId = await readFile(path: './output/effectId.tab', delimiter: ',');
    var equipSet = await readFile(path: './raw/Set.tab');
    var savedSetId = await readFile(path: './output/setId.tab', delimiter: ',');
    // var skill = await readFile(path: './raw/skill.txt', ids: ['SkillID', 'Level']);

    var equipDb = await readFile(path: './raw/equipdb.txt', ids: ['TabType', 'ID']);
    var mapList = await readFile(path: './raw/MapList.tab');

    var representToExterior = await readFile(path: './raw/ExteriorInfo.tab', ids: ['SubType', 'RepresentID', 'ColorID', 'ForceID']);
    var exteriorToSet = await readFile(path: './raw/exteriorbox.txt', id: 'Set');

    print('parsing');

    var effectParser = EffectParser(
        effectId: savedEffectId,
        event: event,
        recipe: recipe,
    );

    var mapParser = GameMapParser(mapList: mapList);

    var setParser = SetParser(
        equipSet: equipSet,
        effectParser: effectParser,
        attribute: attribute,
        setId: savedSetId,
    );

    var representParser = RepresentParser(
        representToExterior: representToExterior,
        exteriorToSet: exteriorToSet,
    );

    var sourceParser = SourceParser(
        equipDb: equipDb,
        mapParser: mapParser,
    );

    var equipParser = EquipParser(
        armor: armor,
        trinket: trinket,
        weapon: weapon,
        attribute: attribute,
        item: item,
        equipId: savedEquipId,

        effectParser: effectParser,
        setParser: setParser,
        representParser: representParser,
        sourceParser: sourceParser,
    );
    print('generating');
    equipParser.export('./output');
    mapParser.export('./output');
    effectParser.export('./output');
    setParser.export('./output');
    representParser.export('./output');
    sourceParser.export('./output');
    print('done');
}

void enchant() async {
    print('reading files');
    var enchants = await readFile(path: './raw/Enchant.tab');
    var items = await readFile(path: './raw/item.txt', id: 'ItemID');
    var other = await readFile(path: './raw/Other.tab');
    var ids = await readFile(path: './output/enchantId.tab', delimiter: ',');
    print('parsing');
    var enchantParser = EnchantParser(
        ids: ids,
        other: other,
        item: items,
        enchant: enchants,
    );
    print('generating');
    enchantParser.export('./output');
    print('done');
}

void furniture() async {
    print('reading files');
    var furniture = await readFile(path: './raw/furniture.tab');
    var ui = await readFile(path: './raw/furnitureaddinfo.tab', id: 'dwID');
    var item = await readFile(path: './raw/homeland_furnitureinfo.tab', ids: ['nFurnitureType', 'dwFurnitureID', 'nBrushModeCnt']);
    print('parsing');
    var furnitureParser = FurnitureParser(
        furnitures: furniture,
        uis: ui,
        items: item,
    );
    print('generating');
    furnitureParser.export('./output');
    print('done');
}

void stone() async {
    print('reading files');
    var other = await readFile(path: './raw/Other.tab');
    var items = await readFile(path: './raw/item.txt', id: 'ItemID');
    var enchants = await readFile(path: './raw/Enchant.tab');
    var ids = await readFile(path: './output/stoneId.tab', delimiter: ',');
    print('parsing');
    var stoneParser = StoneParser(
        ids: ids,
        others: other,
        items: items,
        enchants: enchants,
    );
    print('generating');
    stoneParser.export('./output');
    print('done');
}