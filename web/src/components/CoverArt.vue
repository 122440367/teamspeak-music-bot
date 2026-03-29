<template>
  <div class="cover-art" :style="{ width: size + 'px', height: size + 'px' }">
    <img
      :src="url"
      :alt="alt"
      class="cover-img"
      :style="{ borderRadius: radius + 'px' }"
      @load="onImageLoad"
      crossorigin="anonymous"
    />
    <div
      v-if="showShadow"
      class="cover-shadow"
      :style="{
        backgroundImage: `url(${url})`,
        borderRadius: radius + 'px',
      }"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

withDefaults(defineProps<{
  url: string;
  size?: number;
  radius?: number;
  alt?: string;
  showShadow?: boolean;
}>(), {
  size: 48,
  radius: 8,
  alt: 'Cover',
  showShadow: false,
});

const loaded = ref(false);

function onImageLoad() {
  loaded.value = true;
}
</script>

<style lang="scss" scoped>
.cover-art {
  position: relative;
  flex-shrink: 0;
}

.cover-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: relative;
  z-index: 1;
}

.cover-shadow {
  position: absolute;
  top: 12px;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  filter: blur(16px);
  opacity: 0.6;
  transform: scale(0.92);
  z-index: 0;
  transition: opacity 0.3s ease;
}
</style>
