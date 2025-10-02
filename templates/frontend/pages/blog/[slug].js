import { useRouter } from "next/router";

export default function BlogPost() {
  const { slug } = useRouter().query;

  return (
    <main style={{ maxWidth: "700px", margin: "2rem auto", padding: "1rem" }}>
      <h1>Blog Post: {slug}</h1>
      <p>
        This is a dynamic blog route. In production it will fetch actual content
        from Strapi CMS.
      </p>
    </main>
  );
}
