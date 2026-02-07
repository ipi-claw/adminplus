/**
 * 表单管理 Composable
 * @param {Object} initialForm - 初始表单数据
 * @returns {Object} 表单管理对象
 */
export function useForm(initialForm = {}) {
  const formRef = ref(null)
  const isEdit = ref(false)
  const dialogVisible = ref(false)
  const dialogTitle = ref('新增')
  const loading = ref(false)

  const form = reactive({ ...initialForm })

  /**
   * 重置表单
   */
  const resetForm = () => {
    Object.assign(form, { ...initialForm })
    formRef.value?.resetFields()
  }

  /**
   * 验证表单
   * @returns {Promise<void>}
   */
  const validateForm = () => {
    return formRef.value?.validate()
  }

  /**
   * 关闭对话框
   */
  const handleDialogClose = () => {
    formRef.value?.resetFields()
    resetForm()
    dialogVisible.value = false
  }

  return {
    formRef,
    form,
    isEdit,
    dialogVisible,
    dialogTitle,
    loading,
    resetForm,
    validateForm,
    handleDialogClose
  }
}