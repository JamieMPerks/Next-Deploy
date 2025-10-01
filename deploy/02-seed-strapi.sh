#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
	echo "Usage: $0 <domain>"
	exit 1
fi

DOMAIN="$1"
PROJECT_DIR="/var/www/$DOMAIN"
CMS_DIR="$PROJECT_DIR/cms"
BOOTSTRAP_PATH="$CMS_DIR/config/functions/bootstrap.js"

mkdir -p "$(dirname "$BOOTSTRAP_PATH")"

echo "==> Writing bootstrap seeder to $BOOTSTRAP_PATH"

cat >"$BOOTSTRAP_PATH" <<'JS'
'use strict';

module.exports = async ({ strapi }) => {
  const pages = [
    { title: 'Home', slug: 'home', sections: [
      { __component: 'sections.hero', heading: 'Welcome to our site', subheading: 'We build great things' },
      { __component: 'sections.text-block', content: 'This is the home page. Replace this dummy content.' }
    ]},
    { title: 'About', slug: 'about', sections: [
      { __component: 'sections.text-block', content: 'About us page - short company blurb.' }
    ]},
    { title: 'Services', slug: 'services', sections: [
      { __component: 'sections.services', items: [
        { title: 'Service One', description: 'Description of service one.' },
        { title: 'Service Two', description: 'Description of service two.' }
      ]}
    ]},
    { title: 'Contact', slug: 'contact', sections: [
      { __component: 'sections.text-block', content: 'Contact Us: email@example.com' }
    ]},
    { title: 'Blog', slug: 'blog', sections: [] }
  ];

  for (const p of pages) {
    const existing = await strapi.db.query('api::page.page').findOne({ where: { slug: p.slug } });
    if (!existing) {
      await strapi.entityService.create('api::page.page', { data: p });
      strapi.log.info(`✅ Seeded page: ${p.slug}`);
    }
  }

  const postExists = await strapi.db.query('api::post.post').findOne({ where: { slug: 'hello-world' } });
  if (!postExists) {
    await strapi.entityService.create('api::post.post', {
      data: {
        title: 'Hello World',
        slug: 'hello-world',
        content: '<p>This is your first blog post.</p>',
        publishedAt: new Date()
      }
    });
    strapi.log.info('✅ Seeded example blog post');
  }
};
JS

echo "==> Bootstrap written for project $PROJECT_DIR"
