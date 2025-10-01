export async function getStaticPaths() {
  const res = await fetch(`${process.env.NEXT_PUBLIC_STRAPI_URL}/posts`);
  const { data } = await res.json();

  const paths = data.map((p) => ({
    params: { slug: p.attributes.slug },
  }));

  return { paths, fallback: "blocking" };
}

export async function getStaticProps({ params }) {
  const res = await fetch(
    `${process.env.NEXT_PUBLIC_STRAPI_URL}/posts?filters[slug][$eq]=${params.slug}&populate=cover`,
  );
  const { data } = await res.json();

  if (!data || !data.length) return { notFound: true };

  return { props: { post: data[0] }, revalidate: 60 };
}

export default function BlogPost({ post }) {
  const p = post.attributes;

  return (
    <article className="max-w-3xl mx-auto px-6 py-12">
      {p.cover?.data?.attributes?.url && (
        <img
          src={p.cover.data.attributes.url}
          alt={p.title}
          className="w-full h-80 object-cover mb-6 rounded"
        />
      )}
      <h1 className="text-4xl font-bold mb-2">{p.title}</h1>
      <p className="text-gray-500 mb-8">
        {new Date(p.publishedAt).toLocaleDateString()}
      </p>
      <div
        className="prose prose-lg"
        dangerouslySetInnerHTML={{ __html: p.content }}
      />
    </article>
  );
}
