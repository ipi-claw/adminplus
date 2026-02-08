<template>
  <el-container class="layout-container">
    <el-aside width="240px">
      <div class="logo">
        <h2>AdminPlus</h2>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#FFFFFF"
        text-color="#333333"
        active-text-color="#0066FF"
      >
        <!-- 动态菜单 -->
        <template v-for="menu in menus" :key="menu.id">
          <!-- 目录类型（有子菜单） -->
          <el-sub-menu v-if="menu.children && menu.children.length > 0" :index="menu.path || menu.id.toString()">
            <template #title>
              <el-icon v-if="menu.icon">
                <component :is="getIcon(menu.icon)" />
              </el-icon>
              <span>{{ menu.name }}</span>
            </template>
            <!-- 子菜单 -->
            <template v-for="child in menu.children" :key="child.id">
              <!-- 如果子菜单还有子菜单（多层嵌套） -->
              <el-sub-menu v-if="child.children && child.children.length > 0" :index="child.path || child.id.toString()">
                <template #title>
                  <el-icon v-if="child.icon">
                    <component :is="getIcon(child.icon)" />
                  </el-icon>
                  <span>{{ child.name }}</span>
                </template>
                <el-menu-item
                  v-for="grandchild in child.children"
                  :key="grandchild.id"
                  :index="grandchild.path"
                  v-if="grandchild.type === 1"
                >
                  <el-icon v-if="grandchild.icon">
                    <component :is="getIcon(grandchild.icon)" />
                  </el-icon>
                  <span>{{ grandchild.name }}</span>
                </el-menu-item>
              </el-sub-menu>
              <!-- 普通菜单项 -->
              <el-menu-item v-else :index="child.path" v-if="child.type === 1">
                <el-icon v-if="child.icon">
                  <component :is="getIcon(child.icon)" />
                </el-icon>
                <span>{{ child.name }}</span>
              </el-menu-item>
            </template>
          </el-sub-menu>
          <!-- 菜单类型（无子菜单） -->
          <el-menu-item v-else :index="menu.path" v-if="menu.type === 1">
            <el-icon v-if="menu.icon">
              <component :is="getIcon(menu.icon)" />
            </el-icon>
            <span>{{ menu.name }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header>
        <div class="header-left">
          <span class="welcome-text">欢迎，{{ userStore.user?.nickname || userStore.user?.username }}</span>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="el-dropdown-link">
              <el-icon><Avatar /></el-icon>
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  个人中心
                </el-dropdown-item>
                <el-dropdown-item
                  divided
                  command="logout"
                >
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Avatar,
  ArrowDown,
  HomeFilled,
  Setting,
  User,
  UserFilled,
  Menu,
  Document,
  Tools,
  DataAnalysis,
  Monitor
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useConfirm } from '@/composables/useConfirm'
import { getUserMenuTree } from '@/api/menu'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const menus = ref([])

// 图标映射表
const iconMap = {
  'HomeFilled': HomeFilled,
  'Setting': Setting,
  'User': User,
  'UserFilled': UserFilled,
  'Menu': Menu,
  'Document': Document,
  'Tools': Tools,
  'DataAnalysis': DataAnalysis,
  'Monitor': Monitor
}

// 获取图标组件
const getIcon = (iconName) => {
  return iconMap[iconName] || Menu
}

const activeMenu = computed(() => route.path)

// 加载用户菜单
const loadUserMenus = async () => {
  try {
    const data = await getUserMenuTree()
    menus.value = data || []
  } catch (error) {
    ElMessage.error('菜单加载失败')
  }
}

// 确认操作
const confirmLogout = useConfirm({
  message: '确定要退出登录吗？',
  type: 'warning'
})

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await confirmLogout()
      userStore.logout()
      ElMessage.success('退出成功')
      router.push('/login')
    } catch {
      // 取消操作
    }
  } else if (command === 'profile') {
    router.push('/profile')
  }
}

onMounted(() => {
  loadUserMenus()
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.el-aside {
  background-color: #FFFFFF;
  border-right: 1px solid #E5E7EB;
  overflow-x: hidden;
  transition: width 0.3s;
}

.logo {
  height: 60px;
  line-height: 60px;
  text-align: center;
  color: #0066FF;
  font-size: 20px;
  font-weight: bold;
  background: linear-gradient(135deg, #0066FF 0%, #7B5FD6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  border-bottom: 1px solid #E5E7EB;
}

.el-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #FFFFFF;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
  padding: 0 24px;
  border-bottom: 1px solid #E5E7EB;
}

.header-left {
  font-size: 16px;
}

.welcome-text {
  color: #1A1A1A;
  font-weight: 500;
}

.header-right {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  cursor: pointer;
  font-size: 20px;
  color: #0066FF;
  transition: color 0.3s;
}

.el-dropdown-link:hover {
  color: #3385FF;
}

.el-main {
  background-color: #F7F8FA;
  padding: 20px;
}

/* 菜单样式 */
:deep(.el-menu) {
  border-right: none;
}

:deep(.el-menu-item) {
  border-right: 3px solid transparent;
  transition: all 0.3s;
  margin: 4px 8px;
  border-radius: 8px;
}

:deep(.el-menu-item.is-active) {
  background-color: #E8F0FE !important;
  color: #0066FF !important;
  font-weight: 600;
}

:deep(.el-menu-item:hover) {
  background-color: #F5F7FA;
  color: #0066FF;
}

:deep(.el-sub-menu__title) {
  margin: 4px 8px;
  border-radius: 8px;
  transition: all 0.3s;
}

:deep(.el-sub-menu__title:hover) {
  background-color: #F5F7FA;
  color: #0066FF;
}

:deep(.el-sub-menu .el-menu-item) {
  margin: 4px 8px 4px 24px;
  border-radius: 6px;
}
</style>