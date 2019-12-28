import 'package:j3pz_data_preprocessor/effect.dart';
import 'package:j3pz_data_preprocessor/set.dart';

class RawEquip {
    int id;
    String name;
    String uiID;
    String representID;
    String colorID;
    String colorID1;
    String colorID2;
    String genre;
    int subType;
    String detailType;
    String price;
    int level;
    String bindType;
    String maxDurability;
    String abradeRate;
    String maxExistTime;
    String maxExistAmount;
    String canTrade;
    String canDestroy;
    String setID;
    String scriptName;
    int quality;
    String base1Type;
    String base1Min;
    String base1Max;
    String base2Type;
    String base2Min;
    String base2Max;
    String base3Type;
    String base3Min;
    String base3Max;
    String base4Type;
    String base4Min;
    String base4Max;
    String base5Type;
    String base5Min;
    String base5Max;
    String base6Type;
    String base6Min;
    String base6Max;
    String require1Type;
    int require1Value;
    String require2Type;
    int require2Value;
    String require3Type;
    int require3Value;
    String require4Type;
    int require4Value;
    String require5Type;
    int require5Value;
    String require6Type;
    int require6Value;
    String magic1Type;
    String magic2Type;
    String magic3Type;
    String magic4Type;
    String magic5Type;
    String magic6Type;
    String magic7Type;
    String magic8Type;
    String magic9Type;
    String magic10Type;
    String magic11Type;
    String magic12Type;
    int skillID;
    int skillLevel;
    String belongSchool;
    String magicKind;
    String magicType;
    String getType;
    String sCATEGORY;
    String coolDownID;
    String iconTag1;
    String iconTag2;
    String isSpecialIcon;
    String isSpecialRepresent;
    String iconID;
    String canSetColor;
    String aucGenre;
    String aucSubType;
    String requireCamp;
    String requireProfessionID;
    String requireProfessionLevel;
    String requireProfessionBranch;
    String packageGenerType;
    String packageSubType;
    String targetType;
    String enchantRepresentID1;
    String enchantRepresentID2;
    String enchantRepresentID3;
    String enchantRepresentID4;
    String existType;
    String diamondTypeMask1;
    String diamondAttributeID1;
    String diamondTypeMask2;
    String diamondAttributeID2;
    String diamondTypeMask3;
    String diamondAttributeID3;
    String equipCoolDownID;
    String recommendID;
    String maxStrengthLevel;
    String canApart;
    String mapBanUseItemMask;
    String ignoreBindMask;
    String canExterior;
    String belongForceMask;
    String represent1;
    String specialRepair;
    String canChangeMagic;
    String growthTabIndex;
    String needGrowthExp;
    String canShared;
    String mapBanTradeItemMask;
    String mapCanExistItemMask;
    String mapBanEquipItemMask;
    String isPVEEquip;
    String repairPriceRebate;

    RawEquip.fromJson(Map<String, dynamic> json) {
        id = int.tryParse(json['ID']);
        name = json['Name'];
        uiID = json['UiID'];
        representID = json['RepresentID'];
        colorID = json['ColorID'];
        colorID1 = json['ColorID1'];
        colorID2 = json['ColorID2'];
        genre = json['Genre'];
        subType = int.tryParse(json['SubType']) ?? 0;
        detailType = json['DetailType'];
        price = json['Price'];
        level = int.tryParse(json['Level']) ?? 0;
        bindType = json['BindType'];
        maxDurability = json['MaxDurability'];
        abradeRate = json['AbradeRate'];
        maxExistTime = json['MaxExistTime'];
        maxExistAmount = json['MaxExistAmount'];
        canTrade = json['CanTrade'];
        canDestroy = json['CanDestroy'];
        setID = json['SetID'];
        scriptName = json['ScriptName'];
        quality = int.tryParse(json['Quality']) ?? 0;
        base1Type = json['Base1Type'];
        base1Min = json['Base1Min'];
        base1Max = json['Base1Max'];
        base2Type = json['Base2Type'];
        base2Min = json['Base2Min'];
        base2Max = json['Base2Max'];
        base3Type = json['Base3Type'];
        base3Min = json['Base3Min'];
        base3Max = json['Base3Max'];
        base4Type = json['Base4Type'];
        base4Min = json['Base4Min'];
        base4Max = json['Base4Max'];
        base5Type = json['Base5Type'];
        base5Min = json['Base5Min'];
        base5Max = json['Base5Max'];
        base6Type = json['Base6Type'];
        base6Min = json['Base6Min'];
        base6Max = json['Base6Max'];
        require1Type = json['Require1Type'];
        require1Value = int.tryParse(json['Require1Value']) ?? 0;
        require2Type = json['Require2Type'];
        require2Value = int.tryParse(json['Require2Value']) ?? 0;
        require3Type = json['Require3Type'];
        require3Value = int.tryParse(json['Require3Value']) ?? 0;
        require4Type = json['Require4Type'];
        require4Value = int.tryParse(json['Require4Value']) ?? 0;
        require5Type = json['Require5Type'];
        require5Value = int.tryParse(json['Require5Value']) ?? 0;
        require6Type = json['Require6Type'];
        require6Value = int.tryParse(json['Require6Value']) ?? 0;
        magic1Type = json['Magic1Type'];
        magic2Type = json['Magic2Type'];
        magic3Type = json['Magic3Type'];
        magic4Type = json['Magic4Type'];
        magic5Type = json['Magic5Type'];
        magic6Type = json['Magic6Type'];
        magic7Type = json['Magic7Type'];
        magic8Type = json['Magic8Type'];
        magic9Type = json['Magic9Type'];
        magic10Type = json['Magic10Type'];
        magic11Type = json['Magic11Type'];
        magic12Type = json['Magic12Type'];
        skillID = int.tryParse(json['SkillID']);
        skillLevel = int.tryParse(json['SkillLevel']);
        belongSchool = json['BelongSchool'];
        magicKind = json['MagicKind'];
        magicType = json['MagicType'];
        getType = json['GetType'];
        sCATEGORY = json['_CATEGORY'];
        coolDownID = json['CoolDownID'];
        iconTag1 = json['IconTag1'];
        iconTag2 = json['IconTag2'];
        isSpecialIcon = json['IsSpecialIcon'];
        isSpecialRepresent = json['IsSpecialRepresent'];
        iconID = json['IconID'];
        canSetColor = json['CanSetColor'];
        aucGenre = json['AucGenre'];
        aucSubType = json['AucSubType'];
        requireCamp = json['RequireCamp'];
        requireProfessionID = json['RequireProfessionID'];
        requireProfessionLevel = json['RequireProfessionLevel'];
        requireProfessionBranch = json['RequireProfessionBranch'];
        packageGenerType = json['PackageGenerType'];
        packageSubType = json['PackageSubType'];
        targetType = json['TargetType'];
        enchantRepresentID1 = json['EnchantRepresentID1'];
        enchantRepresentID2 = json['EnchantRepresentID2'];
        enchantRepresentID3 = json['EnchantRepresentID3'];
        enchantRepresentID4 = json['EnchantRepresentID4'];
        existType = json['ExistType'];
        diamondTypeMask1 = json['DiamondTypeMask1'];
        diamondAttributeID1 = json['DiamondAttributeID1'];
        diamondTypeMask2 = json['DiamondTypeMask2'];
        diamondAttributeID2 = json['DiamondAttributeID2'];
        diamondTypeMask3 = json['DiamondTypeMask3'];
        diamondAttributeID3 = json['DiamondAttributeID3'];
        equipCoolDownID = json['EquipCoolDownID'];
        recommendID = json['RecommendID'];
        maxStrengthLevel = json['MaxStrengthLevel'];
        canApart = json['CanApart'];
        mapBanUseItemMask = json['MapBanUseItemMask'];
        ignoreBindMask = json['IgnoreBindMask'];
        canExterior = json['CanExterior'];
        belongForceMask = json['BelongForceMask'];
        represent1 = json['Represent1'];
        specialRepair = json['SpecialRepair'];
        canChangeMagic = json['CanChangeMagic'];
        growthTabIndex = json['GrowthTabIndex'];
        needGrowthExp = json['NeedGrowthExp'];
        canShared = json['CanShared'];
        mapBanTradeItemMask = json['MapBanTradeItemMask'];
        mapCanExistItemMask = json['MapCanExistItemMask'];
        mapBanEquipItemMask = json['MapBanEquipItemMask'];
        isPVEEquip = json['IsPVEEquip'];
        repairPriceRebate = json['RepairPriceRebate'];
    }
}

class Equip {
    int id;
    String name;
    int icon;
    String category;
    int quality;
    String school;
    String primaryAttribute;
    int score = 0;
    int vitality = 0;
    int spirit = 0;
    int strength = 0;
    int agility = 0;
    int spunk = 0;
    int basicPhysicsShield = 0;
    int basicMagicShield = 0;
    int damageBase = 0;
    int damageRange = 0;
    int attackSpeed = 0;
    int physicsShield = 0;
    int magicShield = 0;
    int dodge = 0;
    int parryBase = 0;
    int parryValue = 0;
    int toughness = 0;
    int attack = 0;
    int heal = 0;
    int crit = 0;
    int critEffect = 0;
    int overcome = 0;
    int haste = 0;
    int hit = 0;
    int strain = 0;
    int huajing = 0;
    int threat = 0;
    Effect effect;
    EquipSet equipSet;
    String embed;
    int strengthen;
    // int source;
    bool deprecated;

    List<String> toList() {
        return [
            '$id',
            name,
            '$icon',
            category,
            '$quality',
            school,
            primaryAttribute,
            '$score',
            '$vitality',
            '$spirit',
            '$strength',
            '$agility',
            '$spunk',
            '$basicPhysicsShield',
            '$basicMagicShield',
            '$damageBase',
            '$damageRange',
            '$attackSpeed',
            '$physicsShield',
            '$magicShield',
            '$dodge',
            '$parryBase',
            '$parryValue',
            '$toughness',
            '$attack',
            '$heal',
            '$crit',
            '$critEffect',
            '$overcome',
            '$haste',
            '$hit',
            '$strain',
            '$huajing',
            '$threat',
            effect != null ? '${effect.id}' : '',
            embed,
            '$strengthen',
            equipSet != null ? '${equipSet.id}' : '',
            (deprecated ?? false) ? '1' : '0',
        ];
    }
}
