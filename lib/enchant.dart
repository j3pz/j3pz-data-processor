class RawEnchant {
    String id;
    String name;
    String uiid;
    String attriName;
    String attribute1Id;
    String attribute1Value1;
    String attribute1Value2;
    String diamondType1;
    String compare1;
    String diamondCount1;
    String diamondIntensity1;
    String attribute2Id;
    String attribute2Value1;
    String attribute2Value2;
    String diamondType2;
    String compare2;
    String diamondCount2;
    String diamondIntensity2;
    String attribute3Id;
    String attribute3Value1;
    String attribute3Value2;
    String diamondType3;
    String compare3;
    String diamondCount3;
    String diamondIntensity3;
    String scriptName;
    String attribute4Id;
    String attribute4Value1;
    String attribute4Value2;
    String representIndex;
    String representId;
    String time;
    String destItemSubType;
    String tabType;
    String tabIndex;
    String packageSize;
    String mapInvalidMask;
    String belongKungfuId;

    RawEnchant.fromJson(Map json) {
        id = json['ID'];
        name = json['Name'];
        uiid = json['UIID'];
        attriName = json['AttriName'];
        attribute1Id = json['Attribute1ID'];
        attribute1Value1 = json['Attribute1Value1'];
        attribute1Value2 = json['Attribute1Value2'];
        diamondType1 = json['DiamondType1'];
        compare1 = json['Compare1'];
        diamondCount1 = json['DiamondCount1'];
        diamondIntensity1 = json['DiamondIntensity1'];
        attribute2Id = json['Attribute2ID'];
        attribute2Value1 = json['Attribute2Value1'];
        attribute2Value2 = json['Attribute2Value2'];
        diamondType2 = json['DiamondType2'];
        compare2 = json['Compare2'];
        diamondCount2 = json['DiamondCount2'];
        diamondIntensity2 = json['DiamondIntensity2'];
        attribute3Id = json['Attribute3ID'];
        attribute3Value1 = json['Attribute3Value1'];
        attribute3Value2 = json['Attribute3Value2'];
        diamondType3 = json['DiamondType3'];
        compare3 = json['Compare3'];
        diamondCount3 = json['DiamondCount3'];
        diamondIntensity3 = json['DiamondIntensity3'];
        scriptName = json['ScriptName'];
        attribute4Id = json['Attribute4ID'];
        attribute4Value1 = json['Attribute4Value1'];
        attribute4Value2 = json['Attribute4Value2'];
        representIndex = json['RepresentIndex'];
        representId = json['RepresentID'];
        time = json['Time'];
        destItemSubType = json['DestItemSubType'];
        tabType = json['TabType'];
        tabIndex = json['TabIndex'];
        packageSize = json['PackageSize'];
        mapInvalidMask = json['MapInvalidMask'];
        belongKungfuId = json['BelongKungfuID'];
    }
}

class RawOther {
    String id;
    String name;
    String category;
    String uiId;
    String genre;
    String subType;
    String detailType;
    String quality;
    String price;
    String bindType;
    String maxExistTime;
    String maxExistAmount;
    String maxDurability;
    String canStack;
    String canConsume;
    String canTrade;
    String canDestroy;
    String scriptName;
    String skillId;
    String skillLevel;
    String level;
    String coolDownId;
    String requireLevel;
    String requireProfessionId;
    String requireProfessionBranch;
    String requireProfessionLevel;
    String requireGender;
    String canUseOnHorse;
    String canUseInFight;
    String canGoodCampUse;
    String canEvilCampUse;
    String canNeutralCampUse;
    String aucGenre;
    int aucSubType;
    String requireForce;
    String requireCamp;
    String targetType;
    String prefix;
    String postfix;
    String enchantId;
    String boxId;
    String existType;
    String mapBanUseItemMask;
    String ignoreBindMask;
    String belongForceMask;
    String canShared;
    String mapBanTradeItemMask;
    String mapCanExistItemMask;

    RawOther.fromJson(Map json) {
        id = json['ID'];
        name = json['Name'];
        category = json['_CATEGORY'];
        uiId = json['UiID'];
        genre = json['Genre'];
        subType = json['SubType'];
        detailType = json['DetailType'];
        quality = json['Quality'];
        price = json['Price'];
        bindType = json['BindType'];
        maxExistTime = json['MaxExistTime'];
        maxExistAmount = json['MaxExistAmount'];
        maxDurability = json['MaxDurability'];
        canStack = json['CanStack'];
        canConsume = json['CanConsume'];
        canTrade = json['CanTrade'];
        canDestroy = json['CanDestroy'];
        scriptName = json['ScriptName'];
        skillId = json['SkillID'];
        skillLevel = json['SkillLevel'];
        level = json['_LEVEL'];
        coolDownId = json['CoolDownID'];
        requireLevel = json['RequireLevel'];
        requireProfessionId = json['RequireProfessionID'];
        requireProfessionBranch = json['RequireProfessionBranch'];
        requireProfessionLevel = json['RequireProfessionLevel'];
        requireGender = json['RequireGender'];
        canUseOnHorse = json['CanUseOnHorse'];
        canUseInFight = json['CanUseInFight'];
        canGoodCampUse = json['CanGoodCampUse'];
        canEvilCampUse = json['CanEvilCampUse'];
        canNeutralCampUse = json['CanNeutralCampUse'];
        aucGenre = json['AucGenre'];
        aucSubType = int.tryParse(json['AucSubType']) ?? 0;
        requireForce = json['RequireForce'];
        requireCamp = json['RequireCamp'];
        targetType = json['TargetType'];
        prefix = json['Prefix'];
        postfix = json['Postfix'];
        enchantId = json['EnchantID'];
        boxId = json['BoxID'];
        existType = json['ExistType'];
        mapBanUseItemMask = json['MapBanUseItemMask'];
        ignoreBindMask = json['IgnoreBindMask'];
        belongForceMask = json['BelongForceMask'];
        canShared = json['CanShared'];
        mapBanTradeItemMask = json['MapBanTradeItemMask'];
        mapCanExistItemMask = json['MapCanExistItemMask'];
    }
}

class Enchant {
    int id;
    String name;
    String category;
    String description;
    String attribute;
    int value;
    String decorator;
    bool deprecated;

    Enchant({this.id, this.name, this.category});
    List<String> toList() {
        return ['$id', name, category, description, attribute, '$value', decorator, deprecated ? '1' : '0'];
    }

    Enchant clone(int newId) {
        var enchant = Enchant(id: newId, name: name, category: category);
        enchant.description = description;
        enchant.attribute = attribute;
        enchant.value = value;
        enchant.decorator = decorator;
        enchant.deprecated = deprecated;
        return enchant;
    }
}
