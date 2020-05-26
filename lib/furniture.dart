class Furniture {
    int id;
    int category;
    String name;
    int quality;
    int level;
    bool interact;
    String scaleRange;
    String source;
    String img;
    String desc;
    int limit;
    int price;
    int environment;
    int beauty;
    int practicality;
    int robustness;
    int fun;

    Furniture({ this.id, this.category, this.name });

    List<String> toList() {
        return [
            '$id',
            '$category',
            name,
            '$quality',
            '$level',
            interact != null ? '1' : '0',
            scaleRange.replaceAll(';', ','),
            source,
            img,
            desc,
            '$limit',
            '$price',
            '$environment',
            '$beauty',
            '$practicality',
            '$robustness',
            '$fun',
        ];
    }
}

class RawFurniture {
    int id;
    int levelLimit;
    int quality;
    int qualityLevel;
    int category1;
    int category2;
    int category3;
    int attribute1;
    int attribute2;
    int attribute3;
    int attribute4;
    int attribute5;
    int attribute6;
    int attribute7;
    int attribute8;
    int architecture;

    RawFurniture.fromJson(Map<String, dynamic> json) {
        id = int.tryParse(json['ID']);
        levelLimit = int.tryParse(json['LevelLimit']);
        quality = int.tryParse(json['Quality']);
        qualityLevel = int.tryParse(json['QualityLevel']);
        category1 = int.tryParse(json['Category1']);
        category2 = int.tryParse(json['Category2']);
        category3 = int.tryParse(json['Category3']);
        attribute1 = int.tryParse(json['Attribute1']);
        attribute2 = int.tryParse(json['Attribute2']);
        attribute3 = int.tryParse(json['Attribute3']);
        attribute4 = int.tryParse(json['Attribute4']);
        attribute5 = int.tryParse(json['Attribute5']);
        attribute6 = int.tryParse(json['Attribute6']);
        attribute7 = int.tryParse(json['Attribute7']);
        attribute8 = int.tryParse(json['Attribute8']);
        architecture = int.tryParse(json['Architecture']);
    }
}

class RawFurnitureInfo {
    int catag1Index;
    int catag2Index;
    int catag3Index;
    int furnitureType;
    int furnitureID;
    int brushModeCnt;
    String name;
    int quality;
    bool interact;
    String scaleRange;

    RawFurnitureInfo.fromJson(Map<String, dynamic> json) {
        catag1Index = int.tryParse(json['nCatag1Index']);
        catag2Index = int.tryParse(json['nCatag2Index']);
        catag3Index = int.tryParse(json['nCatag3Index']);
        furnitureType = int.tryParse(json['nFurnitureType']);
        furnitureID = int.tryParse(json['dwFurnitureID']);
        brushModeCnt = int.tryParse(json['nBrushModeCnt']);
        name = json['szName'];
        quality = int.tryParse(json['nQuality']);
        interact = int.tryParse(json['bInteract']) == 1;
        scaleRange = json['szScaleRange'];
    }
}

class RawFurnitureUi {
    String source;
    String img;

    RawFurnitureUi.fromJson(Map<String, dynamic> json) {
        source = json['szSource'];
        img = json['Path'];
    }
}
