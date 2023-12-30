import 'package:flutter/material.dart';
import 'package:n_back_application/n_back/game.dart';

/// Displays the grid of squares and the square that needs to show
/// TODO: not essential -- accept grid size as parameter... maybe make a Settings BLoC
class NBackGameStateless extends StatelessWidget {

  final Locations? locationToDisplay;

  const NBackGameStateless({super.key, required this.locationToDisplay});

  @override
  Widget build(BuildContext context) {
    int? elementToShow = locationToDisplay?.index;

    List<Widget> columnChildren = [];

    for (int i = 0; i < 3; i++) {

      List<Widget> rowChildren = [];

      for (int j = 0; j < 3; j++) {
        bool showBox = (elementToShow is int) && (3 * i + j) == elementToShow;

        Widget? child = showBox ? Container(color: Colors.red,) : null;

        // TODO: not essential -- make grid look better
        Widget w = Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red)
          ),
          child: SizedBox(
            width: 10,
            height: 10,
            child: child,
          ),
        );

        rowChildren.add(w);
      }

      Widget row = Row(children: rowChildren);
      columnChildren.add(row);
    }

    return Column(children: columnChildren,);
  }

}