import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/secure_store.dart';

class PiholeRepository {
  final SecureStore secureStore;

  PiholeRepository(this.secureStore);

  Pihole active() {
    assert(secureStore.active != null);
    return secureStore.active;
  }

  List<Pihole> getPiholes() {
    return secureStore.piholes.values.toList();
  }

  Future<void> add(Pihole pihole) async {
    return secureStore.add(pihole);
  }

  Future<void> remove(Pihole pihole) async {
    return secureStore.remove(pihole);
  }

  Future<void> activate(Pihole pihole) async {
    await secureStore.activate(pihole);
  }

  Future<void> update(Pihole original, Pihole update) async {
    await secureStore.update(original, update);
  }

  Future<void> reset() async {
    await secureStore.deleteAll();
    await secureStore.add(Pihole());
    await secureStore.reload();
  }
}
