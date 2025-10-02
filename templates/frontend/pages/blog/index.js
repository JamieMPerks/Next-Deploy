import Layout from "../../components/Layout";
import Link from "next/link";
import { getNavLinks } from "../../lib/api";

export default function BlogIndex({ posts, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <h1>Blog</h1>
      {posts.length === 0 && <p>No posts yet.</p>}
      <ul>
        {posts.map((post) => (
          <li key={post.slug}>
            <Link href={`/blog/${post.slug}`}>{post.title}</Link>
          </li>
        ))}
      </ul>
    </Layout>
  );
}

export async function getStaticProps() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
  let posts = [];

  try {
    const res = await fetch(`${base}/api/posts`);
    if (res.ok) {
      const { data } = await res.json();
      posts = data.map((p) => ({
        title: p.attributes.title,
        slug: p.attributes.slug,
      }));
    }
  } catch (err) {
    console.warn("⚠️ Strapi not available at build time, skipping blog fetch");
  }

  const navLinks = await getNavLinks().catch(() => []);

  return { props: { posts, navLinks } };
}
