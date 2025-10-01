import React from 'react'
import { fetchHome } from '../lib/api'
import Hero from '../components/sections/hero'

export default function Home({ page }) {
  if (!page) return <div>Loading...</div>
  return (
    <div>
      {page.sections.map((s, i) => {
        if (s.__component === 'sections.hero') return <Hero key={i} {...s} />
        if (s.__component === 'sections.text-block') return <div key={i} dangerouslySetInnerHTML={{__html: s.content}} />
        if (s.__component === 'sections.services') return (
          <section key={i}>
            {s.items && s.items.map((it, j) => <div key={j}><h3>{it.title}</h3><p>{it.description}</p></div>)}
          </section>
        )
        return null
      })}
    </div>
  )
}

export async function getStaticProps() {
  const home = await fetchHome()
  return { props: { page: home || null }, revalidate: 60 }
}
