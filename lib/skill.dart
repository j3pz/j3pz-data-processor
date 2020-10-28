class RawSkillInfo {
    String skillId;
    String level;
    String iconId;
    String show;
    String combatShow;
    String formation;
    String formationCaster;
    String practiceId;
    String sortOrder;
    String remark;
    String name;
    String desc;
    String shortDesc;
    String specialDesc;
    String kungfuDesc;
    String helpDesc;
    String isShowInNewSkill;
    String canDrag;
    String skillRelyOnShow;
    String skillRelyOnNotShow;
    String isShowNotLearn;
    String isHotkeyExitWhenForget;
    String buff;
    String debuff;
    String blackList;
    String simpleDesc;
    String autoSelectTarget;

    RawSkillInfo.fromJson(Map<String, dynamic> json) {
        skillId = json['SkillID'];
        level = json['Level'];
        iconId = json['IconID'];
        show = json['Show'];
        combatShow = json['CombatShow'];
        formation = json['Formation'];
        formationCaster = json['FormationCaster'];
        practiceId = json['PracticeID'];
        sortOrder = json['SortOrder'];
        remark = json['Remark'];
        name = json['Name'];
        desc = json['Desc'];
        shortDesc = json['ShortDesc'];
        specialDesc = json['SpecialDesc'];
        kungfuDesc = json['KungfuDesc'];
        helpDesc = json['HelpDesc'];
        isShowInNewSkill = json['IsShowInNewSkill'];
        canDrag = json['CanDrag'];
        skillRelyOnShow = json['SkillRelyOnShow'];
        skillRelyOnNotShow = json['SkillRelyOnNotShow'];
        isShowNotLearn = json['IsShowNotLearn'];
        isHotkeyExitWhenForget = json['IsHotkeyExitWhenForget'];
        buff = json['Buff'];
        debuff = json['Debuff'];
        blackList = json['BlackList'];
        simpleDesc = json['SimpleDesc'];
        autoSelectTarget = json['AutoSelectTarget'];
    }
}
