<template>
  <div class="settings-page">
    <h1 class="page-title">设置</h1>

    <!-- Theme Toggle -->
    <section class="settings-section">
      <h2 class="section-title">外观</h2>
      <div class="setting-row">
        <div class="setting-label">
          <Icon icon="mdi:theme-light-dark" class="setting-icon" />
          主题模式
        </div>
        <button class="theme-toggle" @click="store.toggleTheme()">
          <Icon :icon="store.theme === 'dark' ? 'mdi:weather-night' : 'mdi:weather-sunny'" />
          {{ store.theme === 'dark' ? '深色' : '浅色' }}
        </button>
      </div>
    </section>

    <!-- Bot Management -->
    <section class="settings-section">
      <h2 class="section-title">机器人管理</h2>
      <div class="bot-list">
        <div v-for="bot in store.bots" :key="bot.id" class="bot-item">
          <div class="bot-info">
            <div class="bot-name">{{ bot.name }}</div>
            <div class="bot-status" :class="{ online: bot.connected }">
              {{ bot.connected ? '在线' : '离线' }}
            </div>
          </div>
          <div class="bot-actions">
            <button class="btn-sm" @click="toggleBot(bot.id, bot.connected)">
              {{ bot.connected ? '停止' : '启动' }}
            </button>
          </div>
        </div>
      </div>

      <div class="create-bot">
        <h3 class="subsection-title">创建新实例</h3>
        <div class="form-row">
          <input v-model="newBotName" class="input" placeholder="机器人名称" />
          <input v-model="newBotServer" class="input" placeholder="TS服务器地址" />
          <button class="btn-primary" @click="createBot">创建</button>
        </div>
      </div>
    </section>

    <!-- Music Account -->
    <section class="settings-section">
      <h2 class="section-title">音乐账号</h2>
      <div class="setting-row">
        <div class="setting-label">
          <Icon icon="mdi:music-note" class="setting-icon" />
          网易云登录Cookie
        </div>
        <div class="cookie-input-wrap">
          <textarea
            v-model="neteaseCookie"
            class="textarea"
            placeholder="粘贴网易云音乐Cookie..."
            rows="3"
          />
          <button class="btn-primary" @click="saveCookie('netease')">保存</button>
        </div>
      </div>
      <div class="setting-row">
        <div class="setting-label">
          <Icon icon="mdi:music-note" class="setting-icon" />
          QQ音乐登录Cookie
        </div>
        <div class="cookie-input-wrap">
          <textarea
            v-model="qqCookie"
            class="textarea"
            placeholder="粘贴QQ音乐Cookie..."
            rows="3"
          />
          <button class="btn-primary" @click="saveCookie('qq')">保存</button>
        </div>
      </div>
    </section>

    <!-- Command Prefix -->
    <section class="settings-section">
      <h2 class="section-title">命令设置</h2>
      <div class="setting-row">
        <div class="setting-label">
          <Icon icon="mdi:console" class="setting-icon" />
          命令前缀
        </div>
        <div class="prefix-input-wrap">
          <input v-model="commandPrefix" class="input input-sm" placeholder="!" />
          <button class="btn-primary" @click="savePrefix">保存</button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { Icon } from '@iconify/vue';
import axios from 'axios';
import { usePlayerStore } from '../stores/player.js';

const store = usePlayerStore();

const newBotName = ref('');
const newBotServer = ref('');
const neteaseCookie = ref('');
const qqCookie = ref('');
const commandPrefix = ref('!');

async function createBot() {
  if (!newBotName.value || !newBotServer.value) return;
  try {
    await axios.post('/api/bot', {
      name: newBotName.value,
      server: newBotServer.value,
    });
    newBotName.value = '';
    newBotServer.value = '';
    await store.fetchBots();
  } catch {
    // Ignore
  }
}

async function toggleBot(botId: string, connected: boolean) {
  try {
    if (connected) {
      await axios.post(`/api/bot/${botId}/stop`);
    } else {
      await axios.post(`/api/bot/${botId}/start`);
    }
    await store.fetchBots();
  } catch {
    // Ignore
  }
}

async function saveCookie(platform: string) {
  const cookie = platform === 'netease' ? neteaseCookie.value : qqCookie.value;
  try {
    await axios.post('/api/settings/cookie', { platform, cookie });
  } catch {
    // Ignore
  }
}

async function savePrefix() {
  try {
    await axios.post('/api/settings/prefix', { prefix: commandPrefix.value });
  } catch {
    // Ignore
  }
}
</script>

<style lang="scss" scoped>
.page-title {
  font-size: 28px;
  font-weight: 800;
  margin-bottom: 32px;
}

.settings-section {
  margin-bottom: 36px;
  padding: 24px;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
}

.section-title {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 16px;
}

.subsection-title {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 12px;
  margin-top: 16px;
}

.setting-row {
  margin-bottom: 16px;
}

.setting-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 8px;
}

.setting-icon {
  font-size: 18px;
  opacity: 0.6;
}

.theme-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  background: var(--hover-bg);
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  transition: all var(--transition-fast);

  &:hover { background: var(--color-primary); color: white; }
}

.bot-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.bot-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: var(--hover-bg);
  border-radius: var(--radius-md);
}

.bot-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bot-name {
  font-size: 14px;
  font-weight: 500;
}

.bot-status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  background: var(--border-color);
  color: var(--text-tertiary);

  &.online {
    background: rgba(51, 94, 234, 0.15);
    color: var(--color-primary);
  }
}

.form-row {
  display: flex;
  gap: 8px;
}

.input {
  flex: 1;
  padding: 10px 14px;
  background: var(--hover-bg);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  color: var(--text-primary);
  font-family: inherit;
  font-size: 13px;
  outline: none;

  &:focus { border-color: var(--color-primary); }
}

.input-sm {
  max-width: 80px;
}

.textarea {
  width: 100%;
  padding: 10px 14px;
  background: var(--hover-bg);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  color: var(--text-primary);
  font-family: inherit;
  font-size: 13px;
  outline: none;
  resize: vertical;

  &:focus { border-color: var(--color-primary); }
}

.cookie-input-wrap {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.prefix-input-wrap {
  display: flex;
  gap: 8px;
  align-items: center;
}

.btn-primary {
  padding: 10px 20px;
  background: var(--color-primary);
  color: white;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  transition: transform var(--transition-fast);

  &:hover { transform: scale(1.02); }
  &:active { transform: scale(0.98); }
}

.btn-sm {
  padding: 6px 14px;
  background: var(--hover-bg);
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  transition: all var(--transition-fast);

  &:hover { background: var(--color-primary); color: white; }
}
</style>
