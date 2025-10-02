import Link from "next/link";

export default function BlogIndex() {
  const posts = [
    { slug: "hello-world", title: "Hello World from Strapi" },
    { slug: "second-post", title: "Second Boilerplate Post" },
  ];

  return (
    <main style={{ maxWidth: "700px", margin: "2rem auto", padding: "1rem" }}>
      <h1>Blog</h1>
      <ul>
        {posts.map((post) => (
          <li key={post.slug}>
            <Link href={`/blog/${post.slug}`}>{post.title}</Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
