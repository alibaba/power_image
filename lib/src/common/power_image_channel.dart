import 'power_image_request.dart';

List<Map<String, dynamic>?> encodeRequests(List<PowerImageRequest> requests) {
  List<Map<String, dynamic>?> encodedTasks = requests
      .map<Map<String, dynamic>?>(
          (PowerImageRequest request) => request.encode())
      .toList();
  return encodedTasks;
}

abstract class PowerImageChannelImpl {
  void setup();

  void startImageRequests(List<PowerImageRequest> requests);

  void releaseImageRequests(List<PowerImageRequest> requests);
}

class PowerImageChannel {

  PowerImageChannelImpl? impl;

  void setup() {
    impl!.setup();
  }

  void startImageRequests(List<PowerImageRequest> requests) async {
    impl!.startImageRequests(requests);
  }

  void releaseImageRequests(List<PowerImageRequest> requests) async {
    impl!.releaseImageRequests(requests);
  }
}
