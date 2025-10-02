import Layout from "../../components/Layout";
import { getNavLinks } from "../../lib/api";

export default function BlogPost({ post, navLinks }) {
  if (!post) {
    return (
      <Layout navLinks={navLinks}>
        <h1>Post not found</h1>
      </Layout>
    );
  }

  return (
    <Layout navLinks={navLinks}>
      <article>
        <h1>{post.title}</h1>
        {post.publishedAt && (
          <small style={{ color: "#555" }}>
            {new Date(post.publishedAt).toLocaleDateString()}
          </small>
        )}
        <div
          style={{ marginTop: "2rem" }}
          dangerouslySetInnerHTML={{ __html: post.content }}
        />
      </article>
    </Layout>
  );
}

export async function getStaticPaths() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";

  const res = await fetch(`${base}/api/posts`);
  const { data } = await res.json();

  const paths = data.map((post) => ({
    params: { slug: post.attributes.slug },
  }));

  return { paths, fallback: "blocking" };
}

export async function getStaticProps({ params }) {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";

  const res = await fetch(
    `${base}/api/posts?filters[slug][$eq]=${params.slug}&populate=deep`,
  );
  const { data } = await res.json();

  const post = data[0]
    ? {
        title: data[0].attributes.title,
        slug: data[0].attributes.slug,
        content: data[0].attributes.content,
        publishedAt: data[0].attributes.publishedAt,
      }
    : null;

  const navLinks = await getNavLinks();

  return { props: { post, navLinks } };
}
