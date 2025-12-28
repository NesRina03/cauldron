import 'package:hive/hive.dart';
import '../../data/models/potion.dart';
import '../../data/models/mood.dart';

enum CachePriority { low, medium, high, critical }

class CacheManager {
  // L1: Memory Cache (in-memory map)
  static final Map<String, CacheEntry> _memoryCache = {};

  // L2: Disk Cache (Hive boxes)
  static late Box<Map> _recipeBox;
  static late Box<Map> _metadataBox;

  // Cache configuration
  static const int maxMemoryCacheSize = 50; // recipes
  static const int maxDiskCacheSize = 200; // recipes
  static const Duration cacheExpiry = Duration(days: 7);

  static Future<void> initialize() async {
    // await Hive.initFlutter(); // Only needed in Flutter main/init, not here
    _recipeBox = await Hive.openBox<Map>('recipe_cache');
    _metadataBox = await Hive.openBox<Map>('cache_metadata');
  }

  // ═══════════════════════════════════════════════════════════
  // INTELLIGENT CACHING - THE COMPETITION WINNER
  // ═══════════════════════════════════════════════════════════

  /// Get recipe with intelligent cache lookup
  static Future<Potion?> getRecipe(String recipeId) async {
    // L1: Check memory cache first (fastest)
    if (_memoryCache.containsKey(recipeId)) {
      final entry = _memoryCache[recipeId]!;
      if (!entry.isExpired()) {
        print('L1 CACHE HIT: $recipeId (Memory)');
        entry.incrementHitCount();
        return entry.potion;
      }
    }

    // L2: Check disk cache (Hive)
    if (_recipeBox.containsKey(recipeId)) {
      final data = _recipeBox.get(recipeId);
      final metadata = _getCacheMetadata(recipeId);

      if (!_isExpired(metadata['cachedAt'])) {
        print('L2 CACHE HIT: $recipeId (Disk)');
        final potion = Potion.fromJson(Map<String, dynamic>.from(data!));

        // Promote to memory cache
        _addToMemoryCache(recipeId, potion, CachePriority.medium);
        _updateAccessMetadata(recipeId);

        return potion;
      }
    }

    // L3: Check bundled assets (starter recipes)
    // Handled separately in RecipesDataSource.loadRecipes()

    print('CACHE MISS: $recipeId (Need network fetch)');
    return null;
  }

  /// Cache a recipe with priority-based strategy
  static Future<void> cacheRecipe(
    Potion potion,
    CachePriority priority,
  ) async {
    final recipeId = potion.id;

    // L1: Add to memory cache
    _addToMemoryCache(recipeId, potion, priority);

    // L2: Persist to disk based on priority
    if (priority == CachePriority.high || priority == CachePriority.critical) {
      await _cacheToDisk(recipeId, potion);
    }

    print('CACHED: $recipeId (Priority: ${priority.name})');
  }

  /// Predictive caching based on user patterns
  static Future<void> predictiveCache(
    List<String> recipeIds,
    CachePriority priority,
  ) async {
    print('PREDICTIVE CACHE: Prefetching ${recipeIds.length} recipes');

    for (var id in recipeIds) {
      // Check if already cached
      if (!await isCached(id)) {
        // Fetch and cache in background
        // This would call your API service
        print('   → Prefetching: $id');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CACHE EVICTION STRATEGIES
  // ═══════════════════════════════════════════════════════════

  /// LRU (Least Recently Used) eviction for memory cache
  static void _addToMemoryCache(
    String recipeId,
    Potion potion,
    CachePriority priority,
  ) {
    // If cache is full, evict LRU entry
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

  /// Evict least recently used item (but protect high-priority)
  static void _evictLRU() {
    CacheEntry? lruEntry;
    String? lruKey;

    for (var entry in _memoryCache.entries) {
      // Don't evict critical priority items
      if (entry.value.priority == CachePriority.critical) continue;

      if (lruEntry == null ||
          entry.value.lastAccessedAt.isBefore(lruEntry.lastAccessedAt)) {
        lruEntry = entry.value;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _memoryCache.remove(lruKey);
      print('EVICTED (LRU): $lruKey');
    }
  }

  /// LFU (Least Frequently Used) eviction for disk cache
  static Future<void> _evictLFU() async {
    if (_recipeBox.length < maxDiskCacheSize) return;

    String? lfuKey;
    int minAccessCount = 999999;

    for (var key in _recipeBox.keys) {
      final metadata = _getCacheMetadata(key);
      final accessCount = metadata['accessCount'] ?? 0;
      final priority = CachePriority.values[metadata['priority'] ?? 0];

      // Don't evict critical items
      if (priority == CachePriority.critical) continue;

      if (accessCount < minAccessCount) {
        minAccessCount = accessCount;
        lfuKey = key;
      }
    }

    if (lfuKey != null) {
      await _recipeBox.delete(lfuKey);
      await _metadataBox.delete(lfuKey);
      print('EVICTED (LFU): $lfuKey');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CACHE WARMING (Preload likely-needed recipes)
  // ═══════════════════════════════════════════════════════════

  /// Warm cache based on time of day + user patterns
  static Future<void> warmCache(Mood currentMood) async {
    print('WARMING CACHE for mood: ${currentMood.displayName}');

    // Strategy: Cache top 10 recipes for current mood
    final recipeIds = await _getTopRecipesForMood(currentMood);
    await predictiveCache(recipeIds, CachePriority.high);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  static Future<void> _cacheToDisk(String recipeId, Potion potion) async {
    // Check if we need to evict
    if (_recipeBox.length >= maxDiskCacheSize) {
      await _evictLFU();
    }

    await _recipeBox.put(recipeId, potion.toJson());
    await _metadataBox.put(recipeId, {
      'cachedAt': DateTime.now().toIso8601String(),
      'accessCount': 0,
      'lastAccessedAt': DateTime.now().toIso8601String(),
      'priority': CachePriority.medium.index,
    });
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
        _recipeBox.containsKey(recipeId);
  }

  static Future<void> clearCache() async {
    _memoryCache.clear();
    await _recipeBox.clear();
    await _metadataBox.clear();
    print('CACHE CLEARED');
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    // Gather all recipes and their access counts
    final Map<String, int> accessCounts = {};
    // Memory cache
    for (var entry in _memoryCache.entries) {
      accessCounts[entry.key] = entry.value.accessCount;
    }
    // Disk cache
    for (var key in _recipeBox.keys) {
      final metadata = _getCacheMetadata(key);
      final count = metadata['accessCount'] ?? 0;
      accessCounts[key] = count;
    }
    // Sort by access count descending
    final sortedKeys = accessCounts.keys.toList()
      ..sort((a, b) => accessCounts[b]!.compareTo(accessCounts[a]!));
    // Get top 10 most accessed recipes
    final mostAccessedRecipes = <Potion>[];
    for (final key in sortedKeys.take(10)) {
      Potion? potion;
      if (_memoryCache.containsKey(key)) {
        potion = _memoryCache[key]!.potion;
      } else if (_recipeBox.containsKey(key)) {
        final data = _recipeBox.get(key);
        if (data != null) {
          potion = Potion.fromJson(Map<String, dynamic>.from(data));
        }
      }
      if (potion != null) {
        mostAccessedRecipes.add(potion);
      }
    }
    return {
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': _recipeBox.length,
      'memoryCacheLimit': maxMemoryCacheSize,
      'diskCacheLimit': maxDiskCacheSize,
      'totalDataSaved': await _calculateCacheSize(),
      'mostAccessedRecipes': mostAccessedRecipes,
    };
  }

  static Future<int> _calculateCacheSize() async {
    // Calculate total bytes saved by caching
    return _recipeBox.length * 50000; // Rough estimate: 50KB per recipe
  }

  static Future<List<String>> _getTopRecipesForMood(Mood mood) async {
    // This would query your database for most popular recipes for this mood
    // For now, return empty - implement after API integration
    return [];
  }
}

// ═══════════════════════════════════════════════════════════
// CACHE ENTRY MODEL
// ═══════════════════════════════════════════════════════════

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
