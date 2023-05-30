import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({Key? key, required this.newsItem}) : super(key: key);

  final NewsItem newsItem;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.newsItem.title),
        elevation: 1,
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          // color: Colors.
        ),
        child: Html(data: widget.newsItem.content),
      ),
    );
  }
}
