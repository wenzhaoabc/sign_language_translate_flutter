import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/net/http.dart';
import 'package:sign_language/res/colours.dart';
import 'package:sign_language/widgets/LearnItemWidget.dart';
import 'package:sign_language/res/constant.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? searchText;
  List<WordItemInfo>? _wordList;

  bool isInDark() {
    return Theme.of(context).primaryColor == Colours.dark_app_main;
  }

  void _searchWords() {
    dio.get('/word_list?word=$searchText').then((value) {
      _wordList = ResponseBase<List<WordItemInfo>>.fromJson(value.data).data;
      setState(() {});
    }).catchError((res) => Fluttertoast.showToast(msg: '查询失败'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(Constant.bg_img_url),
            // image: AssetImage("images/R_C.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('搜索'),
            leading: Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: const NeumorphicBoxShape.circle(),
                depth: 3,
                color: isInDark() ? Colours.dark_app_main : Colours.app_main,
              ),
              margin: const EdgeInsets.all(8),
              child: IconButton(
                iconSize: 25,
                color: isInDark() ? Colors.green : Colors.green,
                icon: const Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            // backgroundColor:
            //     isInDark() ? Colours.dark_app_main : Colours.app_main,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Row(
                children: [
                  _getSearchBarUI(),
                  Neumorphic(
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: const NeumorphicBoxShape.circle(),
                        depth: 2,
                        color: isInDark()
                            ? Colours.dark_btn_bg
                            : Colours.app_main),
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: IconButton(
                      iconSize: 25,
                      icon: Icon(
                        Icons.search_outlined,
                        color: isInDark() ? Colours.dark_btn_icon : Colors.blue,
                      ),
                      onPressed: () {
                        if (searchText != null && searchText!.isNotEmpty) {
                          _searchWords();
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(child: _getLearnList())
            ],
          ),
          backgroundColor: Colors.transparent,
        ));
  }

  Widget _getSearchBarUI() {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Expanded(
        child: Container(
      // height: 40,
      margin: EdgeInsets.only(left: 20),
      // width: deviceWidth - 100,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Neumorphic(
                style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(
                      const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    depth: -5,
                    intensity: 0.75),
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 16),
                    border: InputBorder.none,
                    hintText: 'Some text...',
                  ),
                  onChanged: (String txt) {
                    searchText = txt;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _getLearnList() {
    var itemCount = (_wordList?.length) ?? 0;
    if (itemCount == 0 && searchText != null) {
      return Center(
        child: Column(
          children: const [
            Icon(Icons.error_outline, size: 50),
            Text('查询无果'),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return LearnItemWidget(_wordList![index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0,
          thickness: 0,
        );
      },
    );
  }
}
