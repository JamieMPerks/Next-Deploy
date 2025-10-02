import Layout from "../../components/Layout";
import Link from "next/link";
import { getNavLinks } from "../../lib/api";

export default function BlogIndex({ posts, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <h1>Blog</h1>
      <ul>
        {posts.length === 0 && <li>No blog posts found.</li>}
        {posts.map((post) => (
          <li key={post.slug} style={{ marginBottom: "1rem" }}>
            <Link href={`/blog/${post.slug}`}>
              <strong>{post.title}</strong>
            </Link>
            {post.publishedAt && (
              <small style={{ marginLeft: "0.5rem", color: "#555" }}>
                {new Date(post.publishedAt).toLocaleDateString()}
              </small>
            )}
          </li>
        ))}
      </ul>
    </Layout>
  );
}

export async function getStaticProps() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";

  const res = await fetch(`${base}/api/posts?sort=publishedAt:desc`);
  const { data } = await res.json();

  const posts = data.map((post) => ({
    title: post.attributes.title,
    slug: post.attributes.slug,
    publishedAt: post.attributes.publishedAt,
  }));

  const navLinks = await getNavLinks();

  return { props: { posts, navLinks } };
}
