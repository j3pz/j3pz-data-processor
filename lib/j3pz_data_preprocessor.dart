import 'package:j3pz_data_preprocessor/equip_parser.dart';

import './read_file.dart';

void equips() async {
    var armor = await readFile(path: './raw/Custom_Armor.tab');
    var trinket = await readFile(path: './raw/Custom_Trinket.tab');
    var weapon = await readFile(path: './raw/Custom_Weapon.tab');
    var attribute = await readFile(path: './raw/Attrib.tab');
    var parser = EquipParser(armor: armor, trinket: trinket, weapon: weapon, attribute: attribute);
}
