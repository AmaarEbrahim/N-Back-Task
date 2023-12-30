import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/game.dart';
import 'package:pausable_timer/pausable_timer.dart';

abstract class GameEvent {}

// store settings
/// TODO: non-essential: create heirarchy of gameevents
class StartGameSignal extends GameEvent {}

class PauseGameSignal extends GameEvent {}

class ResumeGameSignal extends GameEvent {}

class TickGameSignal extends GameEvent {}

class RemoveSquareSignal extends GameEvent {}

class AddSquareSignal extends GameEvent {}

// states: game running, game paused, game complete
abstract class GameState {
  Locations? squareToShow;

  GameState({this.squareToShow});
}
class NotStartedGameState extends GameState {
  NotStartedGameState(): super();
}
class RunningGameState extends GameState {
  RunningGameState({super.squareToShow});
}

class PausedGameState extends GameState {
  PausedGameState({super.squareToShow});
}
class CompleteGameState extends GameState {
  CompleteGameState(): super();

}

// each mode is associated with a subclass that communicates the new item that 
// the mode picked
abstract class ModeCommunicator {
  /// Creating a StreamSubscription from the Stream and then pausing and resuming that 
  /// StreamSubscriber must be done by the consumer of this method.
  StreamController<GameEvent> communicate2();

  pause();

  resume();
}

class VisualCommunicator extends ModeCommunicator {

  GeneralNBackParameters generalParameters;
  NBackVisualParameters visualParameters;

  PausableTimer? t;

  VisualCommunicator({required this.generalParameters, required this.visualParameters});

  @override
  StreamController<GameEvent> communicate2() {
    int milliseconds = (visualParameters.percentOfTrialThatSquareShows * generalParameters.trialLength * 1000).toInt();

    StreamController<GameEvent> m = StreamController();

    // show square signal
    m.add(AddSquareSignal());

    t = PausableTimer(Duration(milliseconds: milliseconds), () {
      m.add(RemoveSquareSignal());
    });

    t?.start();


    return m;
  }

  @override
  pause() {
    t?.pause();
  }

  @override
  resume() {
    t?.start();
    
  }
}



class AudioCommunicator extends ModeCommunicator {
  @override
  StreamController<GameEvent> communicate2() {

    return StreamController();
  }
  
  @override
  pause() {
    // throw UnimplementedError();
  }
  
  @override
  resume() {
    // throw UnimplementedError();
  }

}

class ModeInfo {
  Mode mode;
  ModeCommunicator communicator;

  ModeInfo({required this.mode, required this.communicator});
}
List<ModeInfo> generateModeInfo(GameTypes gt, NBackParameters params) {
  if (gt == GameTypes.audio) {
    return [
      ModeInfo(
        mode: AudioMode(domain: Letters.values, params: params.generalParameters),
        communicator: AudioCommunicator()
      )
    ];
  } else if (gt == GameTypes.visual) {
    return [
      ModeInfo(
        mode: VisualMode(domain: Locations.values, params: params.generalParameters), 
        communicator: VisualCommunicator(generalParameters: params.generalParameters, visualParameters: params.getModeParameter())
      )
    ];
  } else {
    return [
      ModeInfo(
        mode: AudioMode(domain: Letters.values, params: params.generalParameters),
        communicator: AudioCommunicator()
      ),
      ModeInfo(
        mode: VisualMode(domain: Locations.values, params: params.generalParameters), 
        communicator: VisualCommunicator(generalParameters: params.generalParameters, visualParameters: params.getModeParameter())
      )
    ];
  }  
}


/// A BLoC that makes it possible to control the flow of the entire game session,
/// while also outputting the squares that a UI component should show as the session
/// progresses.
class NBackBlock extends Bloc<GameEvent, GameState> {


  Game2 timedGame;
  List<ModeCommunicator> modeCommunicators;
  StreamSubscription? ss;

  Locations? locationToShow;

  /// Each ModeCommunicator in `this.modeCommunicators` returns a Stream when
  /// its `communicate` method is called. StreamSubscriptions spawned from
  /// those streams should be added to this list.
  Map<ModeCommunicator, StreamController> modeCommunicatorStreamSubscriptions = {};

  NBackBlock._(NBackParameters params, List<ModeInfo> mis)
    :
    timedGame = Game2(params: params, mapping: mis.map((e) => e.mode).toList()),
    modeCommunicators = mis.map((e) => e.communicator).toList(),
    super(NotStartedGameState())
    {
    on<StartGameSignal>(_handleStartGameSignal);
    on<PauseGameSignal>(_handlePauseGameSignal);
    on<ResumeGameSignal>(_handleResumeGameSignal);
    on<TickGameSignal>(_handleTickGameSignal);
    on<RemoveSquareSignal>(_handleRemoveSquare);
    on<AddSquareSignal>(_handleAddSquare);


  }

  factory NBackBlock(GameTypes gt, NBackParameters params) {
    List<ModeInfo> mis = generateModeInfo(gt, params);
    return NBackBlock._(params, mis);
  }

  Game2 getGame() {
    return timedGame;
  }


  _handleStartGameSignal(StartGameSignal ge, Emitter<GameState> output) {
    // create n-back game using settings
    // create timer
    // run timer and when timer ticks, call add
    // emit RunningGameState

    if (state is! NotStartedGameState) {
      debugPrint("The NBackBlock's state is not NotStartedGameState. It must be NotStartedGameState for it to begin!");
      return;
    }

    ss?.cancel();
    ss = Stream.periodic(Duration(seconds: timedGame.params.generalParameters.trialLength)).listen((event) {

      add(TickGameSignal());

    });


    output(RunningGameState(
      squareToShow: locationToShow
    ));
    

  }

  
  _handlePauseGameSignal(PauseGameSignal ge, Emitter<GameState> output) {
    // pause the timer
    // emit PausedGameState

    if (state is! RunningGameState) {
      debugPrint("The NBackBlock's state is not RunningGameState. It must be RunningGameState for it to run!");
      return;      
    }

    // pause the trial timer
    ss?.pause();

    // each StreamSubscription needs to be paused
    modeCommunicatorStreamSubscriptions.forEach((modeCommunicator, streamController) {
      debugPrint("Pausing - ${streamController.isPaused} - $modeCommunicator");
      modeCommunicator.pause();
      debugPrint("Pauses - ${streamController.isPaused} - $modeCommunicator");
    });

    output(PausedGameState(
      squareToShow: locationToShow
    ));
  }

  _handleResumeGameSignal(ResumeGameSignal ge, Emitter<GameState> output) {
    // resume the timer
    // emit RunningGameState

    if (state is! PausedGameState) {
      debugPrint("The NBackBlock's state is not PausedGameState. It must be PausedGameState for it to resume!");
      return;      
    }

    // timedGame?.ss.resume();
    ss?.resume();
    for (ModeCommunicator ss1 in modeCommunicatorStreamSubscriptions.keys) {
      ss1.resume();
    }

    output(RunningGameState(
      squareToShow: locationToShow
    ));
  }

  _handleTickGameSignal(TickGameSignal ge, Emitter<GameState> output) {

    debugPrint("Tick");

    // Each stream subscription must be canceled because they are only supposed
    // to last a single trial. _handleTickGameSignal signals the start of a new
    // trial.
    for (StreamController element in modeCommunicatorStreamSubscriptions.values) {
      element.close();
    }

    modeCommunicatorStreamSubscriptions.clear();

    // create the new StreamSubscriptions for this trial
    for (ModeCommunicator modeCommunicator in modeCommunicators) {
      StreamController sc = modeCommunicator.communicate2();
      sc.stream.listen((event) {
        debugPrint(event.toString());
        // Each ModeCommunicator sinks GameEvents that this BLoC is supposed to
        // queue up. 
        add(event);
      });
      modeCommunicatorStreamSubscriptions[modeCommunicator] = sc;
    }

    // after the ModeCommunicators have communicated visual and audio info to
    // the user, we will either move onto the next trial if there are trials
    // left, or signal the end of the game if there no trials are left.
    if (timedGame.trialsLeft > 0) {
      timedGame.advance();
      output(RunningGameState(
        squareToShow: locationToShow
      ));

    } else {

      // When the game is over, we must stop the StreamSubscription that is 
      // acting as a timer and signaling the start of each new trial.
      ss?.cancel();
      output(CompleteGameState());
    }
  

  }

  _handleRemoveSquare(RemoveSquareSignal ge, Emitter<GameState> output) {
    if (state is RunningGameState) {
      locationToShow = null;
      output(RunningGameState());
    }
  }

  _handleAddSquare(AddSquareSignal signal, Emitter<GameState> output) {
    if (state is RunningGameState) {
      VisualMode? m = timedGame.getModeFromGameModeEnum<VisualMode>();
      locationToShow = m?.lastItem();
      output(RunningGameState(squareToShow: locationToShow));
    }
  }

}