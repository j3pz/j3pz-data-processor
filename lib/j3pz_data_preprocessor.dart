import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip_parser.dart';
import 'package:j3pz_data_preprocessor/represent_parser.dart';
import 'package:j3pz_data_preprocessor/set_parser.dart';
import 'package:j3pz_data_preprocessor/source_parser.dart';

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

    var representToExterior = await readFile(path: './raw/ExteriorInfo.tab', ids: ['SubType', 'RepresentID', 'ColorID', 'ForceID']);
    var exteriorToSet = await readFile(path: './raw/exteriorbox.txt', id: 'Set');

    print('parsing');

    var effectParser = EffectParser(
        effectId: savedEffectId,
        event: event,
        recipe: recipe,
    );

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
    effectParser.export('./output');
    setParser.export('./output');
    representParser.export('./output');
    sourceParser.export('./output');
    print('done');
}
