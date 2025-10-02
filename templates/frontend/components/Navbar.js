// components/Navbar.js
import Link from "next/link";

export default function Navbar({ links }) {
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
