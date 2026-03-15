<template>
  <div class="settings-page">
    <div class="settings-header">
      <h2>⚙️ 账号设置</h2>
      <p>管理你的个人资料、技能标签和账号安全</p>
    </div>

    <!-- 基本信息 -->
    <div class="settings-section">
      <h3 class="section-title">👤 基本信息</h3>
      <div class="section-body">
        <!-- 头像区域 -->
        <div class="avatar-area">
          <label class="avatar-wrapper">
            <input type="file" accept="image/*" style="display:none" @change="onAvatarSelect" />
            <img v-if="avatarUrl" :src="avatarUrl" class="avatar-img" />
            <div v-else class="avatar-fallback">{{ userStore.info?.nickname?.[0] }}</div>
            <div class="avatar-overlay"><span>📷</span></div>
          </label>
          <div class="avatar-hint">点击头像更换<br/><span style="font-size:11px;color:#bbb">支持 JPG、PNG，建议 200×200</span></div>
        </div>

        <n-form :model="form" label-placement="top" style="margin-top:20px">
          <n-grid :cols="2" :x-gap="16">
            <n-grid-item>
              <n-form-item label="昵称">
                <n-input v-model:value="form.nickname" placeholder="你的昵称" />
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="性别">
                <n-radio-group v-model:value="form.gender">
                  <n-space>
                    <n-radio :value="0">🔒 保密</n-radio>
                    <n-radio :value="1">♂ 男</n-radio>
                    <n-radio :value="2">♀ 女</n-radio>
                  </n-space>
                </n-radio-group>
              </n-form-item>
            </n-grid-item>
          </n-grid>
          <n-form-item label="简介">
            <n-input v-model:value="form.bio" type="textarea" :rows="3" :maxlength="300" show-count placeholder="介绍一下你自己..." />
          </n-form-item>
          <n-form-item label="徒步等级">
            <n-rate v-model:value="form.level" :count="5" />
            <span style="margin-left:8px;font-size:12px;color:#999">当前 Lv.{{ form.level }}</span>
          </n-form-item>
          <div style="text-align:right">
            <n-button type="primary" round :loading="saving" @click="saveProfile">💾 保存资料</n-button>
          </div>
        </n-form>
      </div>
    </div>

    <!-- 技能标签 -->
    <div class="settings-section">
      <h3 class="section-title">🎯 技能标签</h3>
      <div class="section-body">
        <p style="color:#888;font-size:13px;margin:0 0 12px">选择你擅长的户外技能</p>
        <div class="skill-grid">
          <label v-for="tag in allTags" :key="tag.id"
            :class="['skill-option', { active: selectedSkills.includes(tag.id) }]"
            @click="toggleSkill(tag.id)">
            {{ tag.name }}
          </label>
        </div>
        <div style="text-align:right;margin-top:16px">
          <n-button type="primary" round @click="saveSkills">💾 保存技能</n-button>
        </div>
      </div>
    </div>

    <!-- 修改密码 -->
    <div class="settings-section">
      <h3 class="section-title">🔐 修改密码</h3>
      <div class="section-body">
        <n-form :model="pwdForm" label-placement="top">
          <n-grid :cols="2" :x-gap="16">
            <n-grid-item>
              <n-form-item label="原密码">
                <n-input v-model:value="pwdForm.oldPassword" type="password" show-password-on="click" placeholder="输入当前密码" />
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="新密码">
                <n-input v-model:value="pwdForm.newPassword" type="password" show-password-on="click" placeholder="输入新密码" />
              </n-form-item>
            </n-grid-item>
          </n-grid>
          <div style="text-align:right">
            <n-button type="warning" round :loading="savingPwd" @click="savePassword">🔑 修改密码</n-button>
          </div>
        </n-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  NForm, NFormItem, NInput, NButton, NSpace, NAvatar, NGrid, NGridItem,
  NRadioGroup, NRadio, NRate, useMessage
} from 'naive-ui'
import { updateProfile, updatePassword, updateSkills, getAllSkillTags, getUserSkills } from '@/api/user'
import { useUserStore } from '@/stores/user'

const msg = useMessage()
const userStore = useUserStore()

const form = ref({ nickname: '', bio: '', gender: 0, level: 1, avatar: '' })
const pwdForm = ref({ oldPassword: '', newPassword: '' })
const allTags = ref([])
const selectedSkills = ref([])
const avatarFile = ref(null)
const avatarPreview = ref('')
const saving = ref(false)
const savingPwd = ref(false)

const avatarUrl = computed(() => avatarPreview.value || form.value.avatar || userStore.info?.avatar || '')

function onAvatarSelect(e) {
  const file = e.target.files?.[0]
  if (!file) return
  avatarFile.value = file
  // 生成本地预览
  const reader = new FileReader()
  reader.onload = (ev) => { avatarPreview.value = ev.target.result }
  reader.readAsDataURL(file)
}

function toggleSkill(id) {
  const idx = selectedSkills.value.indexOf(id)
  if (idx >= 0) selectedSkills.value.splice(idx, 1)
  else selectedSkills.value.push(id)
}

onMounted(async () => {
  // 确保 user info 已加载
  if (!userStore.info) await userStore.fetchMe()
  const info = userStore.info
  if (info) {
    form.value = {
      nickname: info.nickname || '',
      bio: info.bio || '',
      gender: info.gender ?? 0,
      level: info.level || 1,
      avatar: info.avatar || ''
    }
  }
  const [tagRes, skillRes] = await Promise.all([getAllSkillTags(), getUserSkills(info.id)])
  allTags.value = tagRes.data
  selectedSkills.value = skillRes.data.map(s => s.id)
})

async function saveProfile() {
  saving.value = true
  try {
    const fd = new FormData()
    ;['nickname', 'bio', 'gender', 'level'].forEach(k => fd.append(k, form.value[k]))
    if (avatarFile.value) fd.append('avatar', avatarFile.value)
    await updateProfile(fd)
    await userStore.fetchMe()
    // 同步最新头像到表单
    form.value.avatar = userStore.info?.avatar || ''
    avatarPreview.value = ''
    avatarFile.value = null
    msg.success('保存成功 ✅')
  } finally { saving.value = false }
}

async function saveSkills() {
  await updateSkills({ tagIds: selectedSkills.value })
  msg.success('技能标签已更新 ✅')
}

async function savePassword() {
  if (!pwdForm.value.oldPassword || !pwdForm.value.newPassword) return msg.warning('请填写完整')
  savingPwd.value = true
  try {
    await updatePassword(pwdForm.value)
    msg.success('密码修改成功 ✅')
    pwdForm.value = { oldPassword: '', newPassword: '' }
  } finally { savingPwd.value = false }
}
</script>

<style scoped>
.settings-page { max-width: 680px; margin: 0 auto; }

.settings-header {
  margin-bottom: 24px;
}
.settings-header h2 { margin: 0; font-size: 24px; font-weight: 800; color: #1a1a2e; }
.settings-header p { margin: 4px 0 0; font-size: 14px; color: #999; }

.settings-section {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 14px;
  margin-bottom: 16px;
  overflow: hidden;
}
.section-title {
  margin: 0;
  padding: 16px 20px;
  font-size: 15px;
  font-weight: 600;
  color: #333;
  background: #fafbfc;
  border-bottom: 1px solid #f0f0f0;
}
.section-body {
  padding: 20px;
}

/* 头像区域 */
.avatar-area {
  display: flex;
  align-items: center;
  gap: 16px;
}
.avatar-wrapper {
  position: relative;
  cursor: pointer;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}
.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.avatar-fallback {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #e0e0e0, #bdbdbd);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
  font-weight: 700;
}
.avatar-overlay {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(0,0,0,.4);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  opacity: 0;
  transition: opacity .3s;
  cursor: pointer;
}
.avatar-wrapper:hover .avatar-overlay { opacity: 1; }
.avatar-hint {
  font-size: 13px;
  color: #666;
  line-height: 1.5;
}

/* 技能标签选择 */
.skill-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.skill-option {
  padding: 6px 16px;
  border-radius: 20px;
  border: 1px solid #e0e0e0;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  transition: all .2s;
  user-select: none;
}
.skill-option:hover { border-color: #2d8cf0; color: #2d8cf0; }
.skill-option.active {
  background: linear-gradient(135deg, #2d8cf0, #0ea5e9);
  color: #fff;
  border-color: transparent;
  font-weight: 600;
}
</style>
