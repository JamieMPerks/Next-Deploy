export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Method not allowed" });
  }

  const secret = process.env.REVALIDATE_SECRET;
  if (!secret || req.query.secret !== secret) {
    return res.status(401).json({ message: "Invalid or missing secret token" });
  }

  try {
    const body = req.body;

    if (body.model === "page" && body.entry?.slug) {
      const slug = body.entry.slug;
      const path = slug === "home" ? "/" : `/${slug}`;
      await res.revalidate(path);
      console.log(`✅ Revalidated Page: ${path}`);
      return res.json({ revalidated: true, path });
    }
    if (body.model === "post" && body.entry?.slug) {
      const slug = body.entry.slug;

      await res.revalidate("/blog");

      const path = `/blog/${slug}`;
      await res.revalidate(path);

      console.log(`✅ Revalidated Blog Index + Post: ${path}`);
      return res.json({ revalidated: true, path, blogIndex: true });
    }

    await res.revalidate("/");
    await res.revalidate("/blog");
    return res.json({ revalidated: true, fallback: true });
  } catch (err) {
    console.error("❌ Revalidation error:", err);
    return res
      .status(500)
      .json({ message: "Error revalidating", error: err.message });
  }
}
