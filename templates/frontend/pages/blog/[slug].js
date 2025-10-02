import Layout from "../../components/Layout";
import { getNavLinks } from "../../lib/api";

export default function BlogPost({ post, navLinks }) {
  if (!post) {
    return (
      <Layout navLinks={navLinks}>
        <h1>Post Not Found</h1>
      </Layout>
    );
  }
  return (
    <Layout navLinks={navLinks}>
      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </Layout>
  );
}

export async function getStaticPaths() {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
  let paths = [];

  try {
    const res = await fetch(`${base}/api/posts`);
    if (res.ok) {
      const { data } = await res.json();
      paths = data.map((p) => ({ params: { slug: p.attributes.slug } }));
    }
  } catch (err) {
    console.warn(
      "⚠️ Strapi not available at build time, no blog paths generated",
    );
  }

  return { paths, fallback: "blocking" };
}

export async function getStaticProps({ params }) {
  const base = process.env.NEXT_PUBLIC_STRAPI_URL || "http://localhost:1337";
  let post = null;

  try {
    const res = await fetch(
      `${base}/api/posts?filters[slug][$eq]=${params.slug}&populate=deep`,
    );
    if (res.ok) {
      const { data } = await res.json();
      if (data[0]) {
        post = {
          title: data[0].attributes.title,
          slug: data[0].attributes.slug,
          content: data[0].attributes.content,
        };
      }
    }
  } catch (err) {
    console.warn(`⚠️ Could not fetch post ${params.slug} at build time`);
  }

  const navLinks = await getNavLinks().catch(() => []);

  return { props: { post, navLinks } };
}
