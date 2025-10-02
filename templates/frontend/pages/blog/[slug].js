import Layout from "../../components/Layout";
import { getNavLinks, fetchPosts, fetchPost } from "../../lib/api";

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
  const posts = await fetchPosts();
  const paths = posts.map((p) => ({
    params: { slug: p.slug },
  }));
  return { paths, fallback: "blocking" };
}

export async function getStaticProps({ params }) {
  const post = await fetchPost(params.slug);
  const navLinks = await getNavLinks();
  return { props: { post, navLinks } };
}
