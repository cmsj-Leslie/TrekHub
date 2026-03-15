<template>
  <div style="max-width:800px;margin:0 auto">
    <n-page-header title="创建新线路" @back="$router.back()" />
    <n-card style="margin-top:16px">
      <n-form ref="formRef" :model="form" :rules="rules" label-placement="left" label-width="90px">
        <n-form-item label="线路名称" path="title">
          <n-input v-model:value="form.title" placeholder="简洁描述这条线路" />
        </n-form-item>
        <n-grid :cols="2" :x-gap="16">
          <n-grid-item>
            <n-form-item label="难度" path="difficulty">
              <n-select v-model:value="form.difficulty" :options="difficultyOptions" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="地区" path="region">
              <n-input v-model:value="form.region" placeholder="如：四川成都" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="距离(km)" path="distance_km">
              <n-input-number v-model:value="form.distance_km" :min="0" :precision="1" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="爬升(m)">
              <n-input-number v-model:value="form.elevation_m" :min="0" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="时长(h)">
              <n-input-number v-model:value="form.duration_h" :min="0" :precision="1" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="封面图">
              <n-upload :max="1" list-type="image-card" accept="image/*" @change="onCoverChange">
                <n-button>选择图片</n-button>
              </n-upload>
            </n-form-item>
          </n-grid-item>
        </n-grid>
        <n-form-item label="线路描述">
          <n-input v-model:value="form.description" type="textarea" :rows="4" placeholder="描述线路特点、难点、注意事项..." />
        </n-form-item>

        <!-- 地图绘制 -->
        <n-form-item label="绘制轨迹">
          <div style="width:100%">
            <n-space style="margin-bottom:8px">
              <n-button @click="enableDraw" type="primary" size="small">开始绘制</n-button>
              <n-button @click="disableDraw" size="small">停止绘制</n-button>
              <n-button @click="clearDraw" size="small">清除</n-button>
              <n-upload :max="1" accept=".gpx" @change="onGpxChange">
                <n-button size="small">导入GPX</n-button>
              </n-upload>
              <span style="color:#999;font-size:12px">已标记 {{ drawPoints.length }} 个点</span>
            </n-space>
            <div id="create-map" style="height:400px;border-radius:8px;border:1px solid #eee"></div>
          </div>
        </n-form-item>

        <n-space justify="end">
          <n-button @click="$router.back()">取消</n-button>
          <n-button type="primary" :loading="submitting" @click="submit">发布线路</n-button>
        </n-space>
      </n-form>
    </n-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  NPageHeader, NCard, NForm, NFormItem, NInput, NInputNumber, NSelect,
  NGrid, NGridItem, NButton, NSpace, NUpload, useMessage
} from 'naive-ui'
import { createRoute, uploadGpx } from '@/api/route'
import { useMap } from '@/composables/useMap'

const router = useRouter()
const msg = useMessage()
const formRef = ref(null)
const { drawPoints, init, enableDraw, disableDraw, clearDraw, drawRoute } = useMap('create-map')

const form = ref({
  title: '', difficulty: 2, region: '', distance_km: 0,
  elevation_m: 0, duration_h: 0, description: ''
})
const coverFile = ref(null)
const submitting = ref(false)

const difficultyOptions = [
  { label: '简单', value: 1 }, { label: '中等', value: 2 },
  { label: '困难', value: 3 }, { label: '专家', value: 4 }
]

const rules = {
  title: { required: true, message: '请输入线路名称', trigger: 'blur' },
  difficulty: { required: true, type: 'number', message: '请选择难度等级', trigger: 'change' },
  region: { required: true, message: '请输入地区', trigger: 'blur' },
  distance_km: { required: true, type: 'number', min: 0.1, message: '请输入线路距离', trigger: 'blur' }
}

function onCoverChange({ fileList }) { coverFile.value = fileList[0]?.file || null }

async function onGpxChange({ fileList }) {
  const file = fileList[0]?.file
  if (!file) return
  const fd = new FormData()
  fd.append('gpx', file)
  const res = await uploadGpx(fd)
  drawPoints.value = res.data.points
  drawRoute(res.data.points)
  msg.success(`已解析 ${res.data.points.length} 个坐标点`)
}

async function submit() {
  try { await formRef.value?.validate() } catch { return }
  if (!drawPoints.value.length) return msg.warning('请在地图上绘制线路轨迹')
  submitting.value = true
  try {
    const fd = new FormData()
    Object.entries(form.value).forEach(([k, v]) => fd.append(k, v))
    if (coverFile.value) fd.append('cover_image', coverFile.value)
    fd.append('start_lng', drawPoints.value[0].lng)
    fd.append('start_lat', drawPoints.value[0].lat)
    fd.append('points', JSON.stringify(drawPoints.value))
    const res = await createRoute(fd)
    msg.success('线路发布成功')
    router.push(`/routes/${res.data.id}`)
  } catch (e) {
    msg.error(e?.msg || '发布失败')
  } finally { submitting.value = false }
}

onMounted(init)
</script>
