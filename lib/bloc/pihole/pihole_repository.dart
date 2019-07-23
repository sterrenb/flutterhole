import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/local_storage.dart';

class PiholeRepository {
  final LocalStorage localStorage;

  PiholeRepository(this.localStorage);

  Future<void> refresh() async {
    await localStorage.init();
    if (localStorage.cache.isEmpty) {
      await localStorage.reset();
    }
  }

  List<Pihole> getPiholes() {
    return localStorage.cache.values.toList();
  }

  Pihole active() {
    return localStorage.active();
  }

  Future<bool> add(Pihole pihole) async {
    return localStorage.add(pihole);
  }

  Future<bool> remove(Pihole pihole) async {
    return localStorage.remove(pihole);
  }

  Future<void> activate(Pihole pihole) async {
    await localStorage.activate(pihole);
  }

  Future<void> update(Pihole original, Pihole update) async {
    await localStorage.update(original, update);
  }

  Future<void> reset() async {
    await localStorage.reset();
  }
}
