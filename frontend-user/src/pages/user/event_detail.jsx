import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import Header from "../../components/navbar.jsx";
import Footer from "../../components/footer.jsx";
import MOCK_CARD_IMAGE from "../../assets/hero news.png";
import {
  getEventDetailAPI,
  reportEventAPI,
  joinEventAPI,
} from "../../api/event";

import { MapPin, Calendar, Clock, Users, TriangleAlert } from "lucide-react";

const EventDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const [event, setEvent] = useState(null);
  const [loading, setLoading] = useState(true);

  const [joined, setJoined] = useState(false);
  const [showTerms, setShowTerms] = useState(false);
  const isClosed =
  event?.status === "closed" ||
  event?.subStatus === "closed";

  // 🔴 REPORT STATE
  const [showReport, setShowReport] = useState(false);
  const [reportReason, setReportReason] = useState("");
  const [reportLoading, setReportLoading] = useState(false);

  /* ================= FORMAT AGE ================= */
  const formatAgeRange = (minAge, maxAge) => {
    if (minAge === 0 && maxAge === 0) return "All Age";
    if (minAge === 0 && maxAge > 0) return `Below ${maxAge + 1} years`;
    if (minAge > 0 && maxAge === 0) return `Above ${minAge - 1} years`;
    if (minAge === maxAge) return `${minAge} years`;
    return `${minAge} - ${maxAge} years`;
  };

  /* ================= FORMAT DATE ================= */
  const formatDate = (date) =>
    new Date(date).toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

  /* ================= FETCH EVENT ================= */
  useEffect(() => {
    const fetchEvent = async () => {
      try {
        const res = await getEventDetailAPI(id);

        const mappedEvent = {
          id: res.event_id,
          title: res.title,
          organizer: res.host_name,
          location: res.location,
          specificAddress: res.specific_address,
          addressLink: res.address_link,

          dateRange: `${formatDate(res.start_date)} - ${formatDate(
            res.end_date
          )}`,
          time: `${res.start_time} - ${res.end_time}`,
          ageGroup: formatAgeRange(res.min_age, res.max_age),

          imageUrl: res.cover_image || MOCK_CARD_IMAGE,
          description: res.description,
          termsAndConditions: res.terms,

          isHost: res.is_host,
          isApplicant: res.is_applicant,
          isParticipant: res.is_participant,

          groupLink: res.group_link,

          status: res.status,
          subStatus: res.sub_status,
        };

        setEvent(mappedEvent);

        setJoined(
          mappedEvent.isHost ||
            mappedEvent.isApplicant ||
            mappedEvent.isParticipant
        );
      } catch (err) {
        console.error("Fetch event detail failed:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchEvent();
  }, [id]);

  /* ================= JOIN EVENT (GET API) ================= */
  const handleJoinEvent = async () => {
    try {
      await joinEventAPI(id);

      setEvent((prev) => ({
        ...prev,
        isApplicant: true,
        status: "pending",
      }));

      setJoined(true);
    } catch (err) {
      const message = err.response?.data?.message || "";

      // 🚨 PROFILE BELUM LENGKAP
      if (
        err.response?.status === 400 &&
        message.toLowerCase().includes("profile")
      ) {
        alert("Please complete your profile before joining this event.");
        navigate("/profile");
        return;
      }

      alert(message || "Failed to join event");
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        Loading event...
      </div>
    );
  }

  if (!event) {
    return (
      <div className="min-h-screen flex items-center justify-center text-xl">
        Event not found
      </div>
    );
  }

  return (
    <>
      <Header />

      <main className="min-h-screen bg-slate-50">
        <div className="w-full px-6 py-10">
          <div className="bg-white rounded-xl overflow-hidden border relative">
            {/* 🔴 REPORT BUTTON */}
            {!event.isHost && (
              <button
                onClick={() => setShowReport(true)}
                className="absolute top-6 right-6 flex items-center gap-2
                           text-sm text-red-600 font-semibold bg-red-50
                           px-3 py-1 rounded-full hover:bg-red-100"
              >
                <TriangleAlert className="w-4 h-4" />
                Report Event
              </button>
            )}

            {/* TOP */}
            <div className="md:flex">
              <div className="md:w-1/2">
                <img
                  src={event.imageUrl}
                  alt={event.title}
                  className="w-full h-[420px] object-cover"
                />
              </div>

              <div className="p-8 flex-1">
                <h1 className="text-4xl font-extrabold">{event.title}</h1>
                <p className="text-lg text-gray-600 mt-2 mb-8">
                  {event.organizer}
                </p>

                {/* ===== EVENT META (GRID 2x2) ===== */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-10 gap-y-5 mt-6 text-base text-gray-800">
                  {/* Location */}
                  <div className="flex items-start gap-3">
                    <MapPin className="w-6 h-6 text-green-700 mt-0.5 shrink-0" />
                    <div className="flex flex-col leading-snug">
                      <span className="font-medium">{event.location}</span>

                      {(event.specificAddress || event.addressLink) && (
                        <span className="text-sm text-gray-600">
                          {event.specificAddress}
                          {event.addressLink && (
                            <>
                              {" • "}
                              <a
                                href={
                                  event.addressLink.startsWith("http")
                                    ? event.addressLink
                                    : `https://${event.addressLink}`
                                }
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-green-700 underline font-medium hover:text-green-900"
                              >
                                View on Maps
                              </a>
                            </>
                          )}
                        </span>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center gap-3 font-medium">
                    <Calendar className="w-6 h-6 text-green-700" />
                    <span>{event.dateRange}</span>
                  </div>

                  <div className="flex items-center gap-3 font-medium">
                    <Clock className="w-6 h-6 text-green-700" />
                    <span>{event.time}</span>
                  </div>

                  <div className="flex items-center gap-3 font-medium">
                    <Users className="w-6 h-6 text-green-700" />
                    <span>{event.ageGroup}</span>
                  </div>
                </div>

                {event.isParticipant && event.groupLink && (
                  <div className="mt-6">
                    <label className="text-xs font-semibold text-gray-600">
                      Group Link
                    </label>
                    <div className="border rounded-md px-3 py-2 bg-gray-100">
                      <a
                        href={event.groupLink}
                        target="_blank"
                        rel="noreferrer noopener"
                        className="underline break-all text-sm text-green-700 hover:text-green-900"
                      >
                        {event.groupLink}
                      </a>
                    </div>
                  </div>
                )}

                <button
                  onClick={() => setShowTerms(true)}
                  className="mt-8 px-4 py-2 border rounded-lg text-green-700"
                >
                  Terms & Conditions
                </button>
              </div>
            </div>

            {/* DESCRIPTION */}
            <div className="p-8 border-t">
              <h2 className="text-2xl font-bold mb-4">Description</h2>
              <p>{event.description}</p>
            </div>
          </div>
        </div>

        {/* JOIN */}
        <div className="p-8 flex flex-col items-end gap-3">
          {isClosed && (
            <div className="text-sm text-red-600 font-medium">
              This event is currently unavailable.
            </div>
          )}
          <button
            onClick={!joined ? handleJoinEvent : undefined}
            disabled={joined || isClosed}
            className={`px-10 py-3 rounded-lg font-bold transition
              ${
                joined || isClosed
                  ? "bg-gray-400 cursor-not-allowed"
                  : "bg-green-700 text-white hover:bg-green-800"
              }`}
          >
            {event.isHost
              ? "YOU ARE THE HOST"
              : event.isParticipant
              ? "JOINED"
              : event.isApplicant
              ? "WAITING FOR APPROVAL"
              : isClosed
              ? "EVENT CLOSED"
              : "JOIN EVENT"}
          </button>
        </div>

        {/* REPORT MODAL */}
        {showReport && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-xl w-full max-w-md">
              <h2 className="text-xl font-bold text-red-600 mb-4">
                Report Event
              </h2>

              <textarea
                value={reportReason}
                onChange={(e) => setReportReason(e.target.value)}
                placeholder="Explain why you are reporting this event..."
                className="w-full border rounded-lg p-3 h-32 resize-none"
              />

              <div className="flex justify-end gap-3 mt-5">
                <button
                  onClick={() => setShowReport(false)}
                  className="px-4 py-2 border rounded-lg"
                >
                  Cancel
                </button>

                <button
                  disabled={reportLoading || !reportReason.trim()}
                  onClick={async () => {
                    try {
                      setReportLoading(true);
                      await reportEventAPI(event.id, reportReason);
                      alert("Event reported successfully ✅");
                      setShowReport(false);
                      setReportReason("");
                    } catch (err) {
                      alert(
                        err.response?.data?.message || "Failed to report event"
                      );
                    } finally {
                      setReportLoading(false);
                    }
                  }}
                  className={`px-4 py-2 rounded-lg text-white
                    ${
                      reportLoading || !reportReason.trim()
                        ? "bg-gray-400 cursor-not-allowed"
                        : "bg-red-600 hover:bg-red-700"
                    }`}
                >
                  {reportLoading ? "Reporting..." : "Report"}
                </button>
              </div>
            </div>
          </div>
        )}
        {/* TERMS & CONDITIONS MODAL */}
        {showTerms && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-xl w-full max-w-lg max-h-[80vh] overflow-y-auto">
              <h2 className="text-xl font-bold mb-4">Terms & Conditions</h2>

              <p className="text-sm text-gray-700 whitespace-pre-line">
                {event.termsAndConditions || "No terms provided."}
              </p>

              <div className="flex justify-end mt-6">
                <button
                  onClick={() => setShowTerms(false)}
                  className="px-4 py-2 border rounded-lg"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}
      </main>

      <Footer />
    </>
  );
};

export default EventDetailPage;
