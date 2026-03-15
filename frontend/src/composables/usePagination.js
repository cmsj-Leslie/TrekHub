/** 通用分页逻辑复用 - 所有列表页共用的加载、翻页、状态管理 */
import { ref } from 'vue'

// 所有列表页通用分页 composable，避免重复代码
export function usePagination(fetchFn, pageSize = 12) {
  const list    = ref([])
  const total   = ref(0)
  const page    = ref(1)
  const loading = ref(false)

  async function load(params = {}, reset = false) {
    if (reset) { page.value = 1; list.value = [] }
    loading.value = true
    try {
      const res = await fetchFn({ page: page.value, pageSize, ...params })
      total.value = res.data.total
      list.value  = reset ? res.data.list : [...list.value, ...res.data.list]
    } finally {
      loading.value = false
    }
  }

  function nextPage(params) {
    page.value++
    return load(params)
  }

  return { list, total, page, loading, load, nextPage }
}
