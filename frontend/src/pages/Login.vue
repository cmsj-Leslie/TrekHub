<template>
  <div style="max-width:400px;margin:80px auto">
    <n-card title="登录 TrekHub">
      <n-form ref="formRef" :model="form" :rules="rules" @submit.prevent="submit">
        <n-form-item label="账号（用户名/邮箱）" path="account">
          <n-input v-model:value="form.account" placeholder="请输入账号" />
        </n-form-item>
        <n-form-item label="密码" path="password">
          <n-input v-model:value="form.password" type="password" show-password-on="click" placeholder="请输入密码" />
        </n-form-item>
        <n-button type="primary" block attr-type="submit" :loading="loading">登录</n-button>
      </n-form>
      <template #footer>
        没有账号？<router-link to="/register">立即注册</router-link>
      </template>
    </n-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { NCard, NForm, NFormItem, NInput, NButton, useMessage } from 'naive-ui'
import { useUserStore } from '@/stores/user'
import { useChatStore } from '@/stores/chat'

const router = useRouter()
const msg = useMessage()
const userStore = useUserStore()
const chatStore = useChatStore()

const formRef = ref(null)
const form = ref({ account: '', password: '' })
const loading = ref(false)

const rules = {
  account: { required: true, message: '请输入账号', trigger: 'blur' },
  password: { required: true, message: '请输入密码', trigger: 'blur' }
}

async function submit() {
  try { await formRef.value?.validate() } catch { return }
  loading.value = true
  try {
    await userStore.doLogin(form.value)
    chatStore.connect(userStore.token)
    chatStore.loadRooms()
    msg.success('登录成功')
    router.push('/')
  } catch (e) {
    msg.error(e?.msg || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>
