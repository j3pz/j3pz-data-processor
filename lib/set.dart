import 'package:j3pz_data_preprocessor/effect.dart';

class EquipSet {
    int id;
    String name;
    List<String> names = [];

    EquipSet({ this.id, this.name });

    List<String> toList() {
        return [
            '$id',
            getName(),
        ];
    }

    void addName(String n) {
        if (!names.contains(n)) {
            names.add(n);
        }
    }

    String getCommon(List<List<String>> strs, bool reversed) {
        var common = '';
        var isSame = true;
        var idx = 0;
        while (isSame) {
            var pre = '';
            var shouldBreak = false;
            strs.forEach((str) {
                var c = str[reversed ? (str.length - idx - 1) : idx];
                if (pre == '') {
                    pre = c;
                    if (str.length - 1 == idx) {
                        shouldBreak = true;
                    }
                } else if (c != pre) {
                    isSame = false;
                }
            });
            if (isSame) {
                if (reversed) {
                    common = pre + common;
                } else {
                    common += pre;
                }
            }
            if (shouldBreak) {
                break;
            }
            idx += 1;
        }
        if (common == '' && !reversed) {
            print('套装名解析失败, id=$id, equip: ${names.join(',')}');
        }
        return common;
    }

    String getName() {
        if (names.length > 6) {
            // 共享套装 id 的不同套装
            var oldName = names[0].split('').first;
            var names1 = <String>[];
            var names2 = <String>[];
            names.forEach((n) {
                var c = n.split('').first;
                if (c == oldName) {
                    names1.add(n);
                } else {
                    names2.add(n);
                }
            });
            var processingNames1 = names1.map((n) => n.split('')).toList();
            var processingNames2 = names2.map((n) => n.split('')).toList();
            var prefix1 = getCommon(processingNames1, false);
            var surfix1 = getCommon(processingNames1, true);
            var prefix2 = getCommon(processingNames2, false);
            var surfix2 = getCommon(processingNames2, true);
            return '$prefix1$surfix1 / $prefix2$surfix2';
        }
        var processingNames = names.map((n) => n.split('')).toList();
        var prefix = getCommon(processingNames, false);
        var surfix = getCommon(processingNames, true);
        return '$prefix$surfix';
    }
}

class RawSet {
    int id;
    String name;
    int require2Effect1;
    int require2Effect2;
    int require3Effect1;
    int require3Effect2;
    int require4Effect1;
    int require4Effect2;
    int require5Effect1;
    int require5Effect2;
    int require6Effect1;
    int require6Effect2;
    RawSet.fromJson(Map<String, dynamic> json) {
        id = int.tryParse(json['ID']);
        name = json['Name'];
        require2Effect1 = int.tryParse(json['2_1']);
        require2Effect2 = int.tryParse(json['2_2']);
        require3Effect1 = int.tryParse(json['3_1']);
        require3Effect2 = int.tryParse(json['3_2']);
        require4Effect1 = int.tryParse(json['4_1']);
        require4Effect2 = int.tryParse(json['4_2']);
        require5Effect1 = int.tryParse(json['5_1']);
        require5Effect2 = int.tryParse(json['5_2']);
        require6Effect1 = int.tryParse(json['6_1']);
        require6Effect2 = int.tryParse(json['6_2']);
    }
}
