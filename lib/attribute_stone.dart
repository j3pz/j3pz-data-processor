class AttributeStone {
    int id;
    String name;
    int level;
    int icon;
    bool deprecated;

    AttributeStone({this.id, this.name, this.level});

    List<String> toList() {
        return [
            '$id',
            name,
            '$icon',
            '$level',
            deprecated ? '1' : '0',
        ];
    }
}

class StoneAttribute {
    int id;
    String name;
    String decorator;
    String key;
    double value;
    int requiredQuantity;
    int requiredLevel;

    StoneAttribute({this.id, this.name});

    List<String> toList() {
        return [
            '$id',
            name,
            decorator,
            key,
            '$value',
            '$requiredQuantity',
            '$requiredLevel',
        ];
    }
}