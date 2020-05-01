abstract class MapModel {
  const MapModel();

  Map<String, dynamic> toJson();
}

abstract class ListModel {
  const ListModel();

  List<dynamic> toList();
}
