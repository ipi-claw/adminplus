package com.adminplus;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Redis 缓存测试
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@SpringBootTest
public class RedisCacheTest {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Autowired
    private CacheManager cacheManager;

    @Test
    public void testRedisConnection() {
        // 测试 Redis 连接
        String result = redisTemplate.getConnectionFactory().getConnection().ping();
        assertEquals("PONG", result);
        System.out.println("✅ Redis 连接测试通过");
    }

    @Test
    public void testStringOperations() {
        // 测试字符串操作
        String key = "test:string";
        String value = "Hello, Redis!";

        // 设置值
        stringRedisTemplate.opsForValue().set(key, value, 10, TimeUnit.SECONDS);
        System.out.println("✅ 设置字符串: " + key + " = " + value);

        // 获取值
        String retrievedValue = stringRedisTemplate.opsForValue().get(key);
        assertEquals(value, retrievedValue);
        System.out.println("✅ 获取字符串: " + retrievedValue);

        // 删除值
        stringRedisTemplate.delete(key);
        System.out.println("✅ 删除字符串: " + key);
    }

    @Test
    public void testObjectOperations() {
        // 测试对象操作
        String key = "test:object";
        TestObject testObj = new TestObject("张三", 25);

        // 设置对象
        redisTemplate.opsForValue().set(key, testObj, 10, TimeUnit.SECONDS);
        System.out.println("✅ 设置对象: " + testObj);

        // 获取对象
        TestObject retrievedObj = (TestObject) redisTemplate.opsForValue().get(key);
        assertNotNull(retrievedObj);
        assertEquals(testObj.getName(), retrievedObj.getName());
        assertEquals(testObj.getAge(), retrievedObj.getAge());
        System.out.println("✅ 获取对象: " + retrievedObj);

        // 删除对象
        redisTemplate.delete(key);
        System.out.println("✅ 删除对象: " + key);
    }

    @Test
    public void testCacheManager() {
        // 测试缓存管理器
        assertNotNull(cacheManager);
        System.out.println("✅ CacheManager 初始化成功");

        // 获取缓存
        Cache cache = cacheManager.getCache("test-cache");
        assertNotNull(cache);
        System.out.println("✅ 缓存实例创建成功");

        // 测试缓存操作
        String key = "testKey";
        String value = "testValue";

        cache.put(key, value);
        System.out.println("✅ 缓存写入: " + key + " = " + value);

        Cache.ValueWrapper wrapper = cache.get(key);
        assertNotNull(wrapper);
        assertEquals(value, wrapper.get());
        System.out.println("✅ 缓存读取: " + wrapper.get());

        cache.evict(key);
        System.out.println("✅ 缓存清除: " + key);

        Cache.ValueWrapper afterEvict = cache.get(key);
        assertNull(afterEvict);
        System.out.println("✅ 缓存已清除");
    }

    @Test
    public void testCacheWithTTL() {
        // 测试缓存过期时间
        String key = "test:ttl";
        String value = "This will expire in 2 seconds";

        redisTemplate.opsForValue().set(key, value, 2, TimeUnit.SECONDS);
        System.out.println("✅ 设置带过期时间的缓存: " + key + " (2秒后过期)");

        // 立即获取
        String immediateValue = (String) redisTemplate.opsForValue().get(key);
        assertEquals(value, immediateValue);
        System.out.println("✅ 立即获取缓存: " + immediateValue);

        // 等待过期
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // 获取已过期的缓存
        String expiredValue = (String) redisTemplate.opsForValue().get(key);
        assertNull(expiredValue);
        System.out.println("✅ 缓存已过期: " + key);
    }

    /**
     * 测试对象
     */
    static class TestObject {
        private String name;
        private int age;

        public TestObject() {
        }

        public TestObject(String name, int age) {
            this.name = name;
            this.age = age;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        @Override
        public String toString() {
            return "TestObject{name='" + name + "', age=" + age + "}";
        }
    }
}