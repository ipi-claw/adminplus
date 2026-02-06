package com.adminplus;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.test.context.TestPropertySource;

import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Redis 连接测试（轻量级测试，不启动完整应用）
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@SpringBootTest(classes = RedisConnectionTest.TestConfig.class, webEnvironment = SpringBootTest.WebEnvironment.NONE)
@TestPropertySource(properties = {
    "spring.data.redis.host=localhost",
    "spring.data.redis.port=6379",
    "spring.data.redis.timeout=2000ms",
    "spring.data.redis.lettuce.pool.max-active=8",
    "spring.data.redis.lettuce.pool.max-idle=8",
    "spring.data.redis.lettuce.pool.min-idle=0",
    "spring.data.redis.lettuce.pool.max-wait=-1ms"
})
public class RedisConnectionTest {

    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired(required = false)
    private StringRedisTemplate stringRedisTemplate;

    @Configuration
    @EnableAutoConfiguration(exclude = {
        org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration.class,
        org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration.class,
        org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration.class,
        org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration.class,
        org.springframework.boot.autoconfigure.web.servlet.ServletWebServerFactoryAutoConfiguration.class
    })
    static class TestConfig {

        @Bean
        public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
            RedisTemplate<String, Object> template = new RedisTemplate<>();
            template.setConnectionFactory(connectionFactory);
            template.setKeySerializer(new StringRedisSerializer());
            template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
            template.setHashKeySerializer(new StringRedisSerializer());
            template.setHashValueSerializer(new GenericJackson2JsonRedisSerializer());
            template.afterPropertiesSet();
            return template;
        }

        @Bean
        public StringRedisTemplate stringRedisTemplate(RedisConnectionFactory connectionFactory) {
            StringRedisTemplate template = new StringRedisTemplate();
            template.setConnectionFactory(connectionFactory);
            return template;
        }
    }

    /**
     * 测试 Redis 基本连接
     */
    @Test
    public void testRedisPing() {
        try {
            String result = redisTemplate.getConnectionFactory().getConnection().ping();
            assertEquals("PONG", result);
            System.out.println("✅ Redis 连接测试通过");
        } catch (Exception e) {
            fail("❌ Redis 连接失败: " + e.getMessage());
        }
    }

    /**
     * 测试字符串操作
     */
    @Test
    public void testStringOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");
            assertNotNull(stringRedisTemplate, "StringRedisTemplate 未注入");

            String key = "test:string:" + System.currentTimeMillis();
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
        } catch (Exception e) {
            fail("❌ 字符串操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试对象操作
     */
    @Test
    public void testObjectOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String key = "test:object:" + System.currentTimeMillis();
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
        } catch (Exception e) {
            fail("❌ 对象操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试过期时间
     */
    @Test
    public void testTTL() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String key = "test:ttl:" + System.currentTimeMillis();
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
        } catch (Exception e) {
            fail("❌ TTL 测试失败: " + e.getMessage());
        }
    }

    /**
     * 测试批量操作
     */
    @Test
    public void testBatchOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String keyPrefix = "test:batch:" + System.currentTimeMillis();

            // 批量设置
            for (int i = 0; i < 10; i++) {
                String key = keyPrefix + ":" + i;
                String value = "value-" + i;
                redisTemplate.opsForValue().set(key, value, 10, TimeUnit.SECONDS);
            }
            System.out.println("✅ 批量设置 10 个键值对");

            // 批量获取
            int count = 0;
            for (int i = 0; i < 10; i++) {
                String key = keyPrefix + ":" + i;
                String value = (String) redisTemplate.opsForValue().get(key);
                if (value != null) {
                    count++;
                }
            }
            assertEquals(10, count);
            System.out.println("✅ 批量获取: " + count + " 个键值对");

            // 批量删除
            for (int i = 0; i < 10; i++) {
                String key = keyPrefix + ":" + i;
                redisTemplate.delete(key);
            }
            System.out.println("✅ 批量删除 10 个键");
        } catch (Exception e) {
            fail("❌ 批量操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试 Hash 操作
     */
    @Test
    public void testHashOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String hashKey = "test:hash:" + System.currentTimeMillis();

            // 设置 Hash 字段
            redisTemplate.opsForHash().put(hashKey, "field1", "value1");
            redisTemplate.opsForHash().put(hashKey, "field2", "value2");
            System.out.println("✅ 设置 Hash 字段: field1=value1, field2=value2");

            // 获取 Hash 字段
            String field1 = (String) redisTemplate.opsForHash().get(hashKey, "field1");
            String field2 = (String) redisTemplate.opsForHash().get(hashKey, "field2");
            assertEquals("value1", field1);
            assertEquals("value2", field2);
            System.out.println("✅ 获取 Hash 字段: field1=" + field1 + ", field2=" + field2);

            // 获取所有 Hash 字段
            var entries = redisTemplate.opsForHash().entries(hashKey);
            assertEquals(2, entries.size());
            System.out.println("✅ 获取所有 Hash 字段: " + entries);

            // 删除 Hash
            redisTemplate.delete(hashKey);
            System.out.println("✅ 删除 Hash: " + hashKey);
        } catch (Exception e) {
            fail("❌ Hash 操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试 List 操作
     */
    @Test
    public void testListOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String listKey = "test:list:" + System.currentTimeMillis();

            // 添加元素到列表左侧
            redisTemplate.opsForList().leftPush(listKey, "item1");
            redisTemplate.opsForList().leftPush(listKey, "item2");
            redisTemplate.opsForList().leftPush(listKey, "item3");
            System.out.println("✅ 左侧添加 3 个元素");

            // 获取列表长度
            Long size = redisTemplate.opsForList().size(listKey);
            assertEquals(3L, size);
            System.out.println("✅ 列表长度: " + size);

            // 获取列表元素
            String item1 = (String) redisTemplate.opsForList().index(listKey, 0);
            String item2 = (String) redisTemplate.opsForList().index(listKey, 1);
            String item3 = (String) redisTemplate.opsForList().index(listKey, 2);
            assertEquals("item3", item1);  // leftPush 是从左侧插入，所以顺序是反的
            assertEquals("item2", item2);
            assertEquals("item1", item3);
            System.out.println("✅ 获取列表元素: " + item1 + ", " + item2 + ", " + item3);

            // 删除列表
            redisTemplate.delete(listKey);
            System.out.println("✅ 删除列表: " + listKey);
        } catch (Exception e) {
            fail("❌ List 操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试 Set 操作
     */
    @Test
    public void testSetOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String setKey = "test:set:" + System.currentTimeMillis();

            // 添加元素
            redisTemplate.opsForSet().add(setKey, "member1");
            redisTemplate.opsForSet().add(setKey, "member2");
            redisTemplate.opsForSet().add(setKey, "member3");
            System.out.println("✅ 添加 3 个成员到 Set");

            // 获取 Set 大小
            Long size = redisTemplate.opsForSet().size(setKey);
            assertEquals(3L, size);
            System.out.println("✅ Set 大小: " + size);

            // 检查成员是否存在
            Boolean exists1 = redisTemplate.opsForSet().isMember(setKey, "member1");
            Boolean exists4 = redisTemplate.opsForSet().isMember(setKey, "member4");
            assertTrue(exists1);
            assertFalse(exists4);
            System.out.println("✅ 成员检查: member1 存在, member4 不存在");

            // 删除成员
            redisTemplate.opsForSet().remove(setKey, "member1");
            size = redisTemplate.opsForSet().size(setKey);
            assertEquals(2L, size);
            System.out.println("✅ 删除 member1 后 Set 大小: " + size);

            // 删除 Set
            redisTemplate.delete(setKey);
            System.out.println("✅ 删除 Set: " + setKey);
        } catch (Exception e) {
            fail("❌ Set 操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试 ZSet 操作
     */
    @Test
    public void testZSetOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String zsetKey = "test:zset:" + System.currentTimeMillis();

            // 添加元素到有序集合
            redisTemplate.opsForZSet().add(zsetKey, "member1", 10.0);
            redisTemplate.opsForZSet().add(zsetKey, "member2", 20.0);
            redisTemplate.opsForZSet().add(zsetKey, "member3", 30.0);
            System.out.println("✅ 添加 3 个元素到 ZSet");

            // 获取 ZSet 大小
            Long size = redisTemplate.opsForZSet().size(zsetKey);
            assertEquals(3L, size);
            System.out.println("✅ ZSet 大小: " + size);

            // 获取排名
            Long rank1 = redisTemplate.opsForZSet().rank(zsetKey, "member1");
            Long rank2 = redisTemplate.opsForZSet().rank(zsetKey, "member2");
            Long rank3 = redisTemplate.opsForZSet().rank(zsetKey, "member3");
            assertEquals(0L, rank1);
            assertEquals(1L, rank2);
            assertEquals(2L, rank3);
            System.out.println("✅ 排名: member1=0, member2=1, member3=2");

            // 删除 ZSet
            redisTemplate.delete(zsetKey);
            System.out.println("✅ 删除 ZSet: " + zsetKey);
        } catch (Exception e) {
            fail("❌ ZSet 操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试键操作
     */
    @Test
    public void testKeyOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String key1 = "test:key1:" + System.currentTimeMillis();
            String key2 = "test:key2:" + System.currentTimeMillis();

            // 设置键值
            redisTemplate.opsForValue().set(key1, "value1", 10, TimeUnit.SECONDS);
            redisTemplate.opsForValue().set(key2, "value2", 10, TimeUnit.SECONDS);
            System.out.println("✅ 设置键值: " + key1 + "=value1, " + key2 + "=value2");

            // 检查键是否存在
            Boolean exists1 = redisTemplate.hasKey(key1);
            Boolean exists3 = redisTemplate.hasKey("test:not-exist");
            assertTrue(exists1);
            assertFalse(exists3);
            System.out.println("✅ 键存在检查: key1 存在, test:not-exist 不存在");

            // 获取键的类型
            String type1 = redisTemplate.type(key1).code();
            assertEquals("string", type1);
            System.out.println("✅ 键类型: key1 的类型是 " + type1);

            // 删除键
            redisTemplate.delete(key1);
            redisTemplate.delete(key2);
            assertFalse(redisTemplate.hasKey(key1));
            assertFalse(redisTemplate.hasKey(key2));
            System.out.println("✅ 删除键: key1 和 key2");
        } catch (Exception e) {
            fail("❌ 键操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试事务操作
     */
    @Test
    public void testTransactionOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            String key1 = "test:tx:key1:" + System.currentTimeMillis();
            String key2 = "test:tx:key2:" + System.currentTimeMillis();

            // 在事务中执行多个操作
            redisTemplate.execute(new org.springframework.data.redis.core.SessionCallback<Object>() {
                @Override
                public Object execute(org.springframework.data.redis.core.RedisOperations operations) {
                    operations.multi();
                    operations.opsForValue().set(key1, "value1", 10, TimeUnit.SECONDS);
                    operations.opsForValue().set(key2, "value2", 10, TimeUnit.SECONDS);
                    return operations.exec();
                }
            });

            // 验证操作结果
            String value1 = (String) redisTemplate.opsForValue().get(key1);
            String value2 = (String) redisTemplate.opsForValue().get(key2);
            assertEquals("value1", value1);
            assertEquals("value2", value2);
            System.out.println("✅ 事务操作成功: key1=" + value1 + ", key2=" + value2);

            // 清理
            redisTemplate.delete(key1);
            redisTemplate.delete(key2);
            System.out.println("✅ 清理测试数据");
        } catch (Exception e) {
            fail("❌ 事务操作失败: " + e.getMessage());
        }
    }

    /**
     * 测试管道操作
     */
    @Test
    public void testPipelineOperations() {
        try {
            assertNotNull(redisTemplate, "RedisTemplate 未注入");

            long start = System.currentTimeMillis();
            String key1 = "test:pipeline:key1:" + start;
            String key2 = "test:pipeline:key2:" + start;

            // 使用管道执行多个操作
            redisTemplate.executePipelined(new org.springframework.data.redis.core.SessionCallback<Object>() {
                @Override
                public Object execute(org.springframework.data.redis.core.RedisOperations operations) {
                    operations.opsForValue().set(key1, "value1", 10, TimeUnit.SECONDS);
                    operations.opsForValue().set(key2, "value2", 10, TimeUnit.SECONDS);
                    return null;
                }
            });

            // 验证管道执行结果
            String value1 = (String) redisTemplate.opsForValue().get(key1);
            String value2 = (String) redisTemplate.opsForValue().get(key2);
            assertEquals("value1", value1);
            assertEquals("value2", value2);
            System.out.println("✅ 管道操作成功");

            // 清理
            redisTemplate.delete(key1);
            redisTemplate.delete(key2);
            System.out.println("✅ 清理测试数据");
        } catch (Exception e) {
            fail("❌ 管道操作失败: " + e.getMessage());
        }
    }
}


class TestObject {
    private String name;
    private int age;

    // 默认构造函数（用于 JSON 反序列化）
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