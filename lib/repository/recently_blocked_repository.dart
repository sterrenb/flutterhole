import 'package:flutterhole_again/service/pihole_client.dart';

import 'api_repository.dart';

class RecentlyBlockedRepository extends ApiRepository {
  final PiholeClient client;
  String _last = '';
  Map<String, int> _cache = {};

  Map<String, int> get cache => _cache;

  RecentlyBlockedRepository(this.client);

  Future<void> getRecentlyBlocked() async {
    final String domain = await client.fetchRecentlyBlocked();

    if (_last != domain) {
      _cache[domain] = _cache[domain] == null ? 1 : _cache[domain]++;
      _last = domain;
    }
  }
}
