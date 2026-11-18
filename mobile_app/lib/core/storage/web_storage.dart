import 'web_storage_stub.dart'
    if (dart.library.html) 'web_storage_web.dart';

Map<String, String>? getWebStorage() => getWebLocalStorage();
