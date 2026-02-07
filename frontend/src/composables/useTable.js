/**
 * 表格操作组合式函数
 * @param {Function} fetchApi - 获取数据的 API 函数
 * @param {Object} options - 配置选项
 * @param {Function} options.onSuccess - 成功回调
 * @param {Function} options.onError - 错误回调
 * @returns {Object} 表格操作相关状态和方法
 */
export function useTable(fetchApi, options = {}) {
  const loading = ref(false)
  const tableData = ref([])

  /**
   * 获取表格数据
   * @param {Object} params - 请求参数
   */
  const fetchTableData = async (params = {}) => {
    loading.value = true
    try {
      const data = await fetchApi(params)
      tableData.value = data
      options.onSuccess?.(data)
    } catch (error) {
      options.onError?.(error)
    } finally {
      loading.value = false
    }
  }

  /**
   * 刷新表格数据
   */
  const refresh = () => {
    fetchTableData()
  }

  return {
    loading,
    tableData,
    fetchTableData,
    refresh
  }
}