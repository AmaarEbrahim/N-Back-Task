import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/game.dart';
import 'package:n_back_application/n_back/n_back_game.dart';
import 'package:n_back_application/n_back/nback_block.dart';
import 'package:n_back_application/n_back/nback_states_bloc.dart';


/// ControllerState is a widget that (1) listens to keypresses to control the
/// flow of the game and indicate matches, and (2) shows the gameboard
/// (NBackGameStateless)
/// 
/// **Design**
/// 
/// To listen to keypresses, ControllerState attaches a listener to a subproperty
/// of the ServicesBinding singleton. This listener is invoked when a key
/// is pressed. The listener reads the key press to determine what action to
/// take. It accesses three BLoCs -- NBackBlock, NBackStatsBloc, and
/// NBackParametersBloc.
/// 
/// **Potential Changes**
/// 
/// Right now ControllerState is the state of a widget. Should a 
/// non-widget class listen to keypress events instead? The `context`
/// property can be supplied to the non-widget class if it is made
/// using BlocProvider.
/// 
class ControllerState extends State<Controller> {


  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKeyPress);
  }

  bool _onKeyPress(KeyEvent ke) {

    NBackBlock f = BlocProvider.of<NBackBlock>(context);
    NBackStatsBloc statsBloc = BlocProvider.of<NBackStatsBloc>(context);

    if (ke is KeyDownEvent) {
      if (ke.logicalKey.keyLabel == "A") {
        if (f.state is NotStartedGameState) {
          f.add(StartGameSignal());
        } else if (f.state is RunningGameState) {
          f.add(PauseGameSignal());
        } else if (f.state is PausedGameState) {
          f.add(ResumeGameSignal());
        }

      } else if (ke.logicalKey.keyLabel == "Q") {

        statsBloc.add(NBackMatch(gm: GameModes.visual));

      }
    }

    return false;

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NBackBlock, GameState>(builder: (ctx, state) {
      return NBackGameStateless(locationToDisplay: state.squareToShow);
    });
  }

}

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<StatefulWidget> createState() {
    return ControllerState();
  }

}