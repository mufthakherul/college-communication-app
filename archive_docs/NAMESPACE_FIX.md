# Android Namespace Fix for Flutter Plugins

## Issue
When building the Android APK with Android Gradle Plugin (AGP) 8.1.0+, some Flutter plugins fail with the error:
```
Namespace not specified. Specify a namespace in the module's build file.
```

This occurs because AGP 8.0+ requires all Android modules to specify a `namespace` in their build.gradle file, but some older Flutter plugins don't include this.

## Affected Plugins
The following plugins in this project don't specify a namespace:
- `flutter_nearby_connections` (v1.1.2)
- `nearby_service` (v0.2.1)
- `qr_code_scanner` (v1.0.1)
- `flutter_webrtc` (v0.9.48)
- `workmanager` (v0.5.2)

## Solution
Added a configuration block in `apps/mobile/android/build.gradle` that automatically assigns namespaces to plugins that don't have one defined:

```gradle
subprojects { subproject ->
    afterEvaluate {
        if (subproject.plugins.hasPlugin('com.android.library')) {
            android {
                if (namespace == null) {
                    def pluginNamespaces = [
                        'flutter_nearby_connections': 'com.pkmnapps.flutter_nearby_connections',
                        'nearby_service': 'np.com.susanthapa.nearby_service',
                        'qr_code_scanner': 'net.touchcapture.qr.flutterqr',
                        'flutter_webrtc': 'com.cloudwebrtc.webrtc',
                        'workmanager': 'be.tramckrijte.workmanager'
                    ]
                    
                    if (pluginNamespaces.containsKey(subproject.name)) {
                        namespace pluginNamespaces[subproject.name]
                    }
                }
            }
        }
    }
}
```

## How It Works
1. The configuration uses `afterEvaluate` to check each subproject after Gradle evaluates it
2. For Android library plugins (`com.android.library`) without a namespace
3. It assigns the appropriate namespace based on the plugin name from the mapping
4. This allows third-party plugins to work with AGP 8.1.0+ without modifying plugin source code

## Namespace Mapping
The namespaces are derived from the plugins' package names:
- **flutter_nearby_connections**: Uses the package name from the plugin's original AndroidManifest.xml (`com.pkmnapps.flutter_nearby_connections`)
- **nearby_service**: Uses `np.com.susanthapa.nearby_service`
- **qr_code_scanner**: Uses `net.touchcapture.qr.flutterqr`
- **flutter_webrtc**: Uses `com.cloudwebrtc.webrtc`
- **workmanager**: Uses `be.tramckrijte.workmanager`

## Testing
After applying this fix, you should be able to build the APK successfully:
```bash
cd apps/mobile
flutter build apk --debug
```

## Alternative Solutions
If you encounter similar issues with other plugins:
1. Add the plugin name and namespace to the `pluginNamespaces` map in build.gradle
2. The namespace should match the package name from the plugin's AndroidManifest.xml
3. You can find the package name by checking the plugin source code or pub.dev

## Related Links
- [Android Gradle Plugin 8.0 Migration Guide](https://developer.android.com/build/releases/past-releases/agp-8-0-0-release-notes#namespace-dsl)
- [Namespace DSL Documentation](https://d.android.com/r/tools/upgrade-assistant/set-namespace)
