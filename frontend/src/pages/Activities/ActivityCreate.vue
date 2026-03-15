<template>
  <div style="max-width:700px;margin:0 auto">
    <n-page-header title="发起活动" @back="$router.back()" />
    <n-card style="margin-top:16px">
      <n-form ref="formRef" :model="form" :rules="rules" label-placement="left" label-width="100px">
        <n-form-item label="活动标题" path="title">
          <n-input v-model:value="form.title" placeholder="活动标题" />
        </n-form-item>
        <n-form-item label="关联线路" path="route_id">
          <n-select v-model:value="form.route_id" :options="routeOptions" placeholder="选择线路" filterable />
        </n-form-item>
        <n-grid :cols="2" :x-gap="16">
          <n-grid-item>
            <n-form-item label="出发时间" path="start_time">
              <n-date-picker v-model:value="form.start_time" type="datetime" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="结束时间" path="end_time">
              <n-date-picker v-model:value="form.end_time" type="datetime" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="最多人数">
              <n-input-number v-model:value="form.max_members" :min="2" :max="50" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="最低等级">
              <n-input-number v-model:value="form.min_level" :min="1" :max="5" style="width:100%" />
            </n-form-item>
          </n-grid-item>
        </n-grid>
        <n-form-item label="必备装备">
          <n-input v-model:value="form.gear_require" placeholder="列出必备装备" />
        </n-form-item>
        <n-form-item label="安全提示" path="safety_info">
          <n-input v-model:value="form.safety_info" type="textarea" :rows="3" placeholder="必填：下撤路线、紧急联系方式、注意事项" />
        </n-form-item>
        <n-form-item label="活动介绍">
          <n-input v-model:value="form.description" type="textarea" :rows="3" placeholder="活动详细介绍" />
        </n-form-item>
        <n-space justify="end">
          <n-button @click="$router.back()">取消</n-button>
          <n-button type="primary" :loading="submitting" @click="submit">发布活动</n-button>
        </n-space>
      </n-form>
    </n-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute as useVRoute } from 'vue-router'
import {
  NPageHeader, NCard, NForm, NFormItem, NInput, NInputNumber, NSelect,
  NDatePicker, NGrid, NGridItem, NButton, NSpace, useMessage
} from 'naive-ui'
import { createActivity } from '@/api/activity'
import { getRoutes } from '@/api/route'

const router = useRouter()
const vRoute = useVRoute()
const msg = useMessage()

const formRef = ref(null)
const routeOptions = ref([])
const submitting = ref(false)

const form = ref({
  route_id: +vRoute.query.routeId || null,
  title: '', start_time: null, end_time: null,
  max_members: 10, min_level: 1, gear_require: '', safety_info: '', description: ''
})

const rules = {
  title: { required: true, message: '请输入活动标题', trigger: 'blur' },
  route_id: { required: true, type: 'number', message: '请选择关联线路', trigger: 'change' },
  start_time: { required: true, type: 'number', message: '请选择出发时间', trigger: 'change' },
  end_time: { required: true, type: 'number', message: '请选择结束时间', trigger: 'change' },
  safety_info: { required: true, message: '请填写安全提示信息', trigger: 'blur' }
}

onMounted(async () => {
  const res = await getRoutes({ pageSize: 100 })
  routeOptions.value = res.data.list.map(r => ({ label: r.title, value: r.id }))
})

async function submit() {
  try { await formRef.value?.validate() } catch { return }
  if (form.value.end_time <= form.value.start_time) return msg.warning('结束时间必须晚于出发时间')
  submitting.value = true
  try {
    const data = { ...form.value, start_time: new Date(form.value.start_time), end_time: new Date(form.value.end_time) }
    const res = await createActivity(data)
    msg.success('活动发布成功')
    router.push(`/activities/${res.data.activity.id}`)
  } catch (e) {
    msg.error(e?.msg || '发布失败')
  } finally { submitting.value = false }
}
</script>
