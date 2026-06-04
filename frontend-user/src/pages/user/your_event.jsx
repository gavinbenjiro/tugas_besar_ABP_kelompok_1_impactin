import React, { useEffect, useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";

import api from "../../api/api";

import Header from "../../components/navbar.jsx";
import Footer from "../../components/footer.jsx";

const YourEventPage = () => {
  const location = useLocation();

  const navigate = useNavigate();

  const [menu, setMenu] = useState("joined"); // joined | created
  const [filter, setFilter] = useState("approved");
  const [joinedEvents, setJoinedEvents] = useState([]);

  const [createdEvents, setCreatedEvents] = useState([]);
  const [loading, setLoading] = useState(false);
  const formatDate = (date) =>
    new Date(date).toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

  /* ================= DUMMY JOINED EVENTS ================= */
  const fetchJoinedEvents = async (filterValue) => {
    try {
      setLoading(true);

      const res = await api.get("/user/events/joined", {
        params: { status: "all" }, // keyword backend
      });

      let mapped =
        res.data?.data?.map((e) => ({
          id: e.event_id,
          title: e.title,
          organizer: e.host_name,
          location: e.location,
          date: formatDate(e.start_date),

          startDate: new Date(e.start_date),
          status: e.status,
          subStatus: e.sub_status,
        })) || [];

      const now = new Date();

      //  FILTER LOGIC JOINED (FRONTEND)
      if (filterValue === "upcoming") {
        mapped = mapped.filter((e) => e.startDate > now);
      }

      if (filterValue === "ongoing") {
        mapped = mapped.filter(
          (e) => e.startDate.toDateString() === now.toDateString(),
        );
      }

      if (filterValue === "completed") {
        mapped = mapped.filter((e) => e.subStatus === "completed");
      }

      if (filterValue === "cancelled") {
        mapped = mapped.filter((e) => e.subStatus === "cancelled");
      }

      // all → no filter
      setJoinedEvents(mapped);
    } catch (err) {
      console.error("Failed to fetch joined events:", err);
      setJoinedEvents([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (menu === "joined") {
      fetchJoinedEvents(filter);
    }
  }, [menu, filter]);

  /* ================= FETCH CREATED EVENTS ================= */
  const fetchCreatedEvents = async (filterValue) => {
    try {
      setLoading(true);

      // 🔑 status = keyword backend (MODE)
      const res = await api.get("/user/events/your", {
        params: { status: filterValue },
      });

      let mapped =
        res.data?.data?.map((e) => ({
          id: e.event_id,
          title: e.title,
          organizer: e.host_name,
          location: e.location,
          date: formatDate(e.start_date),

          status: e.status,
          subStatus: e.sub_status,
        })) || [];

      // ✅ FRONTEND FILTER MINIMAL (ANTI ERROR DATA)
      if (filterValue === "approved") {
        mapped = mapped.filter(
          (e) => e.subStatus === "opened" || e.subStatus === "closed",
        );
      }

      if (filterValue === "pending") {
        mapped = mapped.filter((e) => e.status === "pending");
      }

      if (filterValue === "declined") {
        mapped = mapped.filter((e) => e.status === "declined");
      }

      // ❗ cancelled & completed
      // backend SUDAH kirim data BENAR
      // TIDAK perlu difilter ulang

      setCreatedEvents(mapped);
    } catch (err) {
      console.error("Failed to fetch created events:", err);
      setCreatedEvents([]);
    } finally {
      setLoading(false);
    }
  };

  /* ================= EFFECT ================= */
  useEffect(() => {
    if (menu === "created") {
      fetchCreatedEvents(filter);
    }
  }, [menu, filter, location.pathname]);

  /* ================= DISPLAYED EVENTS ================= */
  const displayedEvents = menu === "joined" ? joinedEvents : createdEvents;

  /* ================= HANDLER ================= */
  const handleView = (id, isHost) => {
    navigate(isHost ? `/manage-event/${id}` : `/event/${id}`);
  };

  const getBadgeLabel = (event) => {
    if (filter === "approved") {
      return event.subStatus; // opened / completed
    }
    return filter;
  };

  const getBadgeClass = (event) => {
    if (filter === "approved") {
      if (event.subStatus === "completed") return "bg-gray-200 text-gray-700";
      if (event.subStatus === "cancelled") return "bg-red-100 text-red-700";
      if (event.subStatus === "closed") return "bg-blue-100 text-blue-700";
      return "bg-green-100 text-green-700"; // opened
    }

    // selain approved → ikut filter
    if (filter === "pending") return "bg-yellow-100 text-yellow-700";
    if (filter === "declined") return "bg-red-200 text-red-800";
    if (filter === "cancelled") return "bg-red-100 text-red-700";
    if (filter === "completed") return "bg-gray-200 text-gray-700";

    return "bg-gray-100 text-gray-600";
  };

  return (
    <>
      <Header />

      <div className="min-h-screen bg-gradient-to-b from-green-50 to-green-200 px-6 py-10">
        <div className="max-w-6xl mx-auto grid grid-cols-12 gap-6">
          {/* ================= SIDEBAR ================= */}
          <div className="col-span-12 md:col-span-3 bg-white p-6 rounded-xl shadow-md">
            <h2 className="font-bold text-lg mb-4">Joined Event</h2>

            <ul className="space-y-2 mb-6">
              {["all", "ongoing", "upcoming", "completed", "cancelled"].map(
                (i) => (
                  <li
                    key={i}
                    onClick={() => {
                      setMenu("joined");
                      setFilter(i);
                    }}
                    className={`cursor-pointer transition
        ${
          menu === "joined" && filter === i
            ? "font-bold text-green-600"
            : "text-gray-600 hover:text-green-600"
        }`}
                  >
                    {i.charAt(0).toUpperCase() + i.slice(1)}
                  </li>
                ),
              )}
            </ul>

            <h2 className="font-bold text-lg mb-4">Created Event</h2>

            <ul className="space-y-2">
              {[
                "approved",
                "pending",
                "cancelled",
                "declined",
                "completed",
              ].map((i) => (
                <li
                  key={i}
                  className={`cursor-pointer transition ${
                    menu === "created" && filter === i
                      ? "font-bold text-green-600"
                      : "text-gray-600 hover:text-green-600"
                  }`}
                  onClick={() => {
                    setMenu("created");
                    setFilter(i);
                  }}
                >
                  {i.charAt(0).toUpperCase() + i.slice(1)}
                </li>
              ))}
            </ul>
          </div>

          {/* ================= CONTENT ================= */}
          <div className="col-span-12 md:col-span-9 space-y-6">
            {loading && (
              <div className="bg-white p-10 rounded-xl shadow text-center">
                Loading event...
              </div>
            )}

            {!loading && displayedEvents.length === 0 && (
              <div className="bg-white p-10 rounded-xl shadow text-center text-gray-500">
                Tidak ada event untuk kategori ini
              </div>
            )}

            {!loading &&
              displayedEvents.map((event) => (
                <div
                  key={event.id}
                  className="bg-white p-6 rounded-xl shadow flex justify-between items-center"
                >
                  {/* INFO */}
                  <div>
                    <h3
                      className="font-bold text-lg capitalize cursor-pointer hover:text-green-600 transition"
                      onClick={() => navigate(`/event/${event.id}`)}
                    >
                      {event.title}
                    </h3>
                    <p className="text-gray-600">{event.location}</p>
                    <p className="text-gray-700">{event.organizer}</p>

                    {menu === "created" && (
                      <span
                        className={`inline-block mt-2 px-3 py-1 text-xs rounded-full ${getBadgeClass(
                          event,
                        )}`}
                      >
                        {getBadgeLabel(event)}
                      </span>
                    )}
                  </div>

                  {/* ACTION */}
                  <div className="text-right">
                    <p className="text-sm text-gray-500">{event.date}</p>

                    {menu === "created" &&
                      event.status === "approved" &&
                      ["opened", "closed"].includes(event.subStatus) && (
                        <button
                          className="px-4 py-2 bg-green-700 text-white rounded-lg mt-3"
                          onClick={() => handleView(event.id, true)}
                        >
                          Manage Event
                        </button>
                      )}

                    {menu === "created" &&
                      ["cancelled", "completed"].includes(event.subStatus) && (
                        <p className="mt-3 text-sm text-gray-400 italic">
                          Event telah {event.subStatus}
                        </p>
                      )}
                  </div>
                </div>
              ))}
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
};

export default YourEventPage;
