class Represent {
    int id;
    String name;

    Represent({this.id, this.name});

    List<String> toList() {
        return [
            '$id',
            name,
        ];
    }
}

class RawRepresentInfo {
    String id;
    String forceId;
    String genre;
    int setId;
    String subType;
    String representId;
    String colorId;
    String represetId1;
    String iconId;
    String isInShop;
    String collectionNeedPiece;
    String collectionNeedMoney;
    String sevenDaysRewards;
    String permanentCoin;
    String startTime;
    String endTime;
    String discount;
    String disStartTime;
    String disEndTime;
    String disRoleTypeMask;
    String canFreeTryOn;
    String subSetId;
    String matchHair;

    RawRepresentInfo.fromJson(Map<String, dynamic> json) {
        id = json['ID'];
        forceId = json['ForceID'];
        genre = json['Genre'];
        setId = int.tryParse(json['SetID']);
        subType = json['SubType'];
        representId = json['RepresentID'];
        colorId = json['ColorID'];
        represetId1 = json['RepresetID1'];
        iconId = json['IconID'];
        isInShop = json['IsInShop'];
        collectionNeedPiece = json['CollectionNeedPiece'];
        collectionNeedMoney = json['CollectionNeedMoney'];
        sevenDaysRewards = json['7daysRewards'];
        permanentCoin = json['PermanentCoin'];
        startTime = json['StartTime'];
        endTime = json['EndTime'];
        discount = json['Discount'];
        disStartTime = json['DisStartTime'];
        disEndTime = json['DisEndTime'];
        disRoleTypeMask = json['DisRoleTypeMask'];
        canFreeTryOn = json['CanFreeTryOn'];
        subSetId = json['SubSetID'];
        matchHair = json['MatchHair'];
    }
}

class RepresentBox {
    String genre;
    String subGenre;
    String setId;
    String force;
    String genreName;
    String subGenreName;
    String setName;
    String helmId;
    String chestId;
    String bangleId;
    String waistId;
    String bootsId;
    String matchHair;

    RepresentBox.fromJson(Map<String, dynamic> json) {
        genre = json['Genre'];
        subGenre = json['SubGenre'];
        setId = json['Set'];
        force = json['Force'];
        genreName = getGenreName(genre);
        subGenreName = json['SubGenreName'];
        setName = json['SetName'];
        helmId = json['HelmID'];
        chestId = json['ChestID'];
        bangleId = json['BangleID'];
        waistId = json['WaistID'];
        bootsId = json['BootsID'];
        matchHair = json['MatchHair'];
    }

    String getGenreName(String genre) {
        switch (genre) {
            case '1': return '门派套装';
            case '2': return '势力套装';
            case '3': return '江湖套装';
        }
        return '';
    }
}
