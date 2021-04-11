import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/elastic_constants.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:flutter_app/screen/detail_screen.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/class/db_manager.dart';

class BookmarkScreen extends StatefulWidget {
  _BookmarkScreen createState() => _BookmarkScreen();
}

class _BookmarkScreen extends State<BookmarkScreen> {
  ScrollController _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  var _lastRow = 0;
  final FETCH_ROW = 10;
  var stream;
  bool isDisposed = true;

  Future<SearchResult> newStream() async {
    var recipe_id_list = await DBManager.Instance.GetAllData(AppConstants.bookmarkDoc);

    final String url = ElasticConstants.endpoint;
    final transport = ConsoleHttpTransport(Uri.parse(url));
    final client = elastic.Client(transport);

    var response;

    response = await client.search(
        'recipe', '_doc', createQuery(recipe_id_list),
        source: true,
        offset: 0,
        limit: FETCH_ROW * (_lastRow + 1),
        sort: [
          {
            "title.keyword": {"order": "asc"}
          }
        ]);

    await transport.close();

    return response;
  }

  Map<dynamic, dynamic> createQuery(recipe_id_list) {
    Map<dynamic, dynamic> query = {
      "bool": {
        "must": [
          {
            "match": {
              "recipe_id": {"query": "" + recipe_id_list.join(", ")}
            }
          }
        ]
      }
    };

    return query;
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void initState() {
    super.initState();
    stream = newStream();
  }

  _BookmarkScreen() {
    _lastRow = 0;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          stream = newStream();
        });
      }
    });
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<SearchResult>(
      stream: Stream.fromFuture(stream),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Icon(Icons.error),
          );
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.hits);
      },
    );
  }

  Widget _buildList(BuildContext context, List<Doc> snapshots) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: snapshots.length,
      itemBuilder: (context, i) {
        final currentRow = (i + 1) ~/ FETCH_ROW;
        if (_lastRow != currentRow) {
          _lastRow = currentRow;
        }
        return _buildListItem(context, snapshots[i]);
      },
      separatorBuilder: (context, i) => Divider(),
    );
  }

  Widget _buildListItem(BuildContext context, Doc data) {
    final recipe = Recipe.fromMap(data.doc);
    return InkWell(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(recipe.thumbnail,
                width: 100, height: 100, fit: BoxFit.fill),
            Expanded(
                child: Text(
              recipe.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black87),
            )),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return DetailScreen(recipe: recipe);
            }));
        print(recipe.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text('즐겨찾기  ', style: TextStyle(color: Colors.white)),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              iconTheme: IconThemeData(color: Colors.white)),
        body: Container(
            child: Column(
          children: <Widget>[
            Expanded(child: _buildBody(context)),
          ],
        )));
  }
}
