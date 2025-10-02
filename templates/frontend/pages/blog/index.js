import Layout from "../../components/Layout";
import { getNavLinks, fetchPosts } from "../../lib/api";

export default function BlogIndex({ posts, navLinks }) {
  return (
    <Layout navLinks={navLinks}>
      <h1>Blog</h1>
      {posts.length === 0 && <p>No posts yet.</p>}
      <ul>
        {posts.map((post) => (
          <li key={post.slug}>
            <a href={`/blog/${post.slug}`}>{post.title}</a>
          </li>
        ))}
      </ul>
    </Layout>
  );
}

export async function getStaticProps() {
  const posts = await fetchPosts();
  const navLinks = await getNavLinks();
  return { props: { posts, navLinks } };
}
