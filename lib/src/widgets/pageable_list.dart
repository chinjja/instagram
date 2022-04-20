import 'package:flutter/material.dart';

class PageableList extends StatefulWidget {
  const PageableList({
    Key? key,
    required this.onFetchMore,
    required this.itemBuilder,
    required this.itemCount,
    this.padding,
    this.separatorBuilder,
    this.reverse = false,
    this.header,
  }) : super(key: key);
  final Widget? header;
  final Future<dynamic> Function() onFetchMore;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool reverse;
  @override
  State<PageableList> createState() => _PageableListState();
}

class _PageableListState extends State<PageableList> {
  final controller = ScrollController();
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.offset >= controller.position.maxScrollExtent) {
        _fetchMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.itemCount + (widget.header != null ? 1 : 0);
    if (widget.separatorBuilder == null) {
      return ListView.builder(
        controller: controller,
        padding: widget.padding,
        itemCount: itemCount,
        itemBuilder: _itemBuilder,
      );
    }
    return ListView.separated(
      controller: controller,
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: _itemBuilder,
      separatorBuilder: widget.separatorBuilder!,
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (widget.header == null) {
      return widget.itemBuilder(context, index);
    } else {
      if (index == 0) {
        return widget.header!;
      } else {
        return widget.itemBuilder(context, index - 1);
      }
    }
  }

  void _fetchMore() async {
    if (_fetching) return;
    try {
      _fetching = true;
      await widget.onFetchMore();
    } finally {
      _fetching = false;
    }
  }
}
