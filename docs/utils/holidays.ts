/**
 * German public holidays utility
 * Calculates dates and provides greetings for seasonal banners
 */

export interface SeasonalInfo {
  key: string | null      // i18n key suffix (e.g., 'newyear', 'weihnachten') or null if no holiday
  background: string      // Background image path
}

/**
 * Calculate Easter Sunday using the Anonymous Gregorian algorithm (Computus)
 */
function getEasterDate(year: number): Date {
  const a = year % 19
  const b = Math.floor(year / 100)
  const c = year % 100
  const d = Math.floor(b / 4)
  const e = b % 4
  const f = Math.floor((b + 8) / 25)
  const g = Math.floor((b - f + 1) / 3)
  const h = (19 * a + b - d - g + 15) % 30
  const i = Math.floor(c / 4)
  const k = c % 4
  const l = (32 + 2 * e + 2 * i - h - k) % 7
  const m = Math.floor((a + 11 * h + 22 * l) / 451)
  const month = Math.floor((h + l - 7 * m + 114) / 31) - 1
  const day = ((h + l - 7 * m + 114) % 31) + 1
  return new Date(year, month, day)
}

/**
 * Add days to a date
 */
function addDays(date: Date, days: number): Date {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

/**
 * Check if a date is within a range (inclusive)
 */
function isDateInRange(date: Date, start: Date, end: Date): boolean {
  const d = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  const s = new Date(start.getFullYear(), start.getMonth(), start.getDate())
  const e = new Date(end.getFullYear(), end.getMonth(), end.getDate())
  return d >= s && d <= e
}

/**
 * Check if two dates are the same day
 */
function isSameDay(date1: Date, date2: Date): boolean {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  )
}

// Background images for different seasons
const BACKGROUNDS = {
  default: '/imgs/bilder/windmill-7.jpeg',
  winter: '/imgs/winter/windmuelle-snow1.jpg',
  spring: '/imgs/pfingstmontag/pfingstmontag3.jpeg',
  mayDay: '/imgs/bilder/windmill-6.jpeg',
  autumn: '/imgs/bilder/windmill-3.jpeg'
}

/**
 * Get current seasonal information (holiday key and background)
 */
export function getSeasonalInfo(date: Date = new Date()): SeasonalInfo {
  const year = date.getFullYear()
  const month = date.getMonth()
  const day = date.getDate()

  // Christmas: Dec 20-31
  if (month === 11 && day >= 20) {
    return { key: 'weihnachten', background: BACKGROUNDS.winter }
  }

  // New Year: Jan 1-15
  if (month === 0 && day <= 15) {
    return { key: 'newyear', background: BACKGROUNDS.winter }
  }

  // Calculate Easter-based holidays
  const easter = getEasterDate(year)
  const goodFriday = addDays(easter, -2)
  const easterMonday = addDays(easter, 1)
  const ascension = addDays(easter, 39)
  const whitMonday = addDays(easter, 50)

  // Good Friday (Karfreitag)
  if (isSameDay(date, goodFriday)) {
    return { key: 'karfreitag', background: BACKGROUNDS.spring }
  }

  // Easter Sunday and Monday (Ostern)
  if (isSameDay(date, easter) || isSameDay(date, easterMonday)) {
    return { key: 'ostern', background: BACKGROUNDS.spring }
  }

  // Labour Day: May 1
  if (month === 4 && day === 1) {
    return { key: 'tagDerArbeit', background: BACKGROUNDS.mayDay }
  }

  // Ascension Day (Christi Himmelfahrt)
  if (isSameDay(date, ascension)) {
    return { key: 'himmelfahrt', background: BACKGROUNDS.spring }
  }

  // Whit Monday (Pfingstmontag)
  if (isSameDay(date, whitMonday)) {
    return { key: 'pfingsten', background: BACKGROUNDS.spring }
  }

  // German Unity Day: Oct 3
  if (month === 9 && day === 3) {
    return { key: 'einheit', background: BACKGROUNDS.autumn }
  }

  // No holiday - return default background
  return { key: null, background: BACKGROUNDS.default }
}

/**
 * Get the current year (for dynamic New Year greetings)
 */
export function getCurrentYear(): number {
  return new Date().getFullYear()
}
