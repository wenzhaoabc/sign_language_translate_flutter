import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sign_language/net/DataModel.dart';
import 'package:sign_language/res/colours.dart';

class SOSItemWidget extends StatefulWidget {
  const SOSItemWidget({Key? key, required this.sosItem}) : super(key: key);
  final SOSItem sosItem;

  @override
  State<SOSItemWidget> createState() => _SOSItemWidgetState();
}

class _SOSItemWidgetState extends State<SOSItemWidget> {
  void doNothing(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    bool isInDark = Theme.of(context).primaryColor == Colours.app_main;
    Color textColor = isInDark ? Colors.black : Colors.white;
    Color iconColor = isInDark ? Colors.grey : Colors.white;

    return Slidable(
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        // dragDismissible: false,

        // All actions are defined in the children parameter.
        children: [
          SlidableAction(
            onPressed: doNothing,
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: doNothing,
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        title: Text(
          widget.sosItem.title,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        subtitle: Text('tel : ${widget.sosItem.to}'),
        trailing: const Icon(
          Icons.call_outlined,
          size: 20,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
