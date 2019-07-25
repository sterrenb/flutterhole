import 'package:flutterhole/bloc/generic/bloc.dart';
import 'package:flutterhole/bloc/generic/repository.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/service/pihole_client.dart';

class SummaryBloc extends GenericBloc<Summary> {
  SummaryBloc(GenericRepository<Summary> repository) : super(repository);
}

class SummaryRepository extends GenericRepository<Summary> {
  SummaryRepository(PiholeClient client) : super(client);

  @override
  Future<Summary> get() async {
    return client.Fetch();
  }
}
