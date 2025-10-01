#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
	echo "Usage: $0 <domain>"
	exit 1
fi

DOMAIN="$1"
FRONTEND_DIR="/var/www/$DOMAIN/frontend"

echo "==> Generating frontend boilerplate in $FRONTEND_DIR"

mkdir -p "$FRONTEND_DIR/pages/blog"
mkdir -p "$FRONTEND_DIR/components"
mkdir -p "$FRONTEND_DIR/styles"

##########################################
# Pages
##########################################

# _app.js
cat >"$FRONTEND_DIR/pages/_app.js" <<'EOF'
import '../styles/globals.css'
import Layout from '../components/Layout'

export default function App({ Component, pageProps }) {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  )
}
EOF

# _document.js
cat >"$FRONTEND_DIR/pages/_document.js" <<'EOF'
import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        <meta name="description" content="Next.js + Strapi Boilerplate" />
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
EOF

# index.js (Home)
cat >"$FRONTEND_DIR/pages/index.js" <<'EOF'
export default function Home() {
  return (
    <div style={{ padding: "3rem", textAlign: "center" }}>
      <h1>Next.js + Strapi Boilerplate</h1>
      <p>Your site is up and running 🎉</p>
    </div>
  )
}
EOF

# Blog index
cat >"$FRONTEND_DIR/pages/blog/index.js" <<'EOF'
import Link from 'next/link'

export default function BlogIndex() {
  const mockPosts = [
    { slug: 'hello-world', title: 'Hello World' },
    { slug: 'second-post', title: 'Second Post' }
  ]
  return (
    <main style={{ padding: "2rem" }}>
      <h1>Blog</h1>
      <ul>
        {mockPosts.map(post => (
          <li key={post.slug}>
            <Link href={`/blog/${post.slug}`}>{post.title}</Link>
          </li>
        ))}
      </ul>
    </main>
  )
}
EOF

# Blog single
cat >"$FRONTEND_DIR/pages/blog/[slug].js" <<'EOF'
import { useRouter } from 'next/router'

export default function BlogPost() {
  const { query } = useRouter()
  const { slug } = query
  return (
    <main style={{ padding: "2rem" }}>
      <h1>Blog Post: {slug}</h1>
      <p>This will display blog content pulled from Strapi.</p>
    </main>
  )
}
EOF

##########################################
# Components
##########################################

# Navbar
cat >"$FRONTEND_DIR/components/Navbar.js" <<'EOF'
import Link from 'next/link'

export default function Navbar() {
  return (
    <nav style={{ padding: "1rem", background: "#222", color: "#fff" }}>
      <ul style={{ display: "flex", gap: "2rem", listStyle: "none" }}>
        <li><Link href="/">Home</Link></li>
        <li><Link href="/blog">Blog</Link></li>
        <li><Link href="/about">About</Link></li>
        <li><Link href="/contact">Contact</Link></li>
      </ul>
    </nav>
  )
}
EOF

# Footer
cat >"$FRONTEND_DIR/components/Footer.js" <<'EOF'
export default function Footer() {
  return (
    <footer style={{
      marginTop: "3rem",
      padding: "1rem",
      textAlign: "center",
      background: "#f2f2f2"
    }}>
      <p>© {new Date().getFullYear()} MyClientSite. All rights reserved.</p>
    </footer>
  )
}
EOF

# Layout
cat >"$FRONTEND_DIR/components/Layout.js" <<'EOF'
import Navbar from './Navbar'
import Footer from './Footer'

export default function Layout({ children }) {
  return (
    <>
      <Navbar />
      <main style={{ minHeight: "80vh" }}>{children}</main>
      <Footer />
    </>
  )
}
EOF

##########################################
# Styles
##########################################

cat >"$FRONTEND_DIR/styles/globals.css" <<'EOF'
body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI',
    Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  background-color: #fff;
  color: #222;
}

a {
  color: blue;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

main {
  padding: 2rem;
}
EOF
echo "✅ Frontend boilerplate created for $DOMAIN"
echo "Next step:"
echo "   Run: bash deploy/05-start-stack.sh $DOMAIN"
