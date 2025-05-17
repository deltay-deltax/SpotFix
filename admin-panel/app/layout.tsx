import "./globals.css";
import { ReactNode } from "react";

export const metadata = {
  title: "SpotFix Government Dashboard",
  description: "Admin panel for managing community reports",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gray-100">
        <header className="bg-pink-600 text-white p-4 shadow-md">
          <div className="container mx-auto flex justify-between items-center">
            <h1 className="text-xl font-bold">SpotFix Government Portal</h1>
            <nav>
              <ul className="flex space-x-4">
                <li>
                  <a href="/" className="hover:underline">
                    Dashboard
                  </a>
                </li>
                <li>
                  <a href="/reports" className="hover:underline">
                    Reports
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </header>
        <main className="container mx-auto py-8 px-4">{children}</main>
        <footer className="bg-gray-800 p-4 text-center text-gray-400">
          <p>© 2025 SpotFix Government Portal</p>
        </footer>
      </body>
    </html>
  );
}
