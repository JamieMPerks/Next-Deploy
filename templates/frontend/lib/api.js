export async function fetchHome() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || 'http://localhost:1337'
  try {
    const res = await fetch(`${base}/api/pages?filters[slug][$eq]=home&populate=deep`)
    const data = await res.json()
    return data?.data?.[0]?.attributes || null
  } catch (e) {
    console.error('fetchHome error', e)
    return null
  }
}
