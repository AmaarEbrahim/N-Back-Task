import 'dart:async';
import 'dart:developer';

/// How do streams behave when a listener is paused? My original
/// assumption was that streams would also pause, but the more I think about
/// this, the less it makes sense. From what I have read and what I
/// am beginning to understand about Streams -- that they pipe information
/// from a sink to drain, I believe that pausing a listener will not have
/// an effect on the stream it listens to. Pausing a listener simply 
/// deactivates the listener until it is resumed. 
///
/// The following test aims to confirm my new belief about streams.
/// 
/// Second:           0   1   2   3   4   5
/// Data:                 0   1   2   3   4
///                             ^       ^
///                             Pause   Resume
/// Original output       0   1           2   ...
/// belief
/// 
/// New output belief     0   1           4

int i = 0;

Stream<int> gen() async* {
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    yield i++;
  }
}

void main() async {



  // Stream<int> s = Stream.periodic(Duration(seconds: 1), (v) {
  //   return v;
  // });

  StreamSubscription ss = gen().listen((event) {
    int s = Timeline.now;
    int e = event;
    print("${s}, ${e}");
  });

  await Future.delayed(Duration(milliseconds: 2500));
  
  ss.pause();

  await Future.delayed(Duration(milliseconds: 2000));

  ss.resume();


}