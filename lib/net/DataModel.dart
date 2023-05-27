class WordItemInfo {
  String? img;
  String word;
  String? tags;
  String? description;
  String? notes;
  String? type;
  String? video;
  int? id;

  WordItemInfo(this.img, this.word, {this.tags, this.description, this.notes});

  WordItemInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        word = json['word'],
        img = json['img'],
        tags = json['tags'],
        description = json['description'],
        notes = json['notes'],
        type = json['type'],
        video = json['video'];
}

class ResponseBase<T> {
  int? code;
  String? msg;
  T? data;

  ResponseBase(this.code, this.msg, this.data);

  ResponseBase.fromJson(Map<String, dynamic> json) {
    code = int.parse(json['code'].toString());
    msg = json['msg'] as String?;
    if (json.containsKey('data')) {
      data = _generateOBJ<T>(json['data'] as Object?);
    }
  }

  T? _generateOBJ<O>(Object? json) {
    if (json == null) {
      return null;
    }
    if (T.toString() == 'String') {
      return json.toString() as T;
    } else if (T.toString() == 'User') {
      return User.fromJson(json as Map<String, dynamic>) as T;
    } else if (T.toString() == 'List<WordItemInfo>') {
      List<dynamic> list = json as List;
      List<WordItemInfo>? wordList = <WordItemInfo>[];
      for (var element in list) {
        wordList.add(WordItemInfo.fromJson(element));
      }
      return wordList as T;
    } else if (T.toString() == 'List<NewsItem>') {
      List<dynamic> list = json as List;
      List<NewsItem>? newsList = <NewsItem>[];
      for (var e in list) {
        newsList.add(NewsItem.fromJson(e));
      }
      return newsList as T;
    } else {
      // list类型数据
      print('list类型数据');
    }
  }
}

class User {
  final int id;
  final String phone;
  final String username;
  final String avatar;
  final DateTime created;

  User(this.id, this.phone, this.username, this.avatar, this.created);

  User.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id'].toString()),
        phone = json['phone'],
        username = json['username'],
        avatar = json['avatar'],
        created = DateTime.parse(json['created']);

  @override
  String toString() {
    return '{"id":$id,"phone":"$phone","username":"$username","avatar":"$avatar","created":"${created.toIso8601String()}"}';
  }
}

class SOSItem {
  late final String title;
  late final String content;
  late final String to;

  SOSItem(this.title, this.content, this.to);

  SOSItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        to = json['to'];

  @override
  String toString() {
    return '{"title":"$title","to":"$to","content":"$content"}';
  }
}

class NewsItem {
  late int id;
  late String title;
  late String author;
  String? content;
  late String image;
  late String created;

  NewsItem(
      this.id, this.title, this.author, this.content, this.image, this.created);

  NewsItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        author = json['author'],
        content = json['content'] ?? '',
        image = json['image'],
        created = json['created'];
}
