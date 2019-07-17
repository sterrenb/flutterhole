import 'package:flutterhole_again/bloc/api_repository.dart';
import 'package:flutterhole_again/model/whitelist.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

class WhitelistRepository extends ApiRepository {
  final PiholeClient client;

  Whitelist _cache;

  Whitelist get cache => _cache;

  WhitelistRepository(this.client);

  Future<Whitelist> getWhitelist() async {
    _cache = await client.fetchWhitelist();
    return _cache;
  }

  Future<Whitelist> addToWhitelist(String domain) async {
    await client.addToWhitelist(domain);
    _cache = Whitelist.add(_cache, domain);
    return _cache;
  }

  Future<Whitelist> removeFromWhitelist(String domain) async {
    await client.removeFromWhitelist(domain);
    _cache = Whitelist(list: _cache.list..remove(domain));
    return _cache;
  }

  Future<Whitelist> editOnWhitelist(String original, String update) async {
    await client.removeFromWhitelist(original);
    await client.addToWhitelist(update);
    _cache = Whitelist(
        list: _cache.list
          ..remove(original)
          ..add(update));
    return _cache;
  }
}
