import 'dart:js_util' as js_util;

bool isGoogleMapsJsAvailableImpl() {
  if (!js_util.hasProperty(js_util.globalThis, 'google')) {
    return false;
  }

  final google = js_util.getProperty<Object?>(js_util.globalThis, 'google');
  if (google == null) {
    return false;
  }

  return js_util.hasProperty(google, 'maps');
}
