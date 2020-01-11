class Source {
    int id;
    String type;
    String description;
    String redeem;
    String activity;
    bool limitedTime = false;
    Reputation reputation;
    Boss boss;

    Source({ this.id, this.type });

    List<String> toList() {
        return [
            '$id',
            type,
            description ?? '',
            activity ?? '',
            limitedTime ? '1' : '0',
            redeem ?? '',
        ];
    }
}

class Reputation {
    int id;
    String name;
    String level;
}

class Boss {
    int id;
    String name;
    GameMap map;
}

class GameMap {
    int id;
    String name;
}

class RawSource {
    String tabType;
    String id;
    String level;
    String aucGenre;
    String aucSubType;
    String name;
    String belongSchool;
    String setId;
    String magicKind;
    String magicType;
    String getType;
    String pvePvp;
    String getForce;
    String getDesc;
    String belongMapId;
    String prestigeRequire;

    RawSource.fromJson(Map<String, dynamic> json) {
        tabType = json['TabType'];
        id = json['ID'];
        level = json['Level'];
        aucGenre = json['AucGenre'];
        aucSubType = json['AucSubType'];
        name = json['Name'];
        belongSchool = json['BelongSchool'];
        setId = json['SetID'];
        magicKind = json['MagicKind'];
        magicType = json['MagicType'];
        getType = json['GetType'];
        pvePvp = json['PVE_PVP'];
        getForce = json['Get_Force'];
        getDesc = json['Get_Desc'];
        belongMapId = json['BelongMapID'];
        prestigeRequire = json['PrestigeRequire'];
    }
}
