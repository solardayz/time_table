import 'package:flutter/material.dart';
import 'package:time_table/constants.dart';

import '../../constants.dart';

class AnimatedTabBarForUser extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(48.0);
  @override
  Widget build(BuildContext context) {
    final TabController tabController = DefaultTabController.of(context)!;
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          indicatorColor: Colors.red,
          tabs: List.generate(globalDays.length, (index) {
            bool selected = tabController.index == index;
            return Tab(
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: selected
                    ? TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
                    : TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black54),
                child: Text(globalDays[index]),
              ),
            );
          }),
        );
      },
    );
  }
}
