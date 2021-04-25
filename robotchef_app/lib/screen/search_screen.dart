import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/class/elastic_constants.dart';
import 'package:flutter_app/class/recipe_search.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:flutter_app/screen/detail_screen.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/widget/RecipeCard.dart';
import 'package:provider/provider.dart';

// 검색 방법
// title:된장찌개,불고기 ingredient:오이,마늘

class SearchScreen extends StatefulWidget {
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _filter = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showAppbar = true;
  bool isScrollingDown = false;
  FocusNode focusNode = FocusNode();
  final Map<String, List<String>> tagDict = {"title": [], "ingredients": []};

  var _lastRow = 0;
  final fetchRow = 10;
  var stream;

  bool init = false;

  Future<SearchResult> newStream() async {
    final String url = ElasticConstants.endpoint;
    final transport = ConsoleHttpTransport(Uri.parse(url));
    final client = elastic.Client(transport);

    var response;

    if (_filter.text.isNotEmpty) {
      response = await client
          .search('recipe-robotchef', '_doc', createQuery(),
              source: true, offset: 0, limit: fetchRow * (_lastRow + 1))
          .timeout(Duration(seconds: 5));
    } else {
      response = await client.search(
          'recipe-robotchef', '_doc', Query.matchAll(),
          source: true,
          offset: 0,
          limit: fetchRow * (_lastRow + 1),
          sort: [
            {
              "title.sort": {"order": "asc"}
            }
          ]).timeout(Duration(seconds: 5));
    }
    print(response);

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
                      "analyzer": "korean_analyzer",
                      "operator": "and",
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
                      "analyzer": "korean_analyzer",
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

    _initFilter();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          stream = newStream();
        });
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });

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
              "($tag:)" + r"([a-z|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|0-9|\s]+,?)*(?=\s|$)");
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

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(() {});
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<SearchResult>(
      stream: Stream.fromFuture(stream),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error),
            ],
          ));
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.hits);
      },
    );
  }

  // 레시피 리스트
  Widget _buildList(BuildContext context, List<Doc> snapshots) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: snapshots.length,
      itemBuilder: (context, i) {
        final currentRow = (i + 1) ~/ fetchRow;
        if (_lastRow != currentRow) {
          _lastRow = currentRow;
        }
        return _buildListItem(context, snapshots[i]);
      },
      separatorBuilder: (context, i) => Divider(),
    );
  }

  // 레시피 리스트 아이템을 만드는 부분
  Widget _buildListItem(BuildContext context, Doc data) {
    final recipeData = Recipe.fromMap(data.doc);

    RecipeCard recipeCard = new RecipeCard(
        recipe: recipeData,
        onTapCard: () {
          Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) {
                return DetailScreen(
                  recipe: recipeData,
                  onPop: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return this.widget;
                        }));
                  },
                );
              }));
        });

    return recipeCard;
  }

  @override
  Widget build(BuildContext context) {
    if (!init) {
      RecipeSearcher searcher =
          Provider.of<RecipeSearcher>(context, listen: false);
      _filter.text = searcher.getSearchText();
      init = true;
    }

    List<String> _dynamicChips = [
      'Health',
      'Food',
      'Nature',
      'Health',
      'Food',
      'Nature',
      'Health',
      'Food',
      'Nature',
      'Health',
      'Food',
      'Nature',
      'Health',
      'Food',
      'Nature'
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              height: _showAppbar ? 112.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Column(
                children: <Widget>[
                  AppBar(
                      title: Container(
                        color: Color(0xFFABBB64),
                        padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                focusNode: focusNode,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                autofocus: true,
                                controller: _filter,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white12,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.cancel),
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        _filter.clear();
                                        focusNode.unfocus();
                                      });
                                    },
                                  ),
                                  hintText: '검색',
                                  labelStyle: TextStyle(color: Colors.black),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (BuildContext context) {
                                  return HomeScreen();
                                }));
                          }),
                      iconTheme: IconThemeData(color: Colors.white)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom:
                                BorderSide(width: 1, color: Colors.black12)),
                      ),
                      child: Row(
                        children: List<Widget>.generate(_dynamicChips.length, (index) {
                          return Chip(label: Text(_dynamicChips[index]),);
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
            ),
            Expanded(child: _buildBody(context))
          ],
        ),
      ),
    );
  }
}
