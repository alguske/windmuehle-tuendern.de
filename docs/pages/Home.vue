<script setup lang="ts">
import { computed } from 'vue'
import { useT } from '../.vitepress/i18n'
import { getSeasonalInfo, getCurrentYear } from '../utils/holidays'

const t = useT()

const seasonalInfo = computed(() => getSeasonalInfo())

const seasonalGreeting = computed(() => {
  const info = seasonalInfo.value
  if (!info.key) return null

  // For New Year, dynamically include the year
  if (info.key === 'newyear') {
    const greeting = t(`home.${info.key}Greeting`)
    return greeting.replace('{year}', String(getCurrentYear()))
  }

  return t(`home.${info.key}Greeting`)
})

const seasonalBackground = computed(() => seasonalInfo.value.background)
</script>

<template>
  <div class="home-hero">
    <div class="hero-content">
      <img src="/imgs/logo.svg" alt="Windmill Logo" class="hero-logo" />
      <h1 class="hero-title">{{ t('home.heroTitle') }}</h1>
      <p class="hero-subtitle">{{ t('home.heroSubtitle') }}</p>
      <p class="hero-text" v-html="t('home.heroText')"></p>
      <a href="spenden" class="cta-button">{{ t('home.heroCta') }}</a>
    </div>
  </div>

  <div class="section-seasonal" :style="{ '--seasonal-bg': `url(${seasonalBackground})` }">
    <div v-if="seasonalGreeting" class="seasonal-banner">
      {{ seasonalGreeting }}
    </div>
  </div>

  <section class="section-light">
    <div class="home-intro">
      <h2>{{ t('home.missionTitle') }}</h2>
      <p v-html="t('home.missionText')"></p>
    </div>
  </section>

  <section class="section-news">
    <div class="news-preview">
      <h2>{{ t('home.newsTitle') }}</h2>
      <div class="news-cards">
        <a v-for="post in t('newsPosts').slice(0, 2)" :key="post.link" :href="post.link" class="news-card">
          <img :src="post.image" :alt="post.title" loading="lazy" />
          <div class="news-card-content">
            <span class="news-date">{{ post.date }}</span>
            <h3>{{ post.title }}</h3>
          </div>
        </a>
      </div>
      <a :href="t('footer.links.news.href')" class="news-link">{{ t('home.allNews') }} →</a>
    </div>
  </section>

  <section class="section-light">
    <div class="home-achieved">
      <div class="card achieved">
        <h3>{{ t('home.achievedTitle') }}</h3>
        <ul>
          <li v-for="(item, i) in t('home.achievedItems')" :key="i" v-html="item"></li>
        </ul>
      </div>
    </div>
  </section>

  <section class="section-dark">
    <div class="home-gallery">
      <a :href="t('footer.links.gallery.href')" class="home-gallery-item" v-for="(item, i) in t('home.gallery')" :key="i" :aria-label="item.text">
        <img :src="item.img" :alt="item.text" loading="lazy" />
        <div class="focus-text">{{ item.text }}</div>
      </a>
    </div>
  </section>

  <section class="section-cta">
    <div class="cta-content">
      <p class="cta-quote">{{ t('home.ctaQuote') }}</p>
      <p class="cta-message">{{ t('home.ctaMessage') }}</p>
      <a :href="t('home.ctaLink')" class="cta-button">{{ t('home.ctaButton') }}</a>
    </div>
  </section>
</template>
