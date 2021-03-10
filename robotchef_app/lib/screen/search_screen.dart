import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/elastic_constants.dart';
import 'package:flutter_app/class/recipe_serach.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:flutter_app/screen/detail_screen.dart';
import 'package:provider/provider.dart';

// title:된장찌개,불고기 ingredient:오이,마늘

class SearchScreen extends StatefulWidget {
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _filter = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  final Map<String, List<String>> tagDict = {"title": [], "ingredients": []};

  var _lastRow = 0;
  final FETCH_ROW = 10;
  var stream;

  bool init = false;

  Future<SearchResult> newStream() async {
    final String url = ElasticConstants.endpoint;
    final transport = ConsoleHttpTransport(Uri.parse(url));
    final client = elastic.Client(transport);

    var response;

    if (_filter.text.isNotEmpty) {
      response = await client.search('recipe', '_doc', createQuery(),
          source: true, offset: 0, limit: FETCH_ROW * (_lastRow + 1));
    } else {
      response = await client.search('recipe', '_doc', Query.matchAll(),
          source: true,
          offset: 0,
          limit: FETCH_ROW * (_lastRow + 1),
          sort: [
            {
              "title.keyword": {"order": "asc"}
            }
          ]);
    }

    await transport.close();

    return response;
  }

  Map<dynamic, dynamic> createQuery() {
    Map<dynamic, dynamic> query = {
      "bool": {
        "must": tagDict["ingredients"].length > 0
            ? [
                {
                  "match": {
                    "ingredients.name": {
                      "query": tagDict["ingredients"].join(','),
                      "fuzziness": "AUTO"
                    }
                  }
                }
              ]
            : [
                {"match_all": {}}
              ],
        "should": tagDict["title"].length > 0
            ? [
                {
                  "match": {
                    "title": {
                      "query": tagDict["title"].join(','),
                      "fuzziness": "AUTO"
                    }
                  }
                }
              ]
            : [
                {"match_all": {}}
              ],
        "minimum_should_match": 1
      }
    };

    return query;
  }

  @override
  void initState() {
    super.initState();
    stream = newStream();
  }

  void _initFilter() {
    _filter.addListener(() {
      setState(() {
        String _searchText = _filter.text;

        for (String tag in tagDict.keys) {
          // 초기화
          tagDict[tag].clear();

          RegExp regExp = new RegExp(
              "(${tag}:)" + r"([a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|0-9|\s]+,?)*(?=\s|$)");
          Match match = regExp.firstMatch(_searchText);

          if (match != null) {
            regExp = new RegExp(r"([a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|0-9|\s]+)(?=,|$)");
            for (Match match in regExp.allMatches(match.group(0))) {
              tagDict[tag].add(match.group(0));
            }
            print("dict : " + tagDict[tag].toString());
          }

          // title 태그가 없으면
          if (match == null && tag == "title") {
            regExp = new RegExp(r"^([a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|0-9|\s]+)(?=\s|$)");
            match = regExp.firstMatch(_searchText);

            if (match != null) {
              tagDict["title"].add(match.group(0));
            }
          }
        }

        _lastRow = 0;
        stream = newStream();
      });
    });
  }

  _SearchScreenState() {
    _initFilter();
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
        if (snapshot.hasError) return Icon(Icons.error);
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
    if(!init) {
      RecipeSearcher searcher = Provider.of<RecipeSearcher>(context, listen: false);
      _filter.text = searcher.GetSearchText();
      init = true;
    }

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
            ),
            Container(
              color: Colors.black,
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: TextField(
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      autofocus: true,
                      controller: _filter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white12,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white60,
                          size: 20,
                        ),
                        suffixIcon: focusNode.hasFocus
                            ? IconButton(
                                icon: Icon(Icons.cancel),
                                onPressed: () {
                                  setState(() {
                                    _filter.clear();
                                    focusNode.unfocus();
                                  });
                                },
                              )
                            : Container(),
                        hintText: '검색',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }
}
