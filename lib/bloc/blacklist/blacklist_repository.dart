import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/service/pihole_client.dart';

class BlacklistRepository extends ApiRepository {
  final PiholeClient client;

  Blacklist _cache;

  Blacklist get cache => _cache;

  BlacklistRepository(this.client);

  Future<Blacklist> getBlacklist() async {
    _cache = await client.fetchBlacklist();
    return _cache;
  }

  Future<Blacklist> addToBlacklist(BlacklistItem item) async {
    await client.addToBlacklist(item);
    _cache = Blacklist.withItem(_cache, item);
    return _cache;
  }

  Future<Blacklist> removeFromBlacklist(BlacklistItem item) async {
    await client.removeFromBlacklist(item);
    _cache = Blacklist.withoutItem(_cache, item);
    return _cache;
  }

  Future<Blacklist> editOnBlacklist(BlacklistItem original, BlacklistItem update) async {
    await client.removeFromBlacklist(original);
    await client.addToBlacklist(update);
    _cache = Blacklist.withoutItem(_cache, original);
    _cache = Blacklist.withItem(_cache, update);
    return _cache;
  }
}
