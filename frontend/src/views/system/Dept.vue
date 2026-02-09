<template>
  <div class="dept-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>部门管理</span>
          <div class="header-actions">
            <el-button
              type="primary"
              @click="handleAdd"
            >
              <el-icon><Plus /></el-icon>
              新增部门
            </el-button>
          </div>
        </div>
      </template>

      <!-- 部门树 -->
      <el-tree
        ref="treeRef"
        v-loading="loading"
        :data="treeData"
        :props="treeProps"
        node-key="id"
        default-expand-all
        highlight-current
        @node-click="handleNodeClick"
      >
        <template #default="{ node, data }">
          <div class="tree-node">
            <span class="node-name">{{ node.label }}</span>
            <div class="node-actions">
              <el-button
                type="primary"
                size="small"
                @click="handleAddChild(data)"
              >
                添加子部门
              </el-button>
              <el-button
                type="warning"
                size="small"
                @click="handleEdit(data)"
              >
                编辑
              </el-button>
              <el-button
                type="danger"
                size="small"
                @click="handleDelete(data)"
              >
                删除
              </el-button>
            </div>
          </div>
        </template>
      </el-tree>
    </el-card>

    <!-- 部门编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="80px"
      >
        <el-form-item
          label="部门名称"
          prop="name"
        >
          <el-input
            v-model="form.name"
            placeholder="请输入部门名称"
          />
        </el-form-item>
        <el-form-item
          label="部门编码"
          prop="code"
        >
          <el-input
            v-model="form.code"
            placeholder="请输入部门编码"
          />
        </el-form-item>
        <el-form-item
          label="负责人"
          prop="leader"
        >
          <el-input
            v-model="form.leader"
            placeholder="请输入负责人"
          />
        </el-form-item>
        <el-form-item
          label="联系电话"
          prop="phone"
        >
          <el-input
            v-model="form.phone"
            placeholder="请输入联系电话"
          />
        </el-form-item>
        <el-form-item
          label="状态"
          prop="status"
        >
          <el-switch
            v-model="form.status"
            :active-value="1"
            :inactive-value="0"
          />
        </el-form-item>
        <el-form-item
          label="排序"
          prop="sortOrder"
        >
          <el-input-number
            v-model="form.sortOrder"
            :min="0"
            :max="999"
          />
        </el-form-item>
        <el-form-item
          label="备注"
          prop="remark"
        >
          <el-input
            v-model="form.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitLoading"
          @click="handleSubmit"
        >
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const treeData = ref([])
const treeRef = ref()
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const isEdit = ref(false)

const formRef = ref()
const form = reactive({
  name: '',
  code: '',
  leader: '',
  phone: '',
  status: 1,
  sortOrder: 0,
  remark: ''
})

const treeProps = {
  label: 'name',
  children: 'children'
}

const rules = {
  name: [{ required: true, message: '请输入部门名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入部门编码', trigger: 'blur' }]
}

// 获取部门树数据
const getData = async () => {
  loading.value = true
  try {
    // 模拟数据
    treeData.value = [
      {
        id: '1',
        name: '总公司',
        code: 'ROOT',
        leader: '张三',
        phone: '13800138000',
        status: 1,
        sortOrder: 1,
        remark: '总公司',
        children: [
          {
            id: '2',
            name: '技术部',
            code: 'TECH',
            leader: '李四',
            phone: '13800138001',
            status: 1,
            sortOrder: 1,
            remark: '技术研发部门'
          },
          {
            id: '3',
            name: '市场部',
            code: 'MARKET',
            leader: '王五',
            phone: '13800138002',
            status: 1,
            sortOrder: 2,
            remark: '市场推广部门'
          }
        ]
      }
    ]
  } catch {
    ElMessage.error('获取部门数据失败')
  } finally {
    loading.value = false
  }
}

// 新增部门
const handleAdd = () => {
  isEdit.value = false
  dialogTitle.value = '新增部门'
  resetForm()
  dialogVisible.value = true
}

// 新增子部门
const handleAddChild = (data) => {
  isEdit.value = false
  dialogTitle.value = '新增子部门'
  resetForm()
  form.parentId = data.id
  dialogVisible.value = true
}

// 编辑部门
const handleEdit = (data) => {
  isEdit.value = true
  dialogTitle.value = '编辑部门'
  Object.assign(form, data)
  dialogVisible.value = true
}

// 删除部门
const handleDelete = async (data) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除部门"${data.name}"吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    ElMessage.success('删除成功')
    getData()
  } catch {
    // 用户取消操作
  }
}

// 节点点击
const handleNodeClick = (data) => {
  console.log('选中部门:', data)
}

// 重置表单
const resetForm = () => {
  Object.assign(form, {
    name: '',
    code: '',
    leader: '',
    phone: '',
    status: 1,
    sortOrder: 0,
    remark: ''
  })
  formRef.value?.resetFields()
}

// 提交表单
const handleSubmit = async () => {
  await formRef.value.validate()

  submitLoading.value = true
  try {
    // 模拟保存操作
    await new Promise(resolve => setTimeout(resolve, 1000))
    ElMessage.success(isEdit.value ? '更新成功' : '创建成功')
    dialogVisible.value = false
    getData()
  } catch {
    ElMessage.error('操作失败')
  } finally {
    submitLoading.value = false
  }
}

onMounted(() => {
  getData()
})
</script>

<style scoped>
.dept-page {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 5px 0;
}

.node-name {
  flex: 1;
}

.node-actions {
  display: flex;
  gap: 5px;
}
</style>