import Layout from "../components/Layout";
import { getNavLinks } from "../lib/api";

export default function NotFound({ navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <div style={{ textAlign: "center", marginTop: "5rem" }}>
        <h1>404 - Page Not Found</h1>
        <p>Sorry, this page does not exist.</p>
      </div>
    </Layout>
  );
}

export async function getStaticProps() {
  const navLinks = await getNavLinks();
  return { props: { navLinks } };
}
