import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/whitelist.dart';
import 'package:flutterhole/service/pihole_client.dart';

class WhitelistRepository extends ApiRepository {
  final PiholeClient client;

  Whitelist _cache;

  Whitelist get cache => _cache;

  WhitelistRepository(this.client, {Whitelist initialValue}) {
    _cache = initialValue ?? Whitelist();
  }

  Future<Whitelist> getWhitelist() async {
    _cache = await client.fetchWhitelist();
    return _cache;
  }

  Future<Whitelist> addToWhitelist(String domain) async {
    await client.addToWhitelist(domain);
    _cache = Whitelist.withItem(_cache, domain);
    return _cache;
  }

  Future<Whitelist> removeFromWhitelist(String domain) async {
    await client.removeFromWhitelist(domain);
    _cache = Whitelist(_cache.list..remove(domain));
    return _cache;
  }

  Future<Whitelist> editOnWhitelist(String original, String update) async {
    await client.removeFromWhitelist(original);
    await client.addToWhitelist(update);
    _cache = Whitelist.withoutItem(_cache, original);
    _cache = Whitelist.withItem(_cache, update);
    return _cache;
  }
}
