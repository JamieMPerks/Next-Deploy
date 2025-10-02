// lib/api.js

async function safeFetch(path, fallback = null) {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";

  try {
    const res = await fetch(`${base}${path}`);
    if (!res.ok) {
      console.warn(`⚠️ Strapi responded with ${res.status} for ${path}`);
      return fallback;
    }
    return await res.json();
  } catch (err) {
    console.error(`❌ Failed to fetch ${path}:`, err.message);
    return fallback;
  }
}

/**
 * Fetch single "Home" page
 */
export async function fetchHome() {
  const data = await safeFetch(
    "/api/pages?filters[slug][$eq]=home&populate=deep",
    { data: [] }, // fallback
  );

  return (
    data?.data?.[0]?.attributes || {
      sections: [
        {
          heading: "Welcome",
          subheading: "Strapi is offline — showing placeholder content.",
        },
      ],
    }
  );
}

/**
 * Fetch pages marked "showInNav: true" for Navbar links
 */
export async function getNavLinks() {
  const data = await safeFetch("/api/pages?filters[showInNav][$eq]=true", {
    data: [],
  });

  return (
    data?.data?.map((page) => {
      const { title, slug } = page.attributes;
      return {
        href: slug === "home" ? "/" : `/${slug}`,
        label: title,
      };
    }) || []
  );
}

/**
 * Fetch a single page by slug
 */
export async function fetchPage(slug) {
  const data = await safeFetch(
    `/api/pages?filters[slug][$eq]=${slug}&populate=deep`,
    { data: [] },
  );

  return (
    data?.data?.[0]?.attributes || {
      title: slug,
      sections: [
        {
          __component: "sections.text-block",
          content: "⚠️ Content unavailable (Strapi offline).",
        },
      ],
    }
  );
}

/**
 * Fetch blog posts (list)
 */
export async function fetchPosts() {
  const data = await safeFetch("/api/posts?populate=deep", { data: [] });

  return (
    data?.data?.map((post) => {
      const { title, slug, excerpt, publishedAt } = post.attributes;
      return { title, slug, excerpt, publishedAt };
    }) || []
  );
}

/**
 * Fetch single blog post by slug
 */
export async function fetchPost(slug) {
  const data = await safeFetch(
    `/api/posts?filters[slug][$eq]=${slug}&populate=deep`,
    { data: [] },
  );

  return (
    data?.data?.[0]?.attributes || {
      title: "Unavailable",
      content: "⚠️ Strapi is offline — blog post not available.",
    }
  );
}
