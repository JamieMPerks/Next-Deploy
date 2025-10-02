export default function Home() {
  return (
    <main style={{ textAlign: "center", padding: "3rem" }}>
      <h1>🚀 Welcome to My Next.js + Strapi Site</h1>
      <p>This is your boilerplate homepage.</p>
      <section style={{ marginTop: "2rem" }}>
        <h2>Features:</h2>
        <ul style={{ listStyle: "none", padding: 0 }}>
          <li>✅ Strapi CMS backend</li>
          <li>✅ Next.js frontend</li>
          <li>✅ Dockerized deployment</li>
          <li>✅ SSL-ready with Nginx + Certbot</li>
        </ul>
      </section>
    </main>
  );
}
