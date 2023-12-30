
// enum names are made from a character denoting the location's vertical position
// and a character denoting the location's horizontal position.
//
//  vertical positions: T (top), M (middle), B (bottom)
//  horizontal positions: L (left), C (center), R (right)
import 'dart:math';

enum Locations {
  tl, tc, tr,
  ml, mc, mr,
  bl, bc, br
}

enum Letters {
  a, b, c, d, e, f, g, h, i
}

class Stats2 {
  int hits;
  int misses;

  Stats2(this.hits, this.misses);
}


class GeneralNBackParameters {
  int trialLength;
  int n;
  int trials;  

  GeneralNBackParameters({required this.n, required this.trials, required this.trialLength}):
    assert(!trialLength.isNegative),
    assert(!n.isNegative),
    assert(!trialLength.isNegative);
}

class NBackParameters {

  GeneralNBackParameters generalParameters;
  List<ModeParameter> modeParameters;

  NBackParameters({required this.generalParameters, required this.modeParameters});

  T getModeParameter<T extends ModeParameter>() {
    return modeParameters.whereType<T>().first;
  }

} 
 
// mode-specific parameters
abstract class ModeParameter {}
class NBackVisualParameters extends ModeParameter {

  /// between 0 and 1
  double percentOfTrialThatSquareShows;

  NBackVisualParameters({required this.percentOfTrialThatSquareShows}):
    assert(percentOfTrialThatSquareShows > 0 && percentOfTrialThatSquareShows <= 1);

}

class NBackAudioParameters extends ModeParameter {}

// The purpose Session is to provide a method that checks
// whether there is an n-back match for the round of n-back
// that the user is currently on. The function checkMatch
// is supplied externally, so this class can be used to check
// matches for any modality -- either spatial or auditory.
class Session {
  void Function() checkMatch;
  bool alreadyCheckedMatch = false;


  Session({required this.checkMatch});

  signalMatch() {
    if (alreadyCheckedMatch == false) {
      checkMatch();
      alreadyCheckedMatch = true;
    }
  }

}

/// Mode chooses the next item to use in the trial for a certain N-back
/// mode. When the game runs, there will be a Mode instance for each of the
/// game's modes. For example, if the game uses spatial and audio modes,
/// there will be a Mode instance for spatial, and a Mode instance for audio.
/// Having one Mode instance per mode in the game ensures that in each trial
/// a randomly selected value will be chosen and showed/played for every
/// mode.
/// 
/// **Usage**
/// 
/// Instantiate, and specify the type of the values that can be picked 
/// through the generic parameter
/// 
/// Call `next()` when you want the instance to select and store the next 
/// random value.
/// 
/// Use `mostRecentSession` when you want to signal that the user believes
/// that there is a match.
/// 
/// Call `generateStatistics()` when you want to see the matches/hits. 
/// 
/// **Design**
/// 
/// Mode keeps track of a list of choosable values in this.domain. 
/// this.domain is a list whose elements belong to the class's generic
/// parameter, DomainType. 
/// 
/// Everytime `next()` is called, a new `Session` instance is created. The 
/// session lets you signal whether the user thinks there is a match. Using
/// the `Session` class like this is a new pattern that I am testing. The
/// advantage to it is that it encapsulates all information into a class
/// whose properties are *defined*. The alternative to this pattern is to
/// keep the properties that would have been in the Session inside of this
/// class. However, since these properties would not be set when this class 
/// is instantiated, every one of them would be *possibly undefined*. With
/// this pattern, only the Session instance is possibly undefined. Every
/// property inside of it is defined.
///    
class Mode<DomainType> {

  GameModes gm;
  List<DomainType> domain;
  List<DomainType> history = [];

  Session? mostRecentSession;

  int matches = 0;
  int misses = 0;

  GeneralNBackParameters params;

  DomainType? lastItem() {
    return history.isNotEmpty ? history.last : null;
  }

  Mode({required this.domain, required this.params, required this.gm}):
    assert(domain.isNotEmpty);

  void next() {
    int len = Locations.values.length;
    DomainType randomValue = domain[Random().nextInt(len)];
    history.add(randomValue);


    mostRecentSession = Session(checkMatch: () {

      // each trial adds a new item into `this.history`. When the user 
      // believes there is a match, we must get the item that showed up
      // N trials ago. For example, if I am playing dual 2-back, when
      // I say there is a match, the app must check the item displayed
      // 2 trials ago.
      //
      // To get the item displayed N trials ago, we look into `this.history`.
      // If not enough trials have occurred, it is possible that there
      // does not exist an item N trials ago. For example, I could play
      // dual 2-back and say there is a match on the first trial. A Dual
      // 2-back match requires at least 3 trials, so it is impossible for there
      // to be a match on the first trial.
      // When this happens, there is an automatic miss.
      // When there are enough trials, to get the item, we calculate the
      // index to look at in `this.history` through this equation
      //    index = history.length - n - 1
      //
      // Ex: suppose we're playing 3-back, and it is trial 5. The trial number
      // should correspond to the size of history because at the start of
      // every trial a new item is added to history. So, the item to check 
      // would be at index = 5 - 3 - 1 = 1. 
      //
      // This may be unintuitive. Why isn't index = 2? You would think it 
      // should be 2 because 5 - 3 is 2. This is not the case because array
      // indices start at 0, so we subtract 1 to account for that. Here's a 
      // visual:
      //    history:
      //      index   0       1       2       3       4
      //      value   item1   item2   item3   item4   item5
      // The index to check for each n-back:
      //      1-BACK                            ^
      //      2-BACK                    ^
      //      3-BACK            ^
      //
      // So, it actually makes sense for index = 1, and the equation
      // history.length - n - 1 is correct
      int indexOfLocationDisplayedNTrialsAgo = history.length - params.n - 1;

      if (indexOfLocationDisplayedNTrialsAgo >= 0) {
        DomainType locationToCheckAgainst = history[indexOfLocationDisplayedNTrialsAgo];

        bool thereWasAMatch = randomValue == locationToCheckAgainst;    

        if (thereWasAMatch) {
          matches++;
        } else {
          misses++;
        }
      } else {
        misses++;
      }


    });
  }

  Stats2 generateStatistics() {
    return Stats2(matches, misses);
  }

  Type getType() {
    return DomainType;
  }


}


class VisualMode extends Mode<Locations> {
  VisualMode({required super.domain, required super.params}): 
    super(gm: GameModes.visual);
}

class AudioMode extends Mode<Letters> {
  AudioMode({required super.domain, required super.params}): 
    super(gm: GameModes.audio);
}

enum GameTypes {
  audio, visual, both
}



enum GameModes {
  audio, visual
}



List<Mode> generateModeMap(GameTypes gt, NBackParameters params) {

  if (gt == GameTypes.audio) {
    return [AudioMode(domain: Letters.values, params: params.generalParameters)];
  } else if (gt == GameTypes.visual) {
    return [VisualMode(domain: Locations.values, params: params.generalParameters)];
  } else {
    return [
      AudioMode(domain: Letters.values, params: params.generalParameters),
      VisualMode(domain: Locations.values, params: params.generalParameters)
    ];
  }


}


/// Game2 contains the core functionality of n-back. Each modality of n-back
/// is stored in a Mode instance. To use, first instantiate this class while
/// passing the game's settings. Call `advance` to move onto the first trial.
/// Call `matchVisual` and `matchAudio` when the player believes there is
/// a visual or audio match. Call `advance` to move onto the next trial and
/// repeat.
///
/// **Design Considerations**
/// A proposed way to design this class was to store the visual and/or audio
/// Mode instances in a list. Since this game supports either visual, audio,
/// or both modalities, customizing the behavior of the game would be as
/// simple as creating a list that had either a visual Mode, an audio Mode, 
/// or both. When the player believes there is a match, they would call
/// a single method and pass in something (e.g. an enum or instance) to 
/// indicate the mode their match was for. For example, if the player
/// believed there was a visual match, their call may look like this:
/// 
///     
///     Game2Instance.match(ModalityType.Visual)
///     
/// 
/// The method to advance to the next trial would behave by looping
/// through the list of Mode instances and calling the `advance` or equivalent 
/// method to advance the trial for each mode. **However**, while this
/// approach is simple and can eliminate a lot of redundancy, the problem
/// is that the Mode class is generic. Its generic parameter specifies the
/// domain of the Mode instance, or list of valid values that the mode can
/// choose and store in its history. 
class Game2 {

  // For each element, the `gm` property of the `Mode` must be the same as the 
  //`GameModes` element that indexes it.
  List<Mode> mapping;
  NBackParameters params;

  int trialNum = 0;

  int get trialsLeft => params.generalParameters.trials - trialNum;

  Game2({required this.params, required this.mapping});
    // assert(mapIsValid(mapping));


  void advance() {
    if (trialsLeft > 0) {
      trialNum++;
      for (var value in mapping) {
        value.next();
      }
    }

  }

  void matchType(GameModes gm) {
    mapping.firstWhere((element) => element.gm == gm).mostRecentSession?.signalMatch();
    // mapping[gm]?.mostRecentSession?.signalMatch();
  }

  List<Stats2> generateStatistics() {
    return mapping.map((e) => e.generateStatistics()).toList();
    // return mapping.map((key, value) => MapEntry(key, value.generateStatistics()));
  }

  T? getModeFromGameModeEnum<T extends Mode<dynamic>>() {
    Iterable<T>? m = mapping.whereType<T>();
    return m.first;
  }

  bool supportsMode(GameModes gm) {
    return mapping.any((element) => element.gm == gm);
    // return mapping.fold<bool>(gm);
  }
  
}
