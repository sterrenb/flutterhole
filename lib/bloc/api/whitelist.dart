import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class Add extends BlocEvent {
  final String domain;

  Add(this.domain);

  @override
  List<Object> get props => [domain];
}

class Remove extends BlocEvent {
  final String domain;

  Remove(this.domain);

  @override
  List<Object> get props => [domain];
}

class Edit extends BlocEvent {
  final String original;
  final String update;

  Edit(this.original, this.update);

  @override
  List<Object> get props => [original, update];
}

class WhitelistBloc extends BaseBloc<Whitelist> {
  final WhitelistRepository whitelistRepository;

  WhitelistBloc(this.whitelistRepository) : super(whitelistRepository);

  Stream<BlocState> _add(String item) async* {
    try {
      final blacklist = await whitelistRepository.addToWhitelist(item);
      yield BlocStateSuccess<Whitelist>(blacklist);
    } on PiholeException catch (e) {
      yield BlocStateError<Whitelist>(e);
    }
  }

  Stream<BlocState> _remove(String item) async* {
    try {
      final blacklist = await whitelistRepository.removeFromWhitelist(item);
      yield BlocStateSuccess<Whitelist>(blacklist);
    } on PiholeException catch (e) {
      yield BlocStateError<Whitelist>(e);
    }
  }

  Stream<BlocState> _edit(String original, String update) async* {
    try {
      final blacklist =
      await whitelistRepository.editOnWhitelist(original, update);
      yield BlocStateSuccess<Whitelist>(blacklist);
    } on PiholeException catch (e) {
      yield BlocStateError<Whitelist>(e);
    }
  }

  @override
  Stream<BlocState> mapEventToState(
    BlocEvent event,
  ) async* {
    yield BlocStateLoading<Whitelist>();
    if (event is Fetch) yield* fetch();
    if (event is Add) yield* _add(event.domain);
    if (event is Remove) yield* _remove(event.domain);
    if (event is Edit) yield* _edit(event.original, event.update);
  }
}

class WhitelistRepository extends BaseRepository<Whitelist> {
  WhitelistRepository(PiholeClient client, {Whitelist initialValue})
      : _cache = initialValue ?? Whitelist(),
        super(client);

  Whitelist _cache;

  Whitelist get cache => _cache;

  @override
  Future<Whitelist> get() async {
    _cache = await client.fetchWhitelist();
    return _cache;
  }

  Future<Whitelist> addToWhitelist(String item) async {
    await client.addToWhitelist(item);
    _cache = Whitelist.withItem(_cache, item);
    return _cache;
  }

  Future<Whitelist> removeFromWhitelist(String item) async {
    await client.removeFromWhitelist(item);
    _cache = Whitelist.withoutItem(_cache, item);
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
