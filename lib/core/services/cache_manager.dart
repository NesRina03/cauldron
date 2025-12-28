import 'package:hive/hive.dart';
import '../../data/models/potion.dart';

enum CachePriority { low, medium, high, critical }

class CacheManager {
  // L1: Memory Cache (in-memory map)
  static final Map<String, CacheEntry> _memoryCache = {};
  // L2: Disk Cache (Hive boxes)
  static late Box<Map> recipeBox;
  static late Box<Map> _metadataBox;

  // Cache configuration
  static const int maxMemoryCacheSize = 50; // recipes
  static const int maxDiskCacheSize = 200; // recipes
  static const Duration cacheExpiry = Duration(days: 7);

  static Future<void> initialize() async {
    recipeBox = await Hive.openBox<Map>('recipe_cache');
    _metadataBox = await Hive.openBox<Map>('cache_metadata');
  }

  /// Get recipe with intelligent cache lookup
  static Future<Potion?> getRecipe(String recipeId) async {
    // L1: Check memory cache first (fastest)
    if (_memoryCache.containsKey(recipeId)) {
      final entry = _memoryCache[recipeId]!;
      if (!entry.isExpired()) {
        entry.incrementHitCount();
        return entry.potion;
      }
    }
    // L2: Check disk cache (Hive)
    if (recipeBox.containsKey(recipeId)) {
      final data = recipeBox.get(recipeId);
      final metadata = _getCacheMetadata(recipeId);
      if (!_isExpired(metadata['cachedAt'])) {
        final potion = Potion.fromJson(Map<String, dynamic>.from(data!));
        _addToMemoryCache(recipeId, potion, CachePriority.medium);
        _updateAccessMetadata(recipeId);
        return potion;
      }
    }
    // L3: Check bundled assets (starter recipes) - handled in RecipesDataSource
    // L4: Network fetch (handled in repository)
    return null;
  }

  static Future<void> cacheRecipe(
    Potion potion,
    CachePriority priority,
  ) async {
    final recipeId = potion.id;
    _addToMemoryCache(recipeId, potion, priority);
    if (priority == CachePriority.high || priority == CachePriority.critical) {
      await _cacheToDisk(recipeId, potion);
    }
  }

  static void _addToMemoryCache(
    String recipeId,
    Potion potion,
    CachePriority priority,
  ) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      _evictLRU();
    }
    _memoryCache[recipeId] = CacheEntry(
      potion: potion,
      cachedAt: DateTime.now(),
      priority: priority,
      accessCount: 0,
      lastAccessedAt: DateTime.now(),
    );
  }

  static void _evictLRU() {
    CacheEntry? lruEntry;
    String? lruKey;
    for (var entry in _memoryCache.entries) {
      if (entry.value.priority == CachePriority.critical) continue;
      if (lruEntry == null ||
          entry.value.lastAccessedAt.isBefore(lruEntry.lastAccessedAt)) {
        lruEntry = entry.value;
        lruKey = entry.key;
      }
    }
    if (lruKey != null) {
      _memoryCache.remove(lruKey);
    }
  }

  static Future<void> _cacheToDisk(String recipeId, Potion potion) async {
    if (recipeBox.length >= maxDiskCacheSize) {
      await _evictLFU();
    }
    await recipeBox.put(recipeId, potion.toJson());
    await _metadataBox.put(recipeId, {
      'cachedAt': DateTime.now().toIso8601String(),
      'accessCount': 0,
      'lastAccessedAt': DateTime.now().toIso8601String(),
      'priority': CachePriority.medium.index,
    });
  }

  static Future<void> _evictLFU() async {
    if (recipeBox.length < maxDiskCacheSize) return;
    String? lfuKey;
    int minAccessCount = 999999;
    for (var key in recipeBox.keys) {
      final metadata = _getCacheMetadata(key);
      final accessCount = metadata['accessCount'] ?? 0;
      final priority = CachePriority.values[metadata['priority'] ?? 0];
      if (priority == CachePriority.critical) continue;
      if (accessCount < minAccessCount) {
        minAccessCount = accessCount;
        lfuKey = key;
      }
    }
    if (lfuKey != null) {
      await recipeBox.delete(lfuKey);
      await _metadataBox.delete(lfuKey);
    }
  }

  static Map<String, dynamic> _getCacheMetadata(String recipeId) {
    final raw = _metadataBox.get(recipeId);
    if (raw == null) return <String, dynamic>{};
    return Map<String, dynamic>.from(raw);
  }

  static void _updateAccessMetadata(String recipeId) {
    final metadata = _getCacheMetadata(recipeId);
    metadata['accessCount'] = (metadata['accessCount'] ?? 0) + 1;
    metadata['lastAccessedAt'] = DateTime.now().toIso8601String();
    _metadataBox.put(recipeId, metadata);
  }

  static bool _isExpired(String? cachedAt) {
    if (cachedAt == null) return true;
    final cached = DateTime.parse(cachedAt);
    return DateTime.now().difference(cached) > cacheExpiry;
  }

  static Future<bool> isCached(String recipeId) async {
    return _memoryCache.containsKey(recipeId) ||
        recipeBox.containsKey(recipeId);
  }

  static Future<void> clearCache() async {
    _memoryCache.clear();
    await recipeBox.clear();
    await _metadataBox.clear();
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': recipeBox.length,
      'memoryCacheLimit': maxMemoryCacheSize,
      'diskCacheLimit': maxDiskCacheSize,
      'totalDataSaved': await _calculateCacheSize(),
    };
  }

  static Future<int> _calculateCacheSize() async {
    return recipeBox.length * 50000; // Rough estimate: 50KB per recipe
  }
}

class CacheEntry {
  final Potion potion;
  final DateTime cachedAt;
  final CachePriority priority;
  int accessCount;
  DateTime lastAccessedAt;

  CacheEntry({
    required this.potion,
    required this.cachedAt,
    required this.priority,
    required this.accessCount,
    required this.lastAccessedAt,
  });

  bool isExpired() {
    return DateTime.now().difference(cachedAt) > CacheManager.cacheExpiry;
  }

  void incrementHitCount() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }
}
