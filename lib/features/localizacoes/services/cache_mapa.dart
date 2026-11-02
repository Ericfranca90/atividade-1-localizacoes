import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheMapa {
  static Future<MapCachingProvider> preparar() async {
    final pastaPrivada = await getApplicationSupportDirectory();
    final pastaCache = Directory(p.join(pastaPrivada.path, 'cache_mapa'));
    await pastaCache.create(recursive: true);

    return BuiltInMapCachingProvider.getOrCreateInstance(
      cacheDirectory: pastaCache.path,
      maxCacheSize: 100 * 1024 * 1024,
    );
  }
}
