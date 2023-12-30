import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/game.dart';

// Events

class SetNBackParametersEvent {
  NBackParameters params;
  GameTypes gt;
  SetNBackParametersEvent({required this.params, required this.gt});
}



// States
class NBackParameterState {
  NBackParameters params;
  GameTypes gt;
  NBackParameterState({required this.params, required this.gt});
}



class NBackParametersBloc extends Bloc<SetNBackParametersEvent, NBackParameterState> {
  NBackParametersBloc(super.initialState)  {
    on<SetNBackParametersEvent>(_handleNBackParameterEvent);
  }


  _handleNBackParameterEvent(SetNBackParametersEvent event, Emitter<NBackParameterState> emitter) {
    NBackParameterState out = NBackParameterState(params: event.params, gt: event.gt);
    emitter(out);
  }


}