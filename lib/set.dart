class EquipSet {
    int id;
    String name;

    EquipSet({ this.id, this.name });
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
