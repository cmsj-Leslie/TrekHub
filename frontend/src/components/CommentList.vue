<template>
  <div>
    <!-- 发表评论 -->
    <n-space v-if="userStore.isLoggedIn" vertical style="margin-bottom:16px">
      <n-rate v-if="targetType === 1" v-model:value="form.rating" />
      <n-input v-model:value="form.content" type="textarea" placeholder="写下你的评价..." :rows="3" />
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
            <!-- 回复 -->
            <n-space style="margin-top:6px">
              <n-button text size="small" @click="likeComment(comment)">👍 {{ comment.like_count }}</n-button>
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
import { ref, onMounted } from 'vue'
import { NSpace, NAvatar, NInput, NButton, NDivider, NSpin, NRate, useMessage } from 'naive-ui'
import { smartTime } from '@/utils/timeUtils'
import { getComments, createComment, removeComment, likeComment as apiLike } from '@/api/social'
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
const form = ref({ content: '', rating: 0 })
const replyTo = ref(null)
const replyContent = ref('')

async function load(reset = false) {
  if (reset) { page.value = 1; list.value = [] }
  loading.value = true
  const res = await getComments({ target_type: props.targetType, target_id: props.targetId, page: page.value }).finally(() => loading.value = false)
  total.value = res.data.total
  list.value = reset ? res.data.list : [...list.value, ...res.data.list]
}

function loadMore() { page.value++; load() }

async function submit() {
  if (!form.value.content.trim()) return msg.warning('评论内容不能为空')
  submitting.value = true
  try {
    await createComment({ target_type: props.targetType, target_id: props.targetId, ...form.value })
    form.value = { content: '', rating: 0 }
    msg.success('评论发布成功')
    load(true)
  } finally { submitting.value = false }
}

async function submitReply(parentId) {
  if (!replyContent.value.trim()) return
  await createComment({ target_type: props.targetType, target_id: props.targetId, content: replyContent.value, parent_id: parentId })
  replyTo.value = null; replyContent.value = ''
  load(true)
}

async function likeComment(comment) {
  await apiLike(comment.id)
  comment.like_count++
}

async function deleteComment(id) {
  await removeComment(id)
  msg.success('已删除')
  load(true)
}

onMounted(() => load(true))
</script>
