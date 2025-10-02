import Navbar from "./Navbar";
import Footer from "./Footer";

export default function Layout({ children, navLinks = [] }) {
  return (
    <>
      <Navbar links={navLinks} />
      <main style={{ minHeight: "75vh", padding: "2rem" }}>{children}</main>
      <Footer />
    </>
  );
}
