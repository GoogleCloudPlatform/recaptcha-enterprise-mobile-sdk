import Foundation
import Network

let NW_QUEUE = "NetworkMonitor"

// Utilities for network monitoring
final class NetworkUtils {
  /// Waits for a network connection using the appropriate method based on iOS version.
  static func waitForNetworkConnection(completion: @escaping () -> Void) {
    if #available(iOS 12, *) {
      let monitor = NWPathMonitor()

      // If already connected, return immediately
      if monitor.currentPath.status == .satisfied {
        completion()
      }

      monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
          monitor.cancel()
          completion()
        }
      }

      monitor.start(queue: DispatchQueue(label: NW_QUEUE))
    }
  }

  @available(iOS 13.0, *)
  static func waitForNetworkConnectionAsync() async {
    return await withCheckedContinuation { continuation in
      waitForNetworkConnection {
        continuation.resume()
      }
    }
  }
}
