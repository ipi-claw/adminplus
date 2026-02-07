<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover" v-loading="loading">
          <div class="stat-card">
            <div class="stat-icon" style="background: #409EFF">
              <el-icon :size="40"><User /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.userCount.toLocaleString() }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" v-loading="loading">
          <div class="stat-card">
            <div class="stat-icon" style="background: #67C23A">
              <el-icon :size="40"><UserFilled /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.roleCount.toLocaleString() }}</div>
              <div class="stat-label">角色总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" v-loading="loading">
          <div class="stat-card">
            <div class="stat-icon" style="background: #E6A23C">
              <el-icon :size="40"><Menu /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.menuCount.toLocaleString() }}</div>
              <div class="stat-label">菜单总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover" v-loading="loading">
          <div class="stat-card">
            <div class="stat-icon" style="background: #F56C6C">
              <el-icon :size="40"><Document /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ stats.logCount.toLocaleString() }}</div>
              <div class="stat-label">日志总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>欢迎使用 AdminPlus</span>
            </div>
          </template>
          <div class="welcome-content">
            <h3>🎉 恭喜！系统已成功启动</h3>
            <p>AdminPlus 是一个基于 Spring Boot 3.5 + JDK 21 + Vue 3 的全栈 RBAC 管理系统</p>
            <ul>
              <li>✅ Spring Boot 3.5 - 最新版本，支持虚拟线程</li>
              <li>✅ JDK 21 - 使用 Record、Switch 模式匹配等新特性</li>
              <li>✅ Spring Security Native JWT - 无需第三方 JWT 库</li>
              <li>✅ Spring Data JPA - 纯 Spring 生态，不使用 MyBatis Plus</li>
              <li>✅ PostgreSQL 16+ - 支持 JSONB 等高级特性</li>
              <li>✅ Vue 3 + JavaScript - 不使用 TypeScript，保持灵活性</li>
              <li>✅ Element Plus - 现代化 UI 组件库</li>
            </ul>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getDashboardStats } from '@/api/dashboard'

// 统计数据
const stats = ref({
  userCount: 0,
  roleCount: 0,
  menuCount: 0,
  logCount: 0
})

// 加载状态
const loading = ref(false)

// 获取统计数据
const fetchStats = async () => {
  try {
    loading.value = true
    const data = await getDashboardStats()
    stats.value = data
  } catch (error) {
    console.error('获取统计数据失败:', error)
    ElMessage.error('获取统计数据失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 组件挂载时获取数据
onMounted(() => {
  fetchStats()
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
}

.stat-icon {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 20px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
}

.stat-label {
  font-size: 14px;
  color: #999;
  margin-top: 5px;
}

.welcome-content h3 {
  margin: 0 0 20px 0;
  color: #333;
}

.welcome-content p {
  color: #666;
  margin-bottom: 20px;
}

.welcome-content ul {
  list-style: none;
  padding: 0;
}

.welcome-content li {
  padding: 10px 0;
  color: #666;
  border-bottom: 1px solid #eee;
}

.welcome-content li:last-child {
  border-bottom: none;
}
</style>