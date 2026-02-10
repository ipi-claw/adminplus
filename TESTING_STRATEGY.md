# AdminPlus 测试策略

## 概述
本文档描述了 AdminPlus 项目的测试策略和测试体系结构。

## 测试类型

### 1. 单元测试 (Unit Tests)
- **位置**: `backend/src/test/java/com/adminplus/`
- **工具**: JUnit 5 + Mockito
- **覆盖范围**: Service、Repository、Utils、Filters
- **目标**: 测试单个组件的正确性

### 2. 集成测试 (Integration Tests)
- **位置**: `backend/src/test/java/com/adminplus/`
- **工具**: Spring Boot Test + H2 Database
- **覆盖范围**: 数据库操作、服务集成、控制器
- **目标**: 测试组件间的集成

### 3. 控制器测试 (Controller Tests)
- **位置**: `backend/src/test/java/com/adminplus/controller/`
- **工具**: MockMvc + WebMvcTest
- **覆盖范围**: REST API 端点
- **目标**: 测试 HTTP 接口的正确性

### 4. 前端组件测试 (Frontend Component Tests)
- **位置**: `frontend/test/components/`
- **工具**: Vitest + Vue Test Utils
- **覆盖范围**: Vue 组件、工具函数
- **目标**: 测试前端组件的渲染和交互

## 测试配置

### 后端测试配置
```yaml
# src/test/resources/application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
  jpa:
    hibernate:
      ddl-auto: create-drop
```

### 前端测试配置
```javascript
// vitest.config.js
export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
  }
})
```

## 测试覆盖率目标

| 组件类型 | 覆盖率目标 |
|----------|------------|
| Service 层 | 90%+ |
| Controller 层 | 85%+ |
| Repository 层 | 80%+ |
| Utils 工具类 | 95%+ |
| Vue 组件 | 70%+ |

## 测试运行

### 运行所有测试
```bash
./run-tests.sh
```

### 运行后端测试
```bash
cd backend
mvn test
```

### 运行前端测试
```bash
cd frontend
npm run test
```

### 运行特定测试类
```bash
# 后端
mvn test -Dtest=UserServiceTest

# 前端
npm run test LoginForm.test.js
```

## 持续集成

### GitHub Actions 配置
项目配置了 GitHub Actions 来自动运行测试：
- 在每次 push 到 main 分支时运行
- 在每次 pull request 时运行
- 生成测试覆盖率报告

### 代码质量门禁
- 测试覆盖率低于 80% 时构建失败
- 任何测试失败时构建失败
- 代码风格检查失败时构建失败

## 测试最佳实践

### 后端测试
1. 使用 `@ExtendWith(MockitoExtension.class)` 进行单元测试
2. 使用 `@SpringBootTest` 进行集成测试
3. 使用 `@Transactional` 确保测试数据隔离
4. 使用 H2 内存数据库进行快速测试

### 前端测试
1. 使用 `mount()` 而不是 `shallowMount()` 进行组件测试
2. 模拟 API 调用以避免真实网络请求
3. 使用 `vi.mock()` 进行模块模拟
4. 测试用户交互和组件状态变化

## 故障排除

### 常见问题
1. **H2 数据库连接失败**: 检查 application-test.yml 配置
2. **MockMvc 测试失败**: 检查 Controller 的依赖注入
3. **前端测试环境问题**: 确保 jsdom 正确配置
4. **测试数据污染**: 使用 @BeforeEach 和 @AfterEach 清理数据

### 调试技巧
- 使用 `@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)` 进行端口测试
- 使用 `TestRestTemplate` 进行端到端测试
- 使用 `@TestPropertySource` 覆盖特定配置