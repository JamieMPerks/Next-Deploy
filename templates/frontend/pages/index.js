import Layout from "../components/Layout";
import { fetchHome, getNavLinks } from "../lib/api";

export default function Home({ home, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <div className="home">
        <h1>🚀 {home?.sections?.[0]?.heading || "Welcome"}</h1>
        <p>
          {home?.sections?.[0]?.subheading || "To our Next.js + Strapi site"}
        </p>

        <section>
          <h2>Features:</h2>
          <ul>
            <li>✅ Strapi CMS backend</li>
            <li>✅ Next.js frontend</li>
            <li>✅ Dockerized deployment</li>
            <li>✅ SSL-ready with Nginx + Certbot</li>
          </ul>
        </section>
      </div>
    </Layout>
  );
}

// Fetch Homepage + Nav Links from Strapi
export async function getStaticProps() {
  const home = await fetchHome();
  const navLinks = await getNavLinks();

  return {
    props: { home, navLinks },
  };
}
