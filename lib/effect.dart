class Effect {
    int id;
    List<String> attribute = [];
    List<String> decorator = [];
    List<num> value = [];
    String trigger;
    String description;

    Effect({this.id, this.trigger, this.description});

    List<String> toList() {
        return [
            '$id',
            attribute.isNotEmpty ? attribute.join(',') : '',
            decorator.isNotEmpty ? decorator.join(',') : '',
            value.isNotEmpty ? value.join(',') : '',
            trigger,
            description,
        ];
    }
}
