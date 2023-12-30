import 'dart:developer';

Stream<int> runToMax(int n) async* {
  int i = 0;
  while (i < n) {
    yield i;
    i++;
    await Future.delayed(Duration(seconds: 1));
  }
}

Stream<int> communicate() async* {
  await Future.delayed(const Duration(milliseconds: 5000));
  yield 3;

  // Stream.fromFuture(Future.delayed(const Duration(milliseconds: 500))).listen((value) async* {
  //   yield RemoveSquareSignal();
  // });    
}

void testRunToMax() async {

  Stream<int> j = runToMax(3);
  
  await Future.delayed(Duration(seconds: 5));

  j.listen((event) { 
    print(event);
  });

  await Future.delayed(Duration(seconds: 1));

  print("Done");

}

void testCommunicate() {

  print(Timeline.now);

  communicate().listen((event) {
    
    print(event);
    print(Timeline.now);

  });
}
void main() async {
  testCommunicate();
}