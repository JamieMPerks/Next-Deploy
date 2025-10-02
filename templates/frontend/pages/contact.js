import Layout from "../components/Layout";
import { getNavLinks, fetchPage } from "../lib/api";

export default function Contact({ page, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <main style={{ maxWidth: "700px", margin: "2rem auto", padding: "1rem" }}>
        <h1>{page?.title || "Contact"}</h1>
        <p>{page?.description || "Get in touch with us:"}</p>
        <ul>
          <li>
            Email: <a href="mailto:info@example.com">info@example.com</a>
          </li>
          <li>Phone: +1 555 123 4567</li>
        </ul>
      </main>
    </Layout>
  );
}

// Could also fetch from Strapi pages if you create a "contact" page entry
export async function getStaticProps() {
  const navLinks = await getNavLinks();
  const page = await fetchPage("contact"); // fallback if not in Strapi
  return { props: { page, navLinks } };
}
