import 'package:flutter/material.dart';
import 'card.dart';

/// This helper widget manages the scrollable content inside a picker widget.
class ScrollPicker<T extends Widget> extends StatefulWidget {
  ScrollPicker({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onSelectedTap,
    this.showDivider: false,
    this.onChanged,
  }) : super(key: key);

  // Events
  final ValueChanged<T>? onChanged;
  final void Function(T) onSelectedTap;

  // Variables
  final List<T> items;
  final T selectedItem;
  final bool showDivider;

  @override
  _ScrollPickerState createState() => _ScrollPickerState<T>(selectedItem);
}

class _ScrollPickerState<T extends Widget> extends State<ScrollPicker<T>> {
  _ScrollPickerState(this.selectedValue);

  // Constants
  static const double itemHeight = cardHeight;

  // Variables
  late double widgetHeight;
  late int numberOfVisibleItems;
  late int numberOfPaddingRows;
  late double visibleItemsHeight;
  late double offset;

  T selectedValue;

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    int initialItem = widget.items.indexOf(selectedValue);
    scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    TextStyle? defaultStyle = themeData.textTheme.bodyText2;
    TextStyle? selectedStyle = themeData.textTheme.headline5
        ?.copyWith(color: themeData.colorScheme.secondary);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        widgetHeight = constraints.maxHeight;

        return Stack(
          children: <Widget>[
            GestureDetector(
              onTapUp: _itemTapped,
              child: ListWheelScrollView.useDelegate(
                childDelegate: ListWheelChildBuilderDelegate(
                    builder: (BuildContext context, int index) {
                  if (index < 0 || index > widget.items.length - 1) {
                    return null;
                  }

                  var value = widget.items[index] as Widget;

                  return Center(
                    child: value,
                  );
                }),
                controller: scrollController,
                itemExtent: itemHeight,
                onSelectedItemChanged: _onSelectedItemChanged,
                physics: FixedExtentScrollPhysics(),
                // perspective: 0.001,
                // diameterRatio: 2,
                // useMagnifier: true,
                // magnification: 1.2,
              ),
            ),
            // Center(child: widget.showDivider ? Divider() : Container()),
            // GestureDetector(onTap: () => widget.onSelectedTap(widget.selectedItem), child: Divider(),),
            GestureDetector(
                onTap: () => widget.onSelectedTap(selectedValue),
                child: Center(
                    child: Container(
                  height: itemHeight,
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: widget.showDivider ? Border(
                      top: BorderSide(
                          color: themeData.colorScheme.secondary, width: 1.0),
                      bottom: BorderSide(
                          color: themeData.colorScheme.secondary, width: 1.0),
                    ) : null,
                  ),
                )))
          ],
        );
      },
    );
  }

  void _itemTapped(TapUpDetails details) {
    Offset position = details.localPosition;
    double center = widgetHeight / 2;
    double changeBy = position.dy - center;
    double newPosition = scrollController.offset + changeBy;

    // animate to and center on the selected item
    scrollController.animateTo(newPosition,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _onSelectedItemChanged(int index) {
    T newValue = widget.items[index];
    if (newValue != selectedValue) {
      selectedValue = newValue;
      if (widget.onChanged != null) {
        widget.onChanged!(newValue);
      }
    } else {
      widget.onSelectedTap(newValue);
    }
  }
}
