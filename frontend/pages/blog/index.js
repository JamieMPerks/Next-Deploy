import Link from "next/link";

export async function getStaticProps() {
  const res = await fetch(
    `${process.env.NEXT_PUBLIC_STRAPI_URL}/posts?populate=cover`,
  );
  const { data } = await res.json();

  return { props: { posts: data || [] }, revalidate: 60 };
}

export default function BlogIndex({ posts }) {
  return (
    <main className="max-w-5xl mx-auto px-6 py-12">
      <h1 className="text-4xl font-bold mb-8">Blog</h1>
      <div className="space-y-10">
        {posts.map((post) => (
          <article key={post.id} className="border-b pb-6">
            {post.attributes.cover?.data && (
              <img
                src={post.attributes.cover.data.attributes.url ?? ""}
                alt={post.attributes.title}
                className="w-full h-64 object-cover mb-4 rounded"
              />
            )}
            <h2 className="text-2xl font-semibold mb-2">
              <Link href={`/blog/${post.attributes.slug}`}>
                {post.attributes.title}
              </Link>
            </h2>
            <p className="text-gray-600 mb-3">
              {new Date(
                post.attributes.publishedAt || Date.now(),
              ).toLocaleDateString()}
            </p>
            <Link
              href={`/blog/${post.attributes.slug}`}
              className="text-blue-600 underline"
            >
              Read more →
            </Link>
          </article>
        ))}
      </div>
    </main>
  );
}
