export default function TextBlock({ data }) {
  return (
    <section className="py-12 px-6 max-w-4xl mx-auto">
      {data.heading && (
        <h2 className="text-2xl font-semibold mb-4">{data.heading}</h2>
      )}
      <div
        className="prose prose-lg text-gray-700"
        // Strapi richtext comes as HTML
        dangerouslySetInnerHTML={{ __html: data.content }}
      />
    </section>
  );
}
