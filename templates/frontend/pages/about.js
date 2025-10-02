import Layout from "../components/Layout";
import { fetchPage, getNavLinks } from "../lib/api";

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

// Uses generic fetchPage from api.js
export async function getStaticProps() {
  const page = await fetchPage("about");
  const navLinks = await getNavLinks();
  return { props: { page, navLinks } };
}
