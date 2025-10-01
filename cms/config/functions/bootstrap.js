'use strict';

module.exports = async () => {
  // This bootstrap uses the Strapi entityService/controller API.
  // It attempts idempotent creation of pages by slug.
  const pages = [
    {
      title: 'Home',
      slug: 'home',
      sections: [
        { __component: 'sections.hero', heading: 'Welcome to our site', subheading: 'We build great things' },
        { __component: 'sections.text-block', content: 'This is the home page. Replace this dummy content.' }
      ]
    },
    {
      title: 'About',
      slug: 'about',
      sections: [
        { __component: 'sections.text-block', content: 'About us page - short company blurb.' }
      ]
    },
    {
      title: 'Services',
      slug: 'services',
      sections: [
        {
          __component: 'sections.services',
          items: [
            { title: 'Service One', description: 'Description of service one.' },
            { title: 'Service Two', description: 'Description of service two.' }
          ]
        }
      ]
    },
    {
      title: 'Contact',
      slug: 'contact',
      sections: [
        { __component: 'sections.text-block', content: 'Contact Us: email@example.com' }
      ]
    },
    {
      title: 'Blog',
      slug: 'blog',
      sections: []
    }
  ];

  for (const p of pages) {
    try {
      const existing = await strapi.db.query('api::page.page').findOne({ where: { slug: p.slug } });
      if (!existing) {
        await strapi.entityService.create('api::page.page', { data: p });
        strapi.log.info(`Seeded page: ${p.slug}`);
      } else {
        strapi.log.info(`Page exists, skipping: ${p.slug}`);
      }
    } catch (err) {
      strapi.log.error('Seeder error', err);
    }
  }
};
