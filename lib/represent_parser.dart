import 'package:j3pz_data_preprocessor/represent.dart';

class RepresentParser {
    Map<String, Represent> represents = {};
    Map<String, String> representToExterior;
    Map<String, String> exteriorToSet;

    RepresentParser({
        Map representToExterior,
        Map exteriorToSet,
        Map exteriorSet,
    }) {
        this.representToExterior = {};
        representToExterior.forEach((key, value) {
            this.representToExterior[key] = value['ID'];
        });

    }
}
