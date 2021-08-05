class GameMap {
    int id;
    String name;

    GameMap({ this.id, this.name });

    List<String> toList() {
        return ['$id', name];
    }
}

class RawMap {
    int id;
    String name;
    String displayName;

    RawMap.fromJson(Map<String, dynamic> json) {
        id = int.tryParse(json['ID']);
        name = json['Name'];
        displayName = json['DisplayName'];
    }
}
