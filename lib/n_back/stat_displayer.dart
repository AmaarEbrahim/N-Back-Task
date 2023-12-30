import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/game.dart';
import 'package:n_back_application/n_back/nback_states_bloc.dart';

class StatDisplayer extends StatelessWidget {
  const StatDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NBackStatsBloc, NBackStatsStatistic>(builder: (ctx, state) {

      List<Widget> statisticsForEachMode = state.stats.map<Widget>((Stats2 stat) {
        return Column(children: [
            Text(stat.hits.toString()),
            Text(stat.misses.toString())
          ]);
      }).toList();

      return Column(
        children: statisticsForEachMode,
      );
    });
  }

}