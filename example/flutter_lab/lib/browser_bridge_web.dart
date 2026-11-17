import 'dart:js_interop';

@JS('globalThis.localStorage')
external _Storage get _storage;
extension type _Storage(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}
@JS('globalThis.document.documentElement')
external _RootElement get _rootElement;
extension type _RootElement(JSObject _) implements JSObject {
  external set lang(JSString value);
}
@JS('globalThis.open')
external JSAny? _open(JSString url, JSString target, JSString features);
String? readLanguage() {
  try {
    final value = _storage.getItem('decision-lab-language'.toJS)?.toDart;
    _rootElement.lang = (value == 'en' ? 'en' : 'pt-BR').toJS;
    return value;
  } catch (_) {
    return null;
  }
}

void saveLanguage(String language) {
  try {
    _rootElement.lang = (language == 'en' ? 'en' : 'pt-BR').toJS;
    _storage.setItem('decision-lab-language'.toJS, language.toJS);
  } catch (_) {/* Storage can be blocked by the browser. */}
}

bool openLink(String url) {
  _open(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);
  return true;
}
