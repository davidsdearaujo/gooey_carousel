import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'side.dart';

import 'gooey_edge.dart';
import 'gooey_edge_clipper.dart';

class GooeyCarousel extends StatefulWidget {
  final List<Widget> children;
  final void Function(int index)? onIndexUpdate;

  GooeyCarousel({
    required this.children,
    this.onIndexUpdate,
  }) : super();

  @override
  GooeyCarouselState createState() => GooeyCarouselState();
}

class GooeyCarouselState extends State<GooeyCarousel>
    with SingleTickerProviderStateMixin {
  int _index = 0; // index of the base (bottom) child
  Offset? _dragOffset; // starting offset of the drag
  late double _dragDirection; // +1 when dragging left to right, -1 for right to left

    bool? _dragCompleted=false; // has the drag successfully resulted in a swipe
  bool get dragCompleted => _dragCompleted!;
  set dragCompleted(bool value) {
    _dragCompleted = value;
    if (value && widget.onIndexUpdate != null) {
      widget.onIndexUpdate!(_dragIndex);
    }
  }

    late int _dragIndex=0; // index of the top child

  late GooeyEdge _edge;
  late Ticker _ticker;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    _edge = GooeyEdge(count: 25);
    _ticker = createTicker(_tick)..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration duration) {
    _edge.tick(duration);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int l = widget.children.length;

    return GestureDetector(
        key: _key,
        onPanDown: (details) => _handlePanDown(details, _getSize()),
        onPanUpdate: (details) => _handlePanUpdate(details, _getSize()),
        onPanEnd: (details) => _handlePanEnd(details, _getSize()),
        child: Stack(
          children: <Widget>[
            widget.children[_index % l],
            _dragIndex == null
                ? SizedBox()
                : ClipPath(
                    child: widget.children[_dragIndex % l],
                    clipBehavior: Clip.hardEdge,
                    clipper: GooeyEdgeClipper(_edge, margin: 10.0),
                  ),
          ],
        ));
  }

  Size _getSize() {
    final RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    return box.size;
  }

  void _handlePanDown(DragDownDetails details, Size size) {
    if (_dragIndex != null && dragCompleted) {
      _index = _dragIndex;
    }
    _dragIndex = 0;
    _dragOffset = details.localPosition;
    dragCompleted = false;
    _dragDirection = 0;

    _edge.farEdgeTension = 0.0;
    _edge.edgeTension = 0.01;
    _edge.reset();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    double dx = details.globalPosition.dx - _dragOffset!.dx ;

    if (!_isSwipeActive(dx)) {
      return;
    }
    if (_isSwipeComplete(dx, size.width)) {
      return;
    }

    if (_dragDirection == -1) {
      dx = size.width + dx;
    }
    _edge.applyTouchOffset(Offset(dx, details.localPosition.dy), size);
  }

  bool _isSwipeActive(double dx) {
    // check if a swipe is just starting:
    if (_dragDirection == 0.0 && dx.abs() > 20.0) {
      _dragDirection = dx.sign;
      _edge.side = _dragDirection == 1.0 ? Side.left : Side.right;
      setState(() {
        _dragIndex = _index - _dragDirection.toInt();
      });
    }
    return _dragDirection != 0.0;
  }

  bool _isSwipeComplete(double dx, double width) {
    if (_dragDirection == 0.0) {
      return false;
    } // haven't started
    if (dragCompleted) {
      return true;
    } // already done

    // check if swipe is just completed:
    double availW = _dragOffset!.dx;
    if (_dragDirection == 1) {
      availW = width - availW;
    }
    double ratio = dx * _dragDirection / availW;

    if (ratio > 0.8 && availW / width > 0.5) {
      dragCompleted = true;
      _edge.farEdgeTension = 0.01;
      _edge.edgeTension = 0.0;
      _edge.applyTouchOffset();
    }
    return dragCompleted;
  }

  void _handlePanEnd(DragEndDetails details, Size size) {
    _edge.applyTouchOffset();
  }
}
