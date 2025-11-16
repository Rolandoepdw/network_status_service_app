/// Defines the possible network connectivity states of the application.
///
/// This enum provides a more granular status than a simple connected/disconnected
/// boolean, allowing for better user feedback and application behavior.
enum NetworkStatus {
  /// The initial state before any connectivity checks have been performed.
  uninitialized,

  /// No network interface (Wi-Fi or mobile data) is currently enabled or connected.
  /// This implies the user needs to enable a network connection on their device.
  disconnected,

  /// A network interface (Wi-Fi or mobile data) is enabled and connected,
  /// but there is no active internet access through it.
  /// (e.g., connected to a Wi-Fi network without internet, or mobile data with no service).
  noService,

  /// A network interface is enabled, connected, and has active internet access.
  connected,
}
