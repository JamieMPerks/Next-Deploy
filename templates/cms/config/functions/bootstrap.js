"use strict";

module.exports = async ({ strapi }) => {
  const pages = [
    {
      title: "Home",
      slug: "home",
      showInNav: true,
      sections: [
        {
          __component: "sections.hero",
          heading: "Welcome",
          subheading: "To our site",
        },
        {
          __component: "sections.text-block",
          content: "This is the home page...",
        },
      ],
    },
    {
      title: "About",
      slug: "about",
      showInNav: true,
      sections: [
        { __component: "sections.text-block", content: "About us info..." },
      ],
    },
    {
      title: "Services",
      slug: "services",
      showInNav: true,
      sections: [
        {
          __component: "sections.services",
          items: [
            { title: "Service One", description: "Description one" },
            { title: "Service Two", description: "Description two" },
          ],
        },
      ],
    },
    {
      title: "Contact",
      slug: "contact",
      showInNav: false, // not visible in nav by default
      sections: [
        {
          __component: "sections.text-block",
          content: "Contact us at: info@example.com",
        },
      ],
    },
    { title: "Blog", slug: "blog", showInNav: true, sections: [] },
  ];

  for (const p of pages) {
    const exists = await strapi.db
      .query("api::page.page")
      .findOne({ where: { slug: p.slug } });
    if (!exists) {
      await strapi.entityService.create("api::page.page", { data: p });
      strapi.log.info(`✅ Seeded page: ${p.slug}`);
    }
  }

  // Add example blog post
  const postExists = await strapi.db
    .query("api::post.post")
    .findOne({ where: { slug: "hello-world" } });
  if (!postExists) {
    await strapi.entityService.create("api::post.post", {
      data: {
        title: "Hello World",
        slug: "hello-world",
        content: "<p>This is your first blog post.</p>",
        publishedAt: new Date(),
      },
    });
    strapi.log.info("✅ Seeded example blog post");
  }
};
