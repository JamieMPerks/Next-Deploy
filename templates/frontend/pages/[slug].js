import Layout from "../components/Layout";
import { getNavLinks, fetchPage } from "../lib/api";

export default function Page({ page, navLinks }) {
  if (!page) {
    return (
      <Layout navLinks={navLinks}>
        <h1>404 - Page Not Found</h1>
      </Layout>
    );
  }

  return (
    <Layout navLinks={navLinks}>
      <h1>{page.title}</h1>
      {page.sections?.map((section, idx) => (
        <div key={idx}>
          {section.__component === "sections.text-block" && (
            <p>{section.content}</p>
          )}
        </div>
      ))}
    </Layout>
  );
}

// Generate static paths for all Strapi "pages"
export async function getStaticPaths() {
  let paths = [];
  try {
    const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
    const res = await fetch(`${base}/api/pages`);
    if (res.ok) {
      const { data } = await res.json();
      paths = data.map((p) => ({
        params: { slug: p.attributes.slug },
      }));
    }
  } catch (err) {
    console.warn("⚠️ Strapi not reachable at build time for pages");
  }

  return { paths, fallback: "blocking" };
}

export async function getStaticProps({ params }) {
  const page = await fetchPage(params.slug);
  const navLinks = await getNavLinks();
  return { props: { page, navLinks } };
}
