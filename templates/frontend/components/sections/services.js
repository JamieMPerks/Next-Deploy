export default function Services({ data }) {
  return (
    <section className="py-16 bg-gray-50">
      <div className="max-w-6xl mx-auto px-6">
        {data.title && (
          <h2 className="text-3xl font-bold mb-8 text-center">{data.title}</h2>
        )}

        <div className="grid md:grid-cols-3 gap-8">
          {data.items?.map((item, idx) => (
            <div
              key={idx}
              className="p-6 bg-white rounded-lg shadow hover:shadow-lg transition"
            >
              {item.icon && (
                <div className="text-4xl mb-4 text-blue-600">{item.icon}</div>
              )}
              <h3 className="text-xl font-semibold mb-2">{item.title}</h3>
              <p className="text-gray-600">{item.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
