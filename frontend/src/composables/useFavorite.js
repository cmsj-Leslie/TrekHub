/** 收藏按钮逻辑复用 - 线路页和活动页共用的收藏状态管理 */
import { ref } from 'vue'
import { toggleFavorite, checkFavorite } from '@/api/social'
import { useMessage } from 'naive-ui'

// 收藏按钮逻辑复用：线路页和活动页共用此 composable
export function useFavorite(targetType, targetId) {
  const favorited = ref(false)
  const msg = useMessage()

  async function check() {
    const res = await checkFavorite({ target_type: targetType, target_id: targetId })
    favorited.value = res.data.favorited
  }

  async function toggle() {
    const res = await toggleFavorite({ target_type: targetType, target_id: targetId })
    favorited.value = res.data.favorited
    msg.success(favorited.value ? '已收藏' : '已取消收藏')
  }

  return { favorited, check, toggle }
}
