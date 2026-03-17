<template>
  <div>
    <!-- 发表评论 -->
    <n-space v-if="userStore.isLoggedIn" vertical style="margin-bottom:16px">
      <n-rate v-if="targetType === 1" v-model:value="form.rating" />
      <n-input v-model:value="form.content" type="textarea" placeholder="写下你的评价..." :rows="3" />
      <!-- 图片上传 -->
      <div class="upload-area">
        <div class="img-preview-list">
          <div v-for="(img, idx) in form.images" :key="idx" class="img-preview-item">
            <img :src="img" />
            <span class="img-remove" @click="form.images.splice(idx, 1)">×</span>
          </div>
          <label v-if="form.images.length < 3" class="img-add-btn">
            <input type="file" accept="image/*" style="display:none" @change="handleImageUpload" />
            <span>📷</span>
            <span style="font-size:11px">添加图片</span>
          </label>
        </div>
        <span v-if="uploading" style="font-size:12px;color:#999">上传中...</span>
      </div>
      <n-button type="primary" :loading="submitting" @click="submit">发布评论</n-button>
    </n-space>

    <!-- 评论列表 -->
    <n-spin :show="loading">
      <div v-if="!list.length" style="text-align:center;color:#999;padding:24px">暂无评论</div>
      <div v-for="comment in list" :key="comment.id" style="margin-bottom:20px">
        <n-space align="start">
          <n-avatar v-if="comment.user?.avatar" :src="comment.user?.avatar" round size="small" />
          <n-avatar v-else round size="small">{{ comment.user?.nickname?.[0] }}</n-avatar>
          <div style="flex:1">
            <n-space align="center" style="margin-bottom:4px">
              <span style="font-weight:600;font-size:13px">{{ comment.user?.nickname }}</span>
              <n-rate v-if="comment.rating" :value="comment.rating" readonly size="small" />
              <span style="color:#aaa;font-size:12px">{{ smartTime(comment.created_at) }}</span>
            </n-space>
            <div style="font-size:14px;line-height:1.6">{{ comment.content }}</div>
            <!-- 图片 -->
            <n-space v-if="comment.images?.length" style="margin-top:8px">
              <img v-for="img in comment.images" :key="img" :src="img" style="width:80px;height:80px;object-fit:cover;border-radius:4px" />
            </n-space>
            <!-- 操作按钮 -->
            <n-space style="margin-top:6px" align="center">
              <button class="like-btn" :class="{ liked: likedSet.has(comment.id) }" @click="toggleLike(comment)">
                👍 <span>{{ comment.like_count || 0 }}</span>
              </button>
              <n-button text size="small" @click="replyTo = comment.id">回复</n-button>
              <n-button v-if="comment.user_id === userStore.info?.id" text size="small" type="error" @click="deleteComment(comment.id)">删除</n-button>
            </n-space>
            <!-- 回复输入框 -->
            <n-space v-if="replyTo === comment.id" vertical style="margin-top:8px">
              <n-input v-model:value="replyContent" placeholder="回复..." size="small" />
              <n-space>
                <n-button size="small" type="primary" @click="submitReply(comment.id)">发送</n-button>
                <n-button size="small" @click="replyTo = null">取消</n-button>
              </n-space>
            </n-space>
            <!-- 子评论 -->
            <div v-for="reply in comment.replies" :key="reply.id" style="margin-top:10px;padding-left:12px;border-left:2px solid #eee">
              <n-space align="center">
                <n-avatar v-if="reply.user?.avatar" :src="reply.user?.avatar" round size="tiny" />
                <n-avatar v-else round size="tiny">{{ reply.user?.nickname?.[0] }}</n-avatar>
                <span style="font-weight:600;font-size:12px">{{ reply.user?.nickname }}</span>
              </n-space>
              <div style="font-size:13px;margin-top:4px">{{ reply.content }}</div>
            </div>
          </div>
        </n-space>
        <n-divider style="margin:12px 0" />
      </div>
      <div v-if="total > list.length" style="text-align:center">
        <n-button text @click="loadMore">加载更多</n-button>
      </div>
    </n-spin>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { NSpace, NAvatar, NInput, NButton, NDivider, NSpin, NRate, useMessage } from 'naive-ui'
import { smartTime } from '@/utils/timeUtils'
import { getComments, createComment, removeComment, likeComment as apiLike, checkCommentLikes, uploadCommentImage } from '@/api/social'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  targetType: { type: Number, required: true },
  targetId: { type: Number, required: true }
})

const msg = useMessage()
const userStore = useUserStore()
const list = ref([])
const total = ref(0)
const page = ref(1)
const loading = ref(false)
const submitting = ref(false)
const form = ref({ content: '', rating: 0, images: [] })
const uploading = ref(false)
const replyTo = ref(null)
const replyContent = ref('')
const likedSet = reactive(new Set())

async function load(reset = false) {
  if (reset) { page.value = 1; list.value = []; likedSet.clear() }
  loading.value = true
  const res = await getComments({ target_type: props.targetType, target_id: props.targetId, page: page.value }).finally(() => loading.value = false)
  total.value = res.data.total
  list.value = reset ? res.data.list : [...list.value, ...res.data.list]
  // 批量加载当前用户的点赞状态
  if (userStore.isLoggedIn && list.value.length) {
    try {
      const ids = list.value.map(c => c.id)
      const likeRes = await checkCommentLikes(ids)
      likeRes.data.forEach(id => likedSet.add(id))
    } catch (e) { /* 未登录或接口异常忽略 */ }
  }
}

function loadMore() { page.value++; load() }

async function submit() {
  if (!form.value.content.trim()) return msg.warning('评论内容不能为空')
  submitting.value = true
  try {
    const payload = {
      target_type: props.targetType,
      target_id: props.targetId,
      content: form.value.content,
      rating: form.value.rating || undefined,
      images: form.value.images.length ? form.value.images : undefined
    }
    await createComment(payload)
    form.value = { content: '', rating: 0, images: [] }
    msg.success('评论发布成功')
    load(true)
  } finally { submitting.value = false }
}

// 处理图片上传
async function handleImageUpload(e) {
  const file = e.target.files?.[0]
  if (!file) return
  e.target.value = '' // 重置 input 以允许重复选择同一文件
  if (form.value.images.length >= 3) return msg.warning('最多上传 3 张图片')
  uploading.value = true
  try {
    const res = await uploadCommentImage(file)
    form.value.images.push(res.data.url)
  } catch (err) {
    msg.error('图片上传失败')
  } finally { uploading.value = false }
}

async function submitReply(parentId) {
  if (!replyContent.value.trim()) return
  await createComment({ target_type: props.targetType, target_id: props.targetId, content: replyContent.value, parent_id: parentId })
  replyTo.value = null; replyContent.value = ''
  load(true)
}

async function toggleLike(comment) {
  if (!userStore.isLoggedIn) return msg.warning('请先登录')
  const res = await apiLike(comment.id)
  comment.like_count = res.data.like_count
  if (res.data.liked) {
    likedSet.add(comment.id)
  } else {
    likedSet.delete(comment.id)
  }
}

async function deleteComment(id) {
  await removeComment(id)
  msg.success('已删除')
  load(true)
}

onMounted(() => load(true))
</script>

<style scoped>
.like-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: none;
  border: 1px solid #e0e0e0;
  border-radius: 16px;
  padding: 2px 10px;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  transition: all .2s;
}
.like-btn:hover {
  border-color: #f43f5e;
  color: #f43f5e;
}
.like-btn.liked {
  background: #fef2f2;
  border-color: #f43f5e;
  color: #f43f5e;
  font-weight: 600;
}
.like-btn:active {
  transform: scale(1.15);
}

/* 图片上传区域 */
.upload-area {
  display: flex; align-items: center; gap: 8px;
}
.img-preview-list {
  display: flex; gap: 8px; flex-wrap: wrap;
}
.img-preview-item {
  position: relative; width: 64px; height: 64px;
  border-radius: 6px; overflow: hidden;
  border: 1px solid #e0e0e0;
}
.img-preview-item img {
  width: 100%; height: 100%; object-fit: cover;
}
.img-remove {
  position: absolute; top: 2px; right: 2px;
  width: 18px; height: 18px; border-radius: 50%;
  background: rgba(0,0,0,.55); color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; cursor: pointer; line-height: 1;
}
.img-remove:hover { background: #e74c3c; }
.img-add-btn {
  width: 64px; height: 64px; border-radius: 6px;
  border: 1px dashed #ccc; cursor: pointer;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  color: #999; transition: all .2s;
}
.img-add-btn:hover { border-color: #2d8cf0; color: #2d8cf0; }
</style>
