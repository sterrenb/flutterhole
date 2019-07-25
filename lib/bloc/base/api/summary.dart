import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/service/pihole_client.dart';

class SummaryBloc extends BaseBloc<Summary> {
  SummaryBloc(BaseRepository<Summary> repository) : super(repository);
}

class SummaryRepository extends BaseRepository<Summary> {
  SummaryRepository(PiholeClient client) : super(client);

  @override
  Future<Summary> get() async {
    return client.fetchSummary();
  }
}
