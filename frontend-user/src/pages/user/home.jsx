import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Header from "../../components/navbar.jsx";
import Footer from "../../components/footer.jsx";
import EventCard from "../../components/event_card.jsx";
import HERO_IMAGE from "../../assets/hero news.png";
import MOCK_CARD_IMAGE from "../../assets/hero news.png";
import { getAllEventsAPI, getEventsCarouselAPI, getEventsRecommendationAPI } from "../../api/event";

import { Leaf, BookOpen, Users, HeartPulse } from "lucide-react";

/* ================= MOCK EVENTS (EVENT LIST ONLY) ================= */
const mockEvents = [
  {
    id: 1,
    title: "DeepBlue Movement",
    date: "SEP 18",
    location: "Yogyakarta Indonesia",
    organizer: "Sea Care Indonesia",
    imageUrl: MOCK_CARD_IMAGE,
    category: "Environment",
  },
  {
    id: 2,
    title: "Ocean Cleanup",
    date: "OCT 05",
    location: "Bali Indonesia",
    organizer: "CleanSea Org",
    imageUrl: MOCK_CARD_IMAGE,
    category: "Environment",
  },
  {
    id: 3,
    title: "Mangrove Planting",
    date: "NOV 12",
    location: "Jakarta Indonesia",
    organizer: "GreenAction",
    imageUrl: MOCK_CARD_IMAGE,
    category: "Community",
  },
  {
    id: 4,
    title: "Beach Awareness",
    date: "DEC 01",
    location: "Lombok Indonesia",
    organizer: "EcoWave",
    imageUrl: MOCK_CARD_IMAGE,
    category: "Education",
  },
  {
    id: 5,
    title: "Public Health Campaign",
    date: "JAN 20",
    location: "Bandung Indonesia",
    organizer: "HealthFirst",
    imageUrl: MOCK_CARD_IMAGE,
    category: "Health",
  },
];

const HomePage = () => {
  const navigate = useNavigate();

  /* ================= EVENT LIST ================= */
  const [events, setEvents] = useState([]);

  /* ================= HERO CAROUSEL ================= */
  const [carouselEvents, setCarouselEvents] = useState([]);
  const [activeSlide, setActiveSlide] = useState(0);

  /* ================= FETCH EVENT LIST ================= */
  /* ================= FETCH EVENT LIST ================= */
useEffect(() => {
  const fetchEvents = async () => {
    try {
      const res = await getAllEventsAPI();

      const mapped = res.data.map((e) => ({
        id: e.event_id,
        title: e.title,
        date: new Date(e.start_date).toLocaleDateString("en-GB", {
          month: "short",
          day: "2-digit",
          year: "numeric",
        }),
        location: e.location,
        organizer: e.host_name,
        imageUrl: e.cover_image,
        category: e.category,
      }));

      setEvents(mapped);
    } catch (err) {
      console.error("Failed to fetch events:", err);
    }
  };

  fetchEvents();
}, []);
/* ================= FETCH HERO CAROUSEL ================= */
useEffect(() => {
  const fetchCarousel = async () => {
    try {
      const token = localStorage.getItem("token");

      let res;
      let mapped = [];

      if (token) {
        // USER LOGIN → recommendation
        res = await getEventsRecommendationAPI();

        const data = Array.isArray(res)
          ? res
          : Array.isArray(res?.data)
            ? res.data
            : [];

        mapped = data.map((e) => ({
          id: e.event_id,
          title: e.title,
          category: e.category,
          imageUrl: e.cover_image,
        }));
      } else {
        // GUEST → carousel
        res = await getEventsCarouselAPI();

        const raw = res?.data || {};

        const order = [
          "environment",
          "education",
          "community",
          "health",
        ];

        mapped = order
          .map((key) => raw[key])
          .filter(Boolean)
          .map((e) => ({
            id: e.event_id,
            title: e.title,
            category: e.category,
            imageUrl: e.cover_image,
          }));
      }

      console.log("CAROUSEL:", mapped);

      setCarouselEvents(mapped);
      setActiveSlide(0);
    } catch (err) {
      console.error("Failed to fetch carousel:", err);
    }
  };

  fetchCarousel();
}, []);

  /* ================= AUTO SLIDE ================= */
  useEffect(() => {
    if (carouselEvents.length <= 1) return;

    const interval = setInterval(() => {
      setActiveSlide((prev) =>
        prev === carouselEvents.length - 1 ? 0 : prev + 1,
      );
    }, 5000);

    return () => clearInterval(interval);
  }, [carouselEvents]);

  /* ================= MANUAL NAV ================= */
  const nextSlide = () => {
    if (!carouselEvents.length) return;
    setActiveSlide((prev) =>
      prev === carouselEvents.length - 1 ? 0 : prev + 1,
    );
  };

  const prevSlide = () => {
    if (!carouselEvents.length) return;
    setActiveSlide((prev) =>
      prev === 0 ? carouselEvents.length - 1 : prev - 1,
    );
  };

  /* ================= DATA SOURCE ================= */
  const eventSource = events.length ? events : mockEvents;
  const currentSlide = carouselEvents[activeSlide];

  return (
    <>
      <main className="bg-[#225740] text-white">
        <Header variant="hero" />

        {/* ================= HERO (ALWAYS RENDER) ================= */}
        <section
          className="relative min-h-screen bg-cover bg-center transition-all duration-700"
          style={{
            backgroundImage: `url(${currentSlide?.imageUrl || HERO_IMAGE})`,
          }}
        >
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />

          <div className="relative max-w-6xl mx-auto px-6 lg:px-16 flex items-center min-h-screen">
            <div className="max-w-xl">
              {currentSlide ? (
                <>
                  <span className="uppercase tracking-widest text-green-400 text-sm">
                    {currentSlide.category}
                  </span>

                  <h1 className="text-5xl md:text-6xl font-extrabold leading-tight mt-2">
                    {currentSlide.title}
                  </h1>

                  <button
                    onClick={() => navigate(`/event/${currentSlide.id}`)}
                    className="mt-8 bg-green-600 hover:bg-green-700
                               px-8 py-3 rounded-full font-semibold
                               shadow-xl transition hover:scale-[1.05]"
                  >
                    See Details
                  </button>
                </>
              ) : (
                <div className="h-32 w-96 rounded-xl bg-white/10 animate-pulse" />
              )}
            </div>
          </div>

          {/* ARROWS */}
          {carouselEvents.length > 1 && (
            <>
              <button
                onClick={prevSlide}
                className="absolute left-6 top-1/2 -translate-y-1/2
                           bg-black/40 hover:bg-black/60
                           p-3 rounded-full text-xl"
              >
                ◀
              </button>

              <button
                onClick={nextSlide}
                className="absolute right-6 top-1/2 -translate-y-1/2
                           bg-black/40 hover:bg-black/60
                           p-3 rounded-full text-xl"
              >
                ▶
              </button>

              {/* DOTS */}
              <div className="absolute bottom-10 left-1/2 -translate-x-1/2 flex gap-3">
                {carouselEvents.map((_, i) => (
                  <button
                    key={i}
                    onClick={() => setActiveSlide(i)}
                    className={`h-3 w-3 rounded-full ${
                      i === activeSlide ? "bg-white" : "bg-white/40"
                    }`}
                  />
                ))}
              </div>
            </>
          )}
        </section>

        {/* ================= CATEGORY HIGHLIGHT ================= */}
        <section className="py-20">
          <div className="text-center max-w-7xl mx-auto px-6 lg:px-20">
            <h2 className="text-3xl font-extrabold mb-6">Focus Areas</h2>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
              {[
                {
                  title: "Environment",
                  Icon: Leaf,
                  desc: "Protecting nature, climate action, and environmental sustainability.",
                },
                {
                  title: "Education",
                  Icon: BookOpen,
                  desc: "Improving access to education, literacy, and lifelong learning.",
                },
                {
                  title: "Community",
                  Icon: Users,
                  desc: "Strengthening communities through collaboration and social impact.",
                },
                {
                  title: "Health",
                  Icon: HeartPulse,
                  desc: "Promoting physical and mental well-being for everyone.",
                },
              ].map(({ title, Icon, desc }) => (
                <div
                  key={title}
                  className="
            relative group bg-white/10 rounded-3xl p-8 text-center
            cursor-pointer overflow-hidden
            transition-all duration-300
            hover:-translate-y-2 hover:shadow-xl
          "
                >
                  {/* DEFAULT CONTENT */}
                  <div className="transition-opacity duration-300 group-hover:opacity-0">
                    <Icon size={42} className="mx-auto mb-4" />
                    <h3 className="text-xl font-bold">{title}</h3>
                  </div>

                  {/* HOVER CONTENT */}
                  <div
                    className="
              absolute inset-0 flex flex-col items-center justify-center
              px-6 text-sm text-white
              bg-green-800/90
              opacity-0 group-hover:opacity-100
              transition-opacity duration-300
            "
                  >
                    <h3 className="text-xl font-bold mb-3">{title}</h3>
                    <p className="leading-relaxed">{desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ================= EVENTS BY CATEGORY ================= */}
        <section className="py-4 space-y-24">
          {["Environment", "Education", "Community", "Health"].map(
            (category) => {
              const filtered = eventSource
                .filter((e) => e.category === category)
                .slice(0, 16);

              if (!filtered.length) return null;

              return (
                <div key={category} className="px-6 lg:px-20">
                  <h2 className="text-2xl font-extrabold mb-10">{category}</h2>

                  <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-8">
                    {filtered.map((event) => (
                      <EventCard key={event.id} {...event} />
                    ))}
                  </div>
                </div>
              );
            },
          )}
        </section>
      </main>

      <Footer />
    </>
  );
};

export default HomePage;
