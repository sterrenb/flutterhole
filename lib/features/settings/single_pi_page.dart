import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/grid.dart';
import 'package:flutterhole_web/features/settings/single_pi_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final singlePiProvider = StateProvider.autoDispose<Pi>((ref) => debugPis.first);

class SinglePiNotifier extends StateNotifier<Pi> {
  SinglePiNotifier(Pi initial) : super(initial);

  void update(Pi pi) => state = pi;

  void updateTitle(String title) {
    print('TODO update');
  }

  void updateColor(Color color) {
    print('TODO $color');

    state = state.copyWith(primaryColor: color);
  }
}

final singlePiProvider =
    StateNotifierProvider.family<SinglePiNotifier, Pi, Pi>((ref, initial) {
  print('returning notifier for ${initial.title}');
  return SinglePiNotifier(initial);
});

class SinglePiPage extends HookWidget {
  const SinglePiPage(
    this.initial, {
    Key? key,
  }) : super(key: key);

  final Pi initial;

  @override
  Widget build(BuildContext context) {
    // final pi = useProvider(singlePiProvider(initial));
    final expandJsonTile = useState(false);

    final pi = useProvider(singlePiProvider(initial));
    final n = context.read(singlePiProvider(initial).notifier);
    final titleController = useTextEditingController(text: pi.title);
    final baseUrlController = useTextEditingController(text: pi.baseUrl);
    final apiPathController = useTextEditingController(text: pi.apiPath);
    final apiPortController =
        useTextEditingController(text: initial.apiPort.toString());

    useEffect(() {
      print('updating title to ${titleController.text}');
      n.updateTitle(titleController.text);
      // n.update(pi.copyWith(title: titleController.text));
      // pi.state = state.copyWith(title: titleController.text);
    }, [titleController.text]);

    // useEffect(() {
    //   pi.state = state.copyWith(baseUrl: baseUrlController.text);
    // }, [baseUrlController.text]);
    //
    // useEffect(() {
    //   pi.state = state.copyWith(apiPath: apiPathController.text);
    // }, [apiPathController.text]);
    //
    // useEffect(() {
    //   pi.state =
    //       state.copyWith(apiPort: int.tryParse(apiPortController.text) ?? 80);
    // }, [apiPortController.text]);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: Text(pi.title),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: StaggeredGridView.count(
          crossAxisCount:
              (MediaQuery.of(context).orientation == Orientation.landscape)
                  ? 8
                  : 4,
          mainAxisSpacing: kGridSpacing,
          crossAxisSpacing: kGridSpacing,
          padding: const EdgeInsets.all(kGridSpacing),
          staggeredTiles: [
            StaggeredTile.extent(4, kToolbarHeight * 2),
            StaggeredTile.count(4, 1),
            StaggeredTile.extent(4, kToolbarHeight),
            StaggeredTile.count(2, 1),
            StaggeredTile.count(2, 2),
            StaggeredTile.count(2, 1),
            StaggeredTile.count(4, 1),
            StaggeredTile.extent(4, kToolbarHeight),
            StaggeredTile.count(2, 2),
            expandJsonTile.value
                ? StaggeredTile.fit(2)
                : StaggeredTile.count(2, 2),
            StaggeredTile.count(1, 1),
            StaggeredTile.count(1, 1),
            StaggeredTile.count(4, 1),
          ],
          children: [
            Container(),
            Card(
              color: pi.primaryColor,
              child: TileTextField(
                controller: titleController,
                style: Theme.of(context).textTheme.headline5,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                hintText: 'Title',
              ),
            ),
            const GridSectionHeader('Host settings', KIcons.host),
            Card(
              child: TileTextField(
                controller: baseUrlController,
                style: Theme.of(context).textTheme.headline6,
                keyboardType: TextInputType.url,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                hintText: 'Base URL',

                // keyboardType: TextInputType.text,
                // minLines: 1,
                // maxLines: 1,
              ),
            ),
            Card(
              child: TileTextField(
                controller: apiPortController,
                style: Theme.of(context).textTheme.headline6,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                hintText: 'API port',

                // keyboardType: TextInputType.text,
                // minLines: 1,
                // maxLines: 1,
              ),
            ),
            Card(
              child: TileTextField(
                controller: apiPathController,
                style: Theme.of(context).textTheme.headline6,
                keyboardType: TextInputType.url,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                hintText: 'API path',

                // keyboardType: TextInputType.text,
                // minLines: 1,
                // maxLines: 1,
              ),
            ),
            Center(
              child: Text(
                pi.baseApiUrl,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            const GridSectionHeader('Customization', KIcons.customization),
            PrimaryColorCard(pi.primaryColor, (selected) {
              n.updateColor(selected);
            }),
            CodeCard(
              pi.toString(),
              tappable: false,
              expanded: false,
              onTap: () {},
            ),
            Card(),
            Card(),
            Container(),
          ],
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
