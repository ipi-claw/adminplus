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
        <el-menu-item index="/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>

        <el-sub-menu index="/system">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系统管理</span>
          </template>
          <el-menu-item index="/system/user">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/system/role">
            <el-icon><UserFilled /></el-icon>
            <span>角色管理</span>
          </el-menu-item>
          <el-menu-item index="/system/menu">
            <el-icon><Menu /></el-icon>
            <span>菜单管理</span>
          </el-menu-item>
          <el-menu-item index="/system/dict">
            <el-icon><Document /></el-icon>
            <span>字典管理</span>
          </el-menu-item>
        </el-sub-menu>
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
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Avatar, ArrowDown, HomeFilled, Setting, User, UserFilled, Menu, Document } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useConfirm } from '@/composables/useConfirm'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)

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