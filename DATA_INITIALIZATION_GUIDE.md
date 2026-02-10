# AdminPlus 数据初始化指南

## 概述

AdminPlus 应用在启动时会自动执行数据初始化，确保系统拥有必要的基础数据（用户、角色、菜单、部门等）。

## 启动流程

### 1. 应用启动
- 应用通过 `AdminPlusApplication.java` 启动
- Spring Boot 自动扫描并加载所有组件
- `DataInitializationService` 实现了 `CommandLineRunner` 接口

### 2. 数据初始化
- 检查是否已经初始化过（通过检查用户和角色数量）
- 如果未初始化，按以下顺序执行：
  - 初始化部门数据
  - 初始化角色数据
  - 初始化菜单数据
  - 初始化用户数据
  - 初始化权限关联

### 3. 初始化内容

#### 部门数据
- AdminPlus 总部
- 技术研发部
- 市场运营部
- 后端开发组
- 前端开发组
- 市场推广组
- 客户服务组

#### 角色数据
- 超级管理员 (ROLE_ADMIN)
- 部门经理 (ROLE_MANAGER)
- 普通用户 (ROLE_USER)
- 开发人员 (ROLE_DEVELOPER)
- 运营人员 (ROLE_OPERATOR)

#### 菜单数据
- 首页
- 系统管理（包含用户、角色、菜单、字典、部门、参数配置管理）
- 数据分析（包含数据统计、报表管理）

#### 用户数据
- admin (超级管理员)
- manager (部门经理)
- user1, user2 (普通用户)
- dev1, dev2 (开发人员)
- operator1, operator2 (运营人员)
- cs1, cs2 (客服人员)

#### 默认密码
所有用户的默认密码都是 `123456`

## 测试方法

### 方法一：完整测试
```bash
./test-data-init.sh
```

这个脚本会：
1. 清理现有容器
2. 启动数据库
3. 编译打包应用
4. 启动完整服务
5. 验证数据初始化结果

### 方法二：手动测试
```bash
# 1. 启动服务
docker-compose up -d

# 2. 等待应用启动
sleep 30

# 3. 检查健康状态
curl http://localhost:8081/api/actuator/health

# 4. 验证数据
# 检查用户数量
docker-compose exec postgres psql -U postgres -d adminplus -c "SELECT COUNT(*) FROM sys_user WHERE deleted = false"

# 检查角色数量
docker-compose exec postgres psql -U postgres -d adminplus -c "SELECT COUNT(*) FROM sys_role WHERE deleted = false"

# 检查菜单数量
docker-compose exec postgres psql -U postgres -d adminplus -c "SELECT COUNT(*) FROM sys_menu WHERE deleted = false"
```

## 配置说明

### 数据初始化服务
- 位置：`backend/src/main/java/com/adminplus/service/DataInitializationService.java`
- 实现了 `CommandLineRunner` 接口
- 在应用启动时自动执行

### 防止重复初始化
- 服务会检查是否已经存在用户和角色数据
- 如果数据已存在，会跳过初始化过程
- 可以通过删除数据库表来重新初始化

## 故障排除

### 初始化失败
1. 检查数据库连接
2. 查看应用日志：`docker-compose logs backend`
3. 检查实体类与数据库表结构的匹配

### 数据不完整
1. 检查数据初始化服务的日志输出
2. 验证repository接口是否正确实现
3. 检查数据库约束和索引

### 应用启动失败
1. 检查编译是否成功：`mvn clean compile`
2. 检查依赖是否正确：`mvn dependency:tree`
3. 查看详细的启动日志