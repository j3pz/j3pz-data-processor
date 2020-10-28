import 'package:j3pz_data_preprocessor/j3pz_data_preprocessor.dart';

void main(List<String> arguments) {
    if (arguments[0] == 'equip') {
        equips();
    } else if (arguments[0] == 'enchant') {
        enchant();
    } else if (arguments[0] == 'furniture') {
        furniture();
    } else if (arguments[0] == 'stone') {
        stone();
    } else if (arguments[0] == 'buff') {
        buff();
    } else {
        print('unsupported command');
    }
}
