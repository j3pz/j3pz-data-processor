class Attribute {
    String iD;
    String value;
    String modifyType;
    String param1Min;
    String param1Max;
    String param2Min;
    String param2Max;
    String group1;
    String group2;
    String group3;
    String group4;
    String group5;
    String group6;
    String group7;
    String group8;
    String group9;
    String group10;

    Attribute.fromJson(Map<String, dynamic> json) {
        iD = json['ID'];
        value = json['Value'];
        modifyType = json['ModifyType'];
        param1Min = json['Param1Min'];
        param1Max = json['Param1Max'];
        param2Min = json['Param2Min'];
        param2Max = json['Param2Max'];
        group1 = json['Group1'];
        group2 = json['Group2'];
        group3 = json['Group3'];
        group4 = json['Group4'];
        group5 = json['Group5'];
        group6 = json['Group6'];
        group7 = json['Group7'];
        group8 = json['Group8'];
        group9 = json['Group9'];
        group10 = json['Group10'];
    }
}
