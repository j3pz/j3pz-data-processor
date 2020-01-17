import 'package:j3pz_data_preprocessor/gamemap.dart';

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
            reputation != null ? '${reputation.id}' : '',
            boss != null ? '${boss.id}' : '',
        ];
    }
}

class Reputation {
    int id;
    String name;
    String level;

    Reputation({this.id, this.name, this.level});

    List<String> toList() {
        return ['$id', name, level];
    }
}

class Boss {
    int id;
    String name;
    GameMap map;

    Boss({this.id, this.name, this.map});

    List<String> toList() {
        return ['$id', name, map != null ? '${map.id}' : '0'];
    }
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

    RawSource.clone(RawSource raw) {
        tabType = raw.tabType;
        id = raw.id;
        level = raw.level;
        aucGenre = raw.aucGenre;
        aucSubType = raw.aucSubType;
        name = raw.name;
        belongSchool = raw.belongSchool;
        setId = raw.setId;
        magicKind = raw.magicKind;
        magicType = raw.magicType;
        getType = raw.getType;
        pvePvp = raw.pvePvp;
        getForce = raw.getForce;
        getDesc = raw.getDesc;
        belongMapId = raw.belongMapId;
        prestigeRequire = raw.prestigeRequire;
    }
}
