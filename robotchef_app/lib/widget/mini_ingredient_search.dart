import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/class/elastic_constants.dart';
import 'package:flutter_app/class/recipe_search.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:provider/provider.dart';

/// 재료 검색 및 추가를 위한 검색 widget
class MiniIngredientSearch extends StatefulWidget {
  List<String> ingredientList; // 선택한 식재료 리스트
  Function refresh;

  MiniIngredientSearch({@required this.ingredientList, @required this.refresh});

  @override
  _MiniIngredientSearchState createState() => _MiniIngredientSearchState();
}

class _MiniIngredientSearchState extends State<MiniIngredientSearch> {
  final TextEditingController _filter = TextEditingController();
  ScrollController _scrollController;
  bool _showAppbar = true;
  bool isScrollingDown = false;
  FocusNode focusNode = FocusNode();

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
          .search('ingredients-robotchef', '_doc', createQuery(),
              source: true, offset: 0, limit: fetchRow * (_lastRow + 1))
          .timeout(Duration(seconds: 5));
    } else {
      response = await client.search(
          'ingredients-robotchef', '_doc', Query.matchAll(),
          source: true,
          offset: 0,
          limit: fetchRow * (_lastRow + 1),
          sort: [
            {
              "name.sort": {"order": "asc"}
            }
          ]).timeout(Duration(seconds: 5));
    }
    print(response);

    await transport.close();

    return response;
  }

  Map<dynamic, dynamic> createQuery() {
    String _searchText = _filter.text;

    Map<dynamic, dynamic> query = {
      "bool": {
        "must": [
          {
            "match": {
              "name": {
                "query": _searchText,
                "analyzer": "korean_analyzer"
              }
            }
          }
        ]
      }
    };

    return query;
  }

  @override
  void initState() {
    super.initState();

    _initFilter();
    _scrollController = new ScrollController();
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

        _lastRow = 0;
        stream = newStream();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
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
        if (!snapshot.hasData) return GradientProgressIndicator(
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark
            ])
        );

        return _buildList(context, snapshot.data.hits);
      },
    );
  }

  // 재료 리스트
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

  // 재료 리스트 아이템을 만드는 부분
  Widget _buildListItem(BuildContext context, Doc data) {
    final ingredientData = data.doc;

    return IngredientChip(
      label: ingredientData['name'],
      ingredientList: widget.ingredientList,
      refresh: widget.refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AnimatedContainer(
              height: _showAppbar ? 56.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: AppBar(
                  automaticallyImplyLeading: false,
                  title: Container(
                    padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            focusNode: focusNode,
                            style: Theme.of(context).textTheme.bodyText1,
                            controller: _filter,
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white12,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.cancel),
                                color: Theme.of(context).iconTheme.color,
                                onPressed: () {
                                  setState(() {
                                    _filter.clear();
                                    focusNode.unfocus();
                                  });
                                },
                              ),
                              hintText: '검색',
                              labelStyle: Theme.of(context).textTheme.bodyText1,
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
                  iconTheme: Theme.of(context).iconTheme),
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

class IngredientChip extends StatefulWidget {
  String label;
  List<String> ingredientList;
  Function refresh;

  IngredientChip({@required this.label, @required this.ingredientList, @required this.refresh});

  @override
  _IngredientChipState createState() => _IngredientChipState();
}

class _IngredientChipState extends State<IngredientChip> {
  bool choosen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    choosen = widget.ingredientList.contains(widget.label);
    return InputChip(
      selected: choosen,
      label: Text(widget.label),
      onPressed: () {
        setState(() {
          choosen = !choosen;
          if(choosen){
            widget.ingredientList.add(widget.label);
            widget.refresh();
          }else{
            widget.ingredientList.remove(widget.label);
            widget.refresh();
          }
        });
      },
    );
  }
}
