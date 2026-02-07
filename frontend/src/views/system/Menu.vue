<template>
  <div class="menu-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>菜单管理</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增菜单
          </el-button>
        </div>
      </template>

      <!-- 菜单树表格 -->
      <el-table
        :data="tableData"
        v-loading="loading"
        border
        row-key="id"
        :tree-props="{ children: 'children' }"
        default-expand-all
      >
        <el-table-column prop="name" label="菜单名称" width="200" />
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getMenuTypeTag(row.type)">
              {{ getMenuTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="path" label="路由路径" />
        <el-table-column prop="component" label="组件路径" />
        <el-table-column prop="permKey" label="权限标识" width="150" />
        <el-table-column prop="icon" label="图标" width="80">
          <template #default="{ row }">
            <el-icon v-if="row.icon && isValidIcon(row.icon)">
              <component :is="row.icon" />
            </el-icon>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column label="可见" width="80">
          <template #default="{ row }">
            <el-tag :type="row.visible === VISIBLE.SHOW ? 'success' : 'info'" size="small">
              {{ row.visible === VISIBLE.SHOW ? '显示' : '隐藏' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === STATUS.NORMAL ? 'success' : 'danger'" size="small">
              {{ row.status === STATUS.NORMAL ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleAddChild(row)">
              新增子菜单
            </el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="上级菜单" prop="parentId">
          <el-tree-select
            v-model="form.parentId"
            :data="menuSelectData"
            :props="{ label: 'name', value: 'id' }"
            placeholder="请选择上级菜单（不选则为��级菜单）"
            clearable
            check-strictly
            :render-after-expand="false"
          />
        </el-form-item>
        <el-form-item label="菜单类型" prop="type">
          <el-radio-group v-model="form.type">
            <el-radio :value="MENU_TYPE.DIRECTORY">目录</el-radio>
            <el-radio :value="MENU_TYPE.MENU">菜单</el-radio>
            <el-radio :value="MENU_TYPE.BUTTON">按钮</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="菜单名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入菜单名称" />
        </el-form-item>
        <el-form-item label="路由路径" prop="path" v-if="form.type !== MENU_TYPE.BUTTON">
          <el-input v-model="form.path" placeholder="请输入路由路径（如 /system/user）" />
        </el-form-item>
        <el-form-item label="组件路径" prop="component" v-if="form.type === MENU_TYPE.MENU">
          <el-input v-model="form.component" placeholder="请输入组件路径（如 system/User）" />
        </el-form-item>
        <el-form-item label="权限标识" prop="permKey" v-if="form.type === MENU_TYPE.BUTTON">
          <el-input v-model="form.permKey" placeholder="请输入权限标识（如 user:add）" />
        </el-form-item>
        <el-form-item label="图标" prop="icon" v-if="form.type !== MENU_TYPE.BUTTON">
          <el-input v-model="form.icon" placeholder="请输入图标名称" />
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" />
        </el-form-item>
        <el-form-item label="是否可见" prop="visible">
          <el-radio-group v-model="form.visible">
            <el-radio :value="VISIBLE.SHOW">显示</el-radio>
            <el-radio :value="VISIBLE.HIDE">隐藏</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="STATUS.NORMAL">正常</el-radio>
            <el-radio :value="STATUS.DISABLED">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getMenuTree, createMenu, updateMenu, deleteMenu } from '@/api/menu'
import { useForm } from '@/composables/useForm'
import { useConfirm } from '@/composables/useConfirm'
import {
  MENU_TYPE,
  STATUS,
  VISIBLE
} from '@/constants'

// 图标白名单
const ALLOWED_ICONS = [
  'Plus', 'Edit', 'Delete', 'Search', 'Setting', 'User', 'Lock', 'Unlock',
  'View', 'Hide', 'Check', 'Close', 'ArrowRight', 'ArrowLeft', 'ArrowUp', 'ArrowDown',
  'Home', 'Menu', 'Document', 'Folder', 'FolderOpened', 'Files', 'DataLine',
  'Tools', 'Management', 'Monitor', 'Bell', 'Message', 'ChatLineSquare',
  'Calendar', 'Clock', 'Timer', 'Warning', 'InfoFilled', 'SuccessFilled',
  'CircleCheck', 'CircleClose', 'CirclePlus', 'CircleMinus', 'ZoomIn', 'ZoomOut',
  'Refresh', 'RefreshRight', 'RefreshLeft', 'Download', 'Upload', 'Share',
  'More', 'MoreFilled', 'Star', 'StarFilled', 'EditPen', 'DeleteFilled'
]

/**
 * 验证图标是否在白名单中
 * @param {string} iconName - 图标名称
 * @returns {boolean} - 是否有效
 */
const isValidIcon = (iconName) => {
  return ALLOWED_ICONS.includes(iconName)
}

// 使用表单组合式函数
const { form, formRef, isEdit, dialogVisible, dialogTitle, resetForm, validateForm } = useForm({
  id: null,
  parentId: null,
  type: 1,
  name: '',
  path: '',
  component: '',
  permKey: '',
  icon: '',
  sortOrder: 0,
  visible: 1,
  status: 1
})

// 使用确认组合式函数
const confirmDelete = useConfirm({
  title: '提示',
  message: '确定要删除该菜单吗？',
  confirmText: '确定',
  cancelText: '取消',
  type: 'warning'
})

/**
 * 安全的图标白名单 - 防止 XSS 攻击
 */
const ICON_WHITELIST = [
  'Plus', 'Edit', 'Delete', 'Search', 'Refresh', 'Setting', 'User', 'Lock',
  'Unlock', 'Document', 'Folder', 'Menu', 'House', 'Tools', 'Monitor',
  'DataAnalysis', 'Management', 'Tickets', 'Files', 'DocumentCopy',
  'Collection', 'Connection', 'Link', 'Promotion', 'Notification', 'Message'
]

/**
 * 验证图标是否在白名单中
 * @param {string} iconName - 图标名称
 * @returns {boolean} - 是否安全
 */
const isIconSafe = (iconName) => {
  return ICON_WHITELIST.includes(iconName)
}

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])

const rules = computed(() => {
  const baseRules = {
    type: [{ required: true, message: '请选择菜单类型', trigger: 'change' }],
    name: [{ required: true, message: '请输入菜单名称', trigger: 'blur' }]
  }

  if (form.type !== MENU_TYPE.BUTTON) {
    baseRules.path = [{ required: true, message: '请输入路由路径', trigger: 'blur' }]
  }

  if (form.type === MENU_TYPE.MENU) {
    baseRules.component = [{ required: true, message: '请输入组件路径', trigger: 'blur' }]
  }

  if (form.type === MENU_TYPE.BUTTON) {
    baseRules.permKey = [{ required: true, message: '请输入权限标识', trigger: 'blur' }]
  }

  return baseRules
})

// 用于选择的菜单树（不包含当前编辑的菜单及其子菜单）
const menuSelectData = computed(() => {
  return buildMenuSelectData(tableData.value, isEdit.value ? form.id : null)
})

const buildMenuSelectData = (menus, excludeId) => {
  return menus
    .filter(menu => menu.id !== excludeId)
    .map(menu => ({
      id: menu.id,
      name: menu.name,
      children: menu.children ? buildMenuSelectData(menu.children, excludeId) : undefined
    }))
}

const getMenuTypeTag = (type) => {
  const tags = { 0: '', 1: 'success', 2: 'warning' }
  return tags[type] || ''
}

const getMenuTypeText = (type) => {
  const texts = { 0: '目录', 1: '菜单', 2: '按钮' }
  return texts[type] || '未知'
}

const getData = async () => {
  loading.value = true
  try {
    tableData.value = await getMenuTree()
  } catch (error) {
    ElMessage.error('获取菜单树失败')
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  isEdit.value = false
  dialogTitle.value = '新增菜单'
  dialogVisible.value = true
}

const handleAddChild = (row) => {
  isEdit.value = false
  dialogTitle.value = '新增子菜单'
  resetForm()
  form.parentId = row.id
  // 如果父级是目录，子菜单默认为菜单类型
  if (row.type === MENU_TYPE.DIRECTORY) {
    form.type = MENU_TYPE.MENU
  }
  dialogVisible.value = true
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
  resetForm()
}

const handleEdit = (row) => {
  isEdit.value = true
  dialogTitle.value = '编辑菜单'
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await validateForm()

  submitLoading.value = true
  try {
    const submitData = { ...form }
    delete submitData.id
    delete submitData.children

    if (isEdit.value) {
      await updateMenu(form.id, submitData)
      ElMessage.success('更新成功')
    } else {
      await createMenu(submitData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    getData()
  } catch (error) {
    // 错误已在 validateForm 中处理
  } finally {
    submitLoading.value = false
  }
}

const handleDelete = async (row) => {
  try {
    await confirmDelete()
    await deleteMenu(row.id)
    ElMessage.success('删除成功')
    getData()
  } catch (error) {
    // 用户取消操作
  }
}

onMounted(() => {
  getData()
})
</script>

<style scoped>
.menu-page {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>