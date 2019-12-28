import 'package:j3pz_data_preprocessor/effect_parser.dart';
import 'package:j3pz_data_preprocessor/equip_parser.dart';

import './read_file.dart';

void equips() async {
    print('reading files');
    var armor = await readFile(path: './raw/Custom_Armor.tab');
    var trinket = await readFile(path: './raw/Custom_Trinket.tab');
    var weapon = await readFile(path: './raw/Custom_Weapon.tab');
    var attribute = await readFile(path: './raw/Attrib.tab');
    var item = await readFile(path: './raw/item.txt', id: 'ItemID');
    var event = await readFile(path: './raw/skillevent.txt');
    var recipe = await readFile(path: './raw/equipmentrecipe.txt');
    var savedEquipId = await readFile(path: './output/equipId.tab', delimiter: ',');
    var savedEffectId = await readFile(path: './output/effectId.tab', delimiter: ',');
    var savedSetId = await readFile(path: './output/setId.tab', delimiter: ',');

    print('parsing');

    var effectParser = EffectParser(
        effectId: savedEffectId,
        event: event,
        recipe: recipe,
    );

    var equipParser = EquipParser(
        armor: armor,
        trinket: trinket,
        weapon: weapon,
        attribute: attribute,
        item: item,
        equipId: savedEquipId,

        effectParser: effectParser,
    );
    print('generating');
    equipParser.export('./output');
    effectParser.export('./output');
    print('done');
}
