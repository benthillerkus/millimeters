import Cocoa
import FlutterMacOS

public class MillimetersPlugin: NSObject, FlutterPlugin {
  static var bounds: CGRect = CGRect.null
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "millimeters", binaryMessenger: registrar.messenger)
    let instance = MillimetersPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    NotificationCenter.default.addObserver(
    forName: NSNotification.Name(rawValue: "NSApplicationDidChangeScreenParametersNotification"),
    object: NSApplication.shared,
    queue: .main) { notification in
        let _bounds = CGDisplayBounds(CGMainDisplayID())
        if bounds != _bounds {
            bounds = _bounds
            channel.invokeMethod("updateResolution", arguments: bounds.size.dictionaryRepresentation)
        }
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "getSize":
      let size = CGDisplayScreenSize(CGMainDisplayID())
      result(size.dictionaryRepresentation)
    case "getResolution":
      MillimetersPlugin.bounds = CGDisplayBounds(CGMainDisplayID())
      result(MillimetersPlugin.bounds.size.dictionaryRepresentation)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
