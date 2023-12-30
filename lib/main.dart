import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_back_application/n_back/controller.dart';
import 'package:n_back_application/n_back/game.dart';
import 'package:n_back_application/n_back/nback_block.dart';
import 'package:n_back_application/n_back/nback_parameters.dart';
import 'package:n_back_application/n_back/nback_states_bloc.dart';
import 'package:n_back_application/n_back/stat_displayer.dart';

// TODO: close all streams
//    close streamsubscribers through the `cancel` method

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestPage() // const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final NBackParameterState defaultParameters = 
  NBackParameterState(
    params: NBackParameters(
      generalParameters: GeneralNBackParameters(n: 1, trials: 20, trialLength: 2),
      modeParameters: [
        NBackAudioParameters(),
        NBackVisualParameters(percentOfTrialThatSquareShows: .50)
      ], 
    ),
    gt: GameTypes.both
  );


/// TODO: page for parameters
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) {
            return NBackParametersBloc(defaultParameters);
          }
        ),
        BlocProvider(
          create: (context) {
            NBackParameters params = context.read<NBackParametersBloc>().state.params;
            GameTypes gt = context.read<NBackParametersBloc>().state.gt;
            return NBackBlock(gt, params);
          },
        ),
        BlocProvider(
          create: (context) { 
            Game2 tg = context.read<NBackBlock>().timedGame;

            
            return NBackStatsBloc(
              NBackStatsStatistic(
                stats: tg.generateStatistics()
              ),
              context: context
            );
          }
        )
      ], child: const Column(children: [Controller(), StatDisplayer()]))
      // child: BlocProvider(
      //   create: (context) => NBackBlock(
      //     NotStartedGameState()
      //   ),
      //   child: Controller()//NBackGame(n: 1, trials: 20),,
      // )
      // child: FlashingSquare(),
    );
  }

}
