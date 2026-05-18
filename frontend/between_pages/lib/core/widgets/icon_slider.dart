import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconSlider extends StatefulWidget {
  final int maxRating;
  final ValueChanged<int> onRatingChanged;
  final IconData filledIcon;
  final IconData unfilledIcon;
  final Color activeColor;
  final Color inactiveColor;
  final int initialRating;

  const IconSlider({
    Key? key,
    this.maxRating = 5,
    required this.onRatingChanged,
    required this.filledIcon,
    required this.unfilledIcon,
    required this.activeColor,
    this.inactiveColor = Colors.grey,
    this.initialRating = 0,
  }) : super(key: key);

  @override
  _IconSliderState createState() => _IconSliderState();
}

class _IconSliderState extends State<IconSlider> {
  late int _currentRating;
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  void _updateRating(DragUpdateDetails details) {
    final RenderBox box = _containerKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.globalToLocal(details.globalPosition);
    final double iconWidth = box.size.width / widget.maxRating;
    final int newRating = (position.dx / iconWidth).clamp(0, widget.maxRating).ceil();

    if (newRating != _currentRating) {
      setState(() {
        _currentRating = newRating;
      });
      widget.onRatingChanged(_currentRating);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _containerKey,
      onHorizontalDragUpdate: _updateRating,
      onTapUp: (details) {
         // Allow tapping to select a rating as well
        final RenderBox box = _containerKey.currentContext!.findRenderObject() as RenderBox;
        final position = box.globalToLocal(details.globalPosition);
        final double iconWidth = box.size.width / widget.maxRating;
        final int newRating = (position.dx / iconWidth).clamp(0, widget.maxRating).ceil();
        setState(() {
          _currentRating = newRating;
        });
        widget.onRatingChanged(_currentRating);
        HapticFeedback.lightImpact();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.maxRating, (index) {
          return Icon(
            index < _currentRating ? widget.filledIcon : widget.unfilledIcon,
            color: index < _currentRating ? widget.activeColor : widget.inactiveColor,
            size: 32,
          );
        }),
      ),
    );
  }
}
