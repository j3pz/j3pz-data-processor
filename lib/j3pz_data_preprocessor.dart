import 'package:j3pz_data_preprocessor/equip_parser.dart';

import './read_file.dart';

void equips() async {
    print('reading files');
    var armor = await readFile(path: './raw/Custom_Armor.tab');
    var trinket = await readFile(path: './raw/Custom_Trinket.tab');
    var weapon = await readFile(path: './raw/Custom_Weapon.tab');
    var attribute = await readFile(path: './raw/Attrib.tab');
    var item = await readFile(path: './raw/item.txt', id: 'ItemID');
    var savedEquipId = await readFile(path: './output/equipId.tab', delimiter: ',');
    print('parsing');
    var parser = EquipParser(
        armor: armor,
        trinket: trinket,
        weapon: weapon,
        attribute: attribute,
        item: item,
        equipId: savedEquipId,
    );
    print('generating');
    parser.export('./output');
}
