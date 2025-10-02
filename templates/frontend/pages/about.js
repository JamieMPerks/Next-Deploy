import Layout from "../components/Layout";
import { getNavLinks } from "../lib/api";

export default function About({ page, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <h1>{page?.title || "About Us"}</h1>

      {page?.sections?.map((section, idx) => (
        <div key={idx} style={{ marginBottom: "1rem" }}>
          {section.__component === "sections.text-block" && (
            <p>{section.content}</p>
          )}
        </div>
      ))}
    </Layout>
  );
}

export async function getStaticProps() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";

  const res = await fetch(
    `${base}/api/pages?filters[slug][$eq]=about&populate=deep`,
  );
  const { data } = await res.json();
  const page = data[0]?.attributes || null;

  const navLinks = await getNavLinks();

  return { props: { page, navLinks } };
}
