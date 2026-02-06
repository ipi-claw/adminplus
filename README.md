# AdminPlus - 全栈 RBAC 管理系统

基于 Spring Boot 3.5 + JDK 21 + Vue 3 的全栈 RBAC（基于角色的访问控制）管理系统。

## 技术栈

### 后端
- **Spring Boot**: 3.5.0（基于 Spring Framework 6）
- **JDK**: 21（LTS）
- **Spring Security**: 6.3+（Native JWT，使用 OAuth2 Resource Server）
- **Spring Data JPA**: 最新版（基于 Hibernate 6.x）
- **PostgreSQL**: 16+
- **Lombok**: 简化 Entity 代码（DTO 使用 record）

### 前端
- **Vue**: 3.5+（Composition API）
- **Vite**: 6+（极速构建）
- **Pinia**: 3.x（状态管理）
- **Element Plus**: 最新版（UI 组件库）
- **Axios**: HTTP 客户端
- **JavaScript**: ES2022+（不使用 TypeScript）

## 核心特性

### 后端特性
- ✅ **JDK 21 新语法**
  - DTO 使用 `record` 类型
  - Switch 表达式
  - 虚拟线程支持

- ✅ **Spring Native**
  - 纯 Spring 生态，无第三方 JWT 库
  - 使用 Spring Security OAuth2 Resource Server
  - 使用 Jackson 处理 JSON
  - 使用 JPA + Hibernate 处理数据库

- ✅ **PostgreSQL 高级特性**
  - JSONB 类型支持
  - TIMESTAMP WITH TIME ZONE
  - 自动更新时间触发器

### 前端特性
- ✅ **Vue 3 Composition API**
  - `<script setup>` 语法
  - Pinia Setup Store
  - 自动导入 Vue API 和组件

- ✅ **Element Plus**
  - 自动按需导入
  - 现代化 UI 设计
  - 丰富的组件库

- ✅ **Axios 封装**
  - 请求/响应拦截器
  - 自动添加 Authorization 头
  - 统一错误处理

## 项目结构

```
AdminPlus/
├── backend/                 # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/adminplus/
│   │   │   │   ├── config/          # 配置类
│   │   │   │   ├── controller/      # 控制器
│   │   │   │   ├── dto/             # 数据传输对象（record）
│   │   │   │   ├── entity/          # 实体类
│   │   │   │   ├── exception/       # 异常处理
│   │   │   │   ├── repository/      # JPA Repository
│   │   │   │   ├── service/         # 服务层
│   │   │   │   ├── utils/           # 工具类
│   │   │   │   └── vo/              # 视图对象（record）
│   │   │   └── resources/
│   │   │       └── application.yml  # 应用配置
│   │   └── test/
│   └── pom.xml                      # Maven 配置
├── frontend/                # 前端项目
│   ├── src/
│   │   ├── api/             # API 接口
│   │   ├── assets/          # 静态资源
│   │   ├── components/      # 全局组件
│   │   ├── directives/      # 自定义指令
│   │   ├── layout/          # 布局组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # Pinia 状态管理
│   │   ├── utils/           # 工具函数
│   │   └── views/           # 页面组件
│   ├── public/              # 公共资源
│   ├── index.html           # HTML 入口
│   ├── package.json         # NPM 配置
│   └── vite.config.js       # Vite 配置
├── docs/                    # 文档
│   └── init.sql             # 数据库初始化脚本
├── .gitignore
└── README.md
```

## 开发规范

### 后端规范

####DTO 使用 record 类型
```java
// 推荐
public record UserLoginReq(
    @NotBlank String username,
    @NotBlank String password
) {}

// 禁止
@Data
public class UserLoginReq {
    private String username;
    private String password;
}
```

#### Switch 表达式
```java
var roleName = switch (roleType) {
    case "ADMIN" -> "管理员";
    case "USER" -> "普通用户";
    default -> throw new IllegalArgumentException("未知角色");
};
```

#### Entity 使用 Lombok
```java
@Data
@Entity
@Table(name = "sys_user")
public class UserEntity extends BaseEntity {
    @Column(name = "username")
    private String username;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "settings", columnDefinition = "jsonb")
    private Map<String, Object> settings;
}
```

### 前端规范

#### 组件使用 `<script setup>`
```vue
<script setup>
import { ref } from 'vue'
import { getUserList } from '@/api/user'

const loading = ref(false)
const tableData = ref([])

const getData = async () => {
  loading.value = true
  try {
    const data = await getUserList()
    tableData.value = data
  } finally {
    loading.value = false
  }
}
</script>
```

#### Pinia Setup Store
```javascript
// stores/user.js
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const setToken = (val) => {
    token.value = val
    localStorage.setItem('token', val)
  }
  return { token, setToken }
})
```

## 快速开始

### 环境要求
- JDK 21+
- Node.js 18+
- PostgreSQL 16+
- Maven 3.8+

### 数据库初始化

```bash
# 创建数据库
createdb adminplus

# 执行初始化脚本
psql -d adminplus -f docs/init.sql
```

### 后端启动

```bash
cd backend

# 修改配置文件
vim src/main/resources/application.yml

# 启动服务
mvn spring-boot:run
```

服务地址：http://localhost:8080/api

API 文档：http://localhost:8080/api/swagger-ui.html

### 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

服务地址：http://localhost:5173

### 默认账号
- 用户名：`admin`
- 密码：`admin123`

## 数据库设计

### 核心表

| 表名 | 说明 |
|------|------|
| `sys_user` | 用户表 |
| `sys_role` | 角色表 |
| `sys_menu` | 菜单/权限表 |
| `sys_user_role` | 用户-角色关联表 |
| `sys_role_menu` | 角色-菜单关联表 |

### 表命名规范
- 表名：`sys_` 前缀，小写蛇形（如 `sys_user`）
- 字段：小写蛇形（如 `user_name`, `create_time`）
- 主键：`id`（BIGSERIAL，自增）
- 时间字段：`create_time`, `update_time`（TIMESTAMP WITH TIME ZONE）
- 逻辑删除：`deleted`（BOOLEAN）

## API 规范

### 响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {...},
  "timestamp": 1704010000000
}
```

### 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 参数错误 |
| 401 | 认证失败 |
| 403 | 无权访问 |
| 500 | 系统错误 |

## 功能模块

- ✅ 用户管理
- ✅ 角色管理
- ✅ 菜单管理
- ✅ 权限控制
- ✅ JWT 认证
- ✅ 统一异常处理
- ✅ API 文档（Swagger/OpenAPI）

## 开发计划

- [ ] 部门管理
- [ ] 字典管理
- [ ] 系统配置
- [ ] 日志管理
- [ ] 操作日志
- [ ] 数据权限
- [ ] 文件上传
- [ ] 导入导出

## License

MIT License