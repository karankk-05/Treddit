import 'package:flutter/material.dart';

class CollapsibleFAB extends StatefulWidget {

  final String label;
  final VoidCallback? onPressed;
final Icon iconlabel;
  const CollapsibleFAB({
    Key? key,
 required this.iconlabel,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CollapsibleFABState createState() => _CollapsibleFABState();
}

class _CollapsibleFABState extends State<CollapsibleFAB> {
  final ScrollController _scrollController = ScrollController();
  bool _showFAB = true;
  double _previousScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    // Add listener to scroll controller
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > _previousScrollOffset) {
      // User is scrolling down
      if (_showFAB) {
        setState(() {
          _showFAB = false;
        });
      }
    } else if (_scrollController.offset < _previousScrollOffset) {
      // User is scrolling up
      if (!_showFAB) {
        setState(() {
          _showFAB = true;
        });
      }
    }
    _previousScrollOffset = _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _showFAB ? 130 : 56,
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        backgroundColor: theme.secondaryContainer,
        icon: Padding(
          padding: _showFAB
              ? const EdgeInsets.only()
              : const EdgeInsets.only(left: 70),
          child: widget.iconlabel
        ),
        label: AnimatedOpacity(
          opacity: _showFAB ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Text(
            widget.label,
            style: TextStyle(
              color: theme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

