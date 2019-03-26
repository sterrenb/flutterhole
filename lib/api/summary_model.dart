class SummaryModel {
  static const String _totalQueriesTitle = 'dns_queries_today';
  static const String _queriesBlockedTitle = 'ads_blocked_today';
  static const String _percentBlockedTitle = 'ads_percentage_today';
  static const String _domainsOnBlocklistTitle = 'domains_being_blocked';

  final int totalQueries;
  final int queriesBlocked;
  final double percentBlocked;
  final int domainsOnBlocklist;

  SummaryModel(
      {this.totalQueries = 0,
      this.queriesBlocked = 0,
      this.percentBlocked = 0.0,
      this.domainsOnBlocklist = 0});

  static _stringToInt(String string) =>
      int.tryParse(string.replaceAll(',', '')) ?? 0;

  SummaryModel.fromJson(Map<String, dynamic> json)
      : totalQueries = _stringToInt(json[_totalQueriesTitle]),
        queriesBlocked = _stringToInt(json[_queriesBlockedTitle]),
        percentBlocked = double.parse(json[_percentBlockedTitle]),
        domainsOnBlocklist = _stringToInt(json[_domainsOnBlocklistTitle]);

  Map<String, dynamic> toJson() => {
        _totalQueriesTitle: totalQueries.toString(),
        _queriesBlockedTitle: queriesBlocked.toString(),
        _percentBlockedTitle: percentBlocked.toString(),
        _domainsOnBlocklistTitle: domainsOnBlocklist.toString(),
      };
}
