import 'package:flutter/material.dart';

class CommonResizable extends StatefulWidget {
  final Widget activeChild;
  final Widget passiveChild;
  final Axis direction;
  final double initialRatio;

  const CommonResizable({
    super.key,
    required this.activeChild,
    required this.passiveChild,
    this.direction = Axis.horizontal,
    this.initialRatio = 0.5,
  });

  @override
  State<CommonResizable> createState() => _CommonResizableState();
}

class _CommonResizableState extends State<CommonResizable> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.direction == Axis.horizontal) {
          final width = constraints.maxWidth;
          return Row(
            children: [
              SizedBox(width: width * _ratio, child: widget.activeChild),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _ratio += details.delta.dx / width;
                    _ratio = _ratio.clamp(0.1, 0.9);
                  });
                },
                child: Container(
                  width: 4,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.drag_handle, size: 12, color: Colors.grey)),
                ),
              ),
              Expanded(child: widget.passiveChild),
            ],
          );
        } else {
          final height = constraints.maxHeight;
          return Column(
            children: [
              SizedBox(height: height * _ratio, child: widget.activeChild),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _ratio += details.delta.dy / height;
                    _ratio = _ratio.clamp(0.1, 0.9);
                  });
                },
                child: Container(
                  height: 4,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.drag_handle, size: 12, color: Colors.grey)),
                ),
              ),
              Expanded(child: widget.passiveChild),
            ],
          );
        }
      },
    );
  }
}
