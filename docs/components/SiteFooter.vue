<script setup lang="ts">
import { computed } from 'vue'
import { useT } from '../.vitepress/i18n'
const t = useT()
const copyright = computed(() => `© ${new Date().getFullYear()} ${t('footer.association')}`)
</script>

<template>
  <footer class="site-footer">
    <div class="footer-content">
      <span class="footer-copyright">{{ copyright }}</span>
      <span class="footer-separator">·</span>
      <span class="footer-credits">
        {{ t('footer.builtBy') }}
        <a href="https://chemaclass.com" target="_blank" rel="noopener">Chema</a>
        ·
        <a href="https://github.com/Chemaclass/website-windmuehle" target="_blank" rel="noopener">GitHub</a>
        ·
        <a :href="t('footer.links.imprint.href')">{{ t('footer.links.imprint.text') }}</a>
      </span>
    </div>
  </footer>
</template>

<style scoped>
.site-footer {
  background: linear-gradient(135deg, #1e3a5f 0%, #152a45 100%);
  color: #fff;
  padding: 1.5rem 1rem;
  margin-top: auto;
}

.footer-content {
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
}

.footer-separator {
  color: rgba(255, 255, 255, 0.4);
}

.footer-credits a {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  transition: color 0.2s ease;
}

.footer-credits a:hover {
  color: #e8a838;
}

@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    gap: 0.25rem;
  }

  .footer-separator {
    display: none;
  }
}
</style>
