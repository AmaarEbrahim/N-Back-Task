import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/game.dart';
import 'package:n_back_application/n_back/nback_block.dart';

// events
abstract class NBackStatsEvent {}
// class NBackMatchSpatial extends NBackStatsEvent {}
// class NBackMatchAudio extends NBackStatsEvent {}
class NBackMatch extends NBackStatsEvent {
  GameModes gm;

  NBackMatch({required this.gm});
}

// states
class NBackStatsStatistic {
  List<Stats2> stats;

  NBackStatsStatistic({required this.stats});
}

 
/// Uses `NBackStatsEvent` signals to say that there is a match on behalf of the
/// user. This match could either be a visual or audio match. After saying
/// that there is a match, this class outputs a `NBackStatsStatistic` with
/// the new statistics for the game session.
/// 
/// *How does this class pass on the message that the user is saying there is
/// a match?*
/// 
/// This class uses a `BuildContext` instance to retrieve a `NBackBlock`.
/// This class then tells the `NBackBlock` that the user says that there
/// is a match.
class NBackStatsBloc extends Bloc<NBackStatsEvent, NBackStatsStatistic> {

  BuildContext context;

  NBackStatsBloc(super.initialState, {required this.context}) {
    // on(_handleSpatial);
    // on(_handleAudio);
    on<NBackMatch>(_handleMatch);
  }

  void _handleMatch(NBackMatch event, Emitter<NBackStatsStatistic> emit) {
    Game2 game = BlocProvider.of<NBackBlock>(context).timedGame;
    if (game.supportsMode(event.gm)) {
      game.matchType(event.gm);
      emit(NBackStatsStatistic(stats: game.generateStatistics()));
    }
  }
  
}