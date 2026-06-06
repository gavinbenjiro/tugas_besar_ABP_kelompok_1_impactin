import React, { useState, useEffect } from "react";
import { NavLink, Link, useNavigate, useLocation } from "react-router-dom";
import { Search } from "lucide-react";
import LOGO from "../assets/impactin_logo.png";
import { useAuth } from "../context/AuthContext";

const Header = () => {
  const { user } = useAuth();

  const navigate = useNavigate();
  const location = useLocation();

  const [query, setQuery] = useState("");

  // ================= SYNC QUERY DARI URL =================
  useEffect(() => {
    const params = new URLSearchParams(location.search);

    const q = params.get("q") || "";

    setQuery(q);
  }, [location.search]);

  // ================= HANDLE SEARCH =================
  const handleSearch = (e) => {
  e.preventDefault();

  // kalau kosong → tetap masuk search page
  if (!query.trim()) {
    navigate("/search");
    return;
  }

  navigate(`/search?q=${encodeURIComponent(query)}`);
};

  return (
    <header className="w-full bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between gap-6">
        {/* ================= LOGO ================= */}
        <Link to="/" className="shrink-0">
          <img src={LOGO} alt="Logo" className="h-10" />
        </Link>

        {/* ================= SEARCH ================= */}
        <form
          onSubmit={handleSearch}
          className={`
            relative flex items-center rounded-full px-4 py-2 w-full max-w-md 
            transition
            ${
              query
                ? "bg-emerald-200 ring-2 ring-emerald-500"
                : "bg-emerald-100/70 focus-within:ring-2 focus-within:ring-emerald-400"
            }
          `}
        >
          <Search size={18} className="text-gray-600" />

          <input
            type="text"
            placeholder="Search event..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="
              ml-2 bg-transparent w-full text-sm text-gray-800
              placeholder-gray-600 focus:outline-none
            "
          />
        </form>

        {/* ================= NAVIGATION ================= */}
        <nav className="flex items-center gap-8 text-sm font-semibold shrink-0">
          <NavLink
            to="/your-event"
            className={({ isActive }) =>
              `transition hover:text-emerald-600
              ${
                isActive
                  ? "text-emerald-700 underline underline-offset-4"
                  : "text-gray-800"
              }`
            }
          >
            Your Event
          </NavLink>

          <NavLink
            to="/create-event"
            className={({ isActive }) =>
              `transition hover:text-emerald-600
              ${
                isActive
                  ? "text-emerald-700 underline underline-offset-4"
                  : "text-gray-800"
              }`
            }
          >
            Create Event
          </NavLink>

          {/* ================= LOGIN / PROFILE ================= */}
          <NavLink
            to={user ? "/profile" : "/login"}
            className={({ isActive }) =>
              `transition hover:text-emerald-600
              ${
                isActive
                  ? "text-emerald-700 underline underline-offset-4"
                  : "text-gray-800"
              }`
            }
          >
            {user ? user.username : "Login"}
          </NavLink>
        </nav>
      </div>
    </header>
  );
};

export default Header;