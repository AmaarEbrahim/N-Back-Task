import 'dart:async';
import 'dart:developer';

void printW(Object? object) {
  print("${Timeline.now} - ${object}");
}

int i = 0;
Stream<int> communicate() async* {

  await Future.delayed(Duration(milliseconds: 500));

  // printW("RemoveSquareSignal");
  yield i++; 
}

void main() async {

    printW("start");

    // ss?.cancel();
    StreamSubscription? s;
    StreamSubscription s1 = Stream.periodic(Duration(seconds: 1)).listen((event) {

      printW("new period");

      s?.cancel();

      s = communicate().listen((event) {
        
        printW(event.toString());

      });

    });

    await Future.delayed(Duration(milliseconds: 1300));
    s1.pause();
    s?.pause();

    await Future.delayed(Duration(milliseconds: 300));
    s1.resume();
    s?.resume();

    await Future.delayed(Duration(milliseconds: 100));
    s1.cancel();
    s?.cancel();

}