// components/Navbar.js
import Link from "next/link";
import "../styles/globals.css"; // ensure CSS is loaded

export default function Navbar({ links = [] }) {
  return (
    <nav className="navbar">
      <ul>
        {links.map((link) => (
          <li key={link.href}>
            <Link href={link.href}>{link.label}</Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
