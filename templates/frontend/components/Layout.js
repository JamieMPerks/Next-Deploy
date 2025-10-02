// components/Layout.js
import Navbar from "./Navbar";
import Footer from "./Footer";
import navLinks from "../nav.config";

export default function Layout({ children }) {
  const visibleLinks = navLinks.filter((link) => link.include);

  return (
    <>
      <Navbar links={visibleLinks} />
      <main style={{ minHeight: "75vh", padding: "2rem" }}>{children}</main>
      <Footer />
    </>
  );
}
