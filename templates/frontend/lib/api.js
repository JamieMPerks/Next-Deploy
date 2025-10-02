// Fetch single home page (existing)
export async function fetchHome() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
  try {
    const res = await fetch(
      `${base}/api/pages?filters[slug][$eq]=home&populate=deep`,
    );
    const data = await res.json();
    return data?.data?.[0]?.attributes || null;
  } catch (e) {
    console.error("fetchHome error", e);
    return null;
  }
}

// Fetch pages marked "showInNav: true" for Navbar
export async function getNavLinks() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
  try {
    const res = await fetch(`${base}/api/pages?filters[showInNav][$eq]=true`);
    const { data } = await res.json();

    return data.map((page) => {
      const { title, slug } = page.attributes;
      return {
        // Use "/" for home, otherwise "/slug"
        href: slug === "home" ? "/" : `/${slug}`,
        label: title,
      };
    });
  } catch (e) {
    console.error("getNavLinks error", e);
    return [];
  }
}
