<template>
  <div class="lyrics-page" :style="bgStyle">
    <div class="lyrics-overlay" />

    <div v-if="currentSong" class="lyrics-content">
      <div class="lyrics-left">
        <CoverArt :url="currentSong.coverUrl" :size="280" :radius="14" :show-shadow="true" />
        <div class="song-meta">
          <div class="song-name">{{ currentSong.name }}</div>
          <div class="song-artist">{{ currentSong.artist }}</div>
        </div>
      </div>

      <div class="lyrics-right">
        <div v-if="loading" class="lyrics-loading">加载歌词中...</div>
        <div v-else-if="lines.length === 0" class="lyrics-empty">暂无歌词</div>
        <div v-else class="lyrics-scroll" ref="scrollContainer">
          <div
            v-for="(line, i) in lines"
            :key="i"
            class="lyrics-line"
            :class="{ active: i === activeLine }"
          >
            {{ line.text }}
          </div>
        </div>
      </div>
    </div>

    <div v-else class="no-song">
      当前没有正在播放的歌曲
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import axios from 'axios';
import { usePlayerStore } from '../stores/player.js';
import CoverArt from '../components/CoverArt.vue';

const store = usePlayerStore();
const currentSong = computed(() => store.currentSong);

interface LyricLine {
  time: number;
  text: string;
}

const lines = ref<LyricLine[]>([]);
const activeLine = ref(0);
const loading = ref(false);
const scrollContainer = ref<HTMLElement | null>(null);
const dominantColor = ref('');

const bgStyle = computed(() => {
  if (currentSong.value?.coverUrl) {
    return {
      backgroundImage: `url(${currentSong.value.coverUrl})`,
      backgroundSize: 'cover',
      backgroundPosition: 'center',
    };
  }
  return {};
});

async function fetchLyrics() {
  if (!currentSong.value) return;
  loading.value = true;
  lines.value = [];

  try {
    const res = await axios.get(`/api/music/lyrics/${currentSong.value.id}`, {
      params: { platform: currentSong.value.platform },
    });
    lines.value = res.data.lyrics || [];
  } catch {
    lines.value = [];
  } finally {
    loading.value = false;
  }
}

watch(currentSong, () => {
  fetchLyrics();
});

onMounted(() => {
  if (currentSong.value) fetchLyrics();
});
</script>

<style lang="scss" scoped>
.lyrics-page {
  position: fixed;
  inset: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lyrics-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(60px);
  -webkit-backdrop-filter: blur(60px);
}

.lyrics-content {
  position: relative;
  z-index: 1;
  display: flex;
  gap: 60px;
  max-width: 1000px;
  width: 100%;
  padding: 40px;
}

.lyrics-left {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.song-meta {
  text-align: center;
}

.song-name {
  font-size: 20px;
  font-weight: 700;
  color: white;
  margin-bottom: 4px;
}

.song-artist {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
}

.lyrics-right {
  flex: 1;
  max-height: 400px;
  overflow-y: auto;
}

.lyrics-scroll {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 40px 0;
}

.lyrics-line {
  font-size: 18px;
  color: rgba(255, 255, 255, 0.35);
  transition: all 0.3s ease;
  cursor: pointer;

  &.active {
    font-size: 22px;
    font-weight: 600;
    color: white;
  }

  &:hover {
    color: rgba(255, 255, 255, 0.6);
  }
}

.lyrics-loading,
.lyrics-empty {
  color: rgba(255, 255, 255, 0.5);
  font-size: 14px;
  text-align: center;
  padding: 60px 0;
}

.no-song {
  position: relative;
  z-index: 1;
  color: rgba(255, 255, 255, 0.5);
  font-size: 16px;
}
</style>
