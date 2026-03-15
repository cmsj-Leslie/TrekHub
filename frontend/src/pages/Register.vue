<template>
  <div style="max-width:420px;margin:60px auto">
    <n-card title="注册 TrekHub">
      <n-form ref="formRef" :model="form" :rules="rules" @submit.prevent="submit">
        <n-form-item label="用户名" path="username">
          <n-input v-model:value="form.username" placeholder="2-30个字符" />
        </n-form-item>
        <n-form-item label="邮箱" path="email">
          <n-input v-model:value="form.email" placeholder="请输入邮箱" />
        </n-form-item>
        <n-form-item label="密码" path="password">
          <n-input v-model:value="form.password" type="password" show-password-on="click" placeholder="至少6位" />
        </n-form-item>
        <n-form-item label="昵称（可选）">
          <n-input v-model:value="form.nickname" placeholder="留空则与用户名相同" />
        </n-form-item>
        <n-button type="primary" block attr-type="submit" :loading="loading">注册</n-button>
      </n-form>
      <template #footer>
        已有账号？<router-link to="/login">立即登录</router-link>
      </template>
    </n-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { NCard, NForm, NFormItem, NInput, NButton, useMessage } from 'naive-ui'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const msg = useMessage()
const userStore = useUserStore()
const formRef = ref(null)
const form = ref({ username: '', email: '', password: '', nickname: '' })
const loading = ref(false)

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 30, message: '用户名需要2-30个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ]
}

async function submit() {
  try { await formRef.value?.validate() } catch { return }
  loading.value = true
  try {
    await userStore.doRegister(form.value)
    msg.success('注册成功')
    router.push('/')
  } catch (e) {
    msg.error(e?.msg || '注册失败')
  } finally {
    loading.value = false
  }
}
</script>
