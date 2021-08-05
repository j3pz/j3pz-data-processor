class RawItem {
    int id;
    int icon;
    String desc;

    RawItem.fromJson(Map<String, dynamic> json) {
        id = int.tryParse(json['ItemID']) ?? 0;
        icon = int.tryParse(json['IconID']) ?? 0;
        desc = json['Desc'];
    }
}