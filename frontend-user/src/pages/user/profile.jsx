import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Header from "../../components/navbar.jsx";
import Footer from "../../components/footer.jsx";
import MOCK_CARD_IMAGE from "../../assets/hero news.png";
import avatarImg from "../../assets/photo avatar of user profile.png";
import { uploadImageToCloudinary } from "../../api/cloudinary";
import {
  getProfileAPI,
  changePasswordAPI,
  addExperienceAPI,
  deleteExperienceAPI,
  editExperienceAPI,
} from "../../api/profile";

const ProfilePage = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const today = new Date().toISOString().split("T")[0];

  /* ================= USER ID LOGIC ================= */
  const loggedUserId = localStorage.getItem("user_id");
  const profileUserId = id || loggedUserId;
  const isOwnProfile = profileUserId === loggedUserId;

  /* ================= PROFILE STATE ================= */
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  /* ================= EXPERIENCE STATE ================= */
  const [experienceList, setExperienceList] = useState([]);

  /* ================= EVENT STATE ================= */
  const [eventList, setEventList] = useState([]);

  /* ================= ADD EXPERIENCE ================= */
  const [showAddExpModal, setShowAddExpModal] = useState(false);
  const [isUploading, setIsUploading] = useState(false);

  const [expForm, setExpForm] = useState({
    title: "",
    host_name: "",
    date: "",
    description: "",
    cover_image: "",
  });

  /* ================= HANDLE SUBMIT ================= */
  const handleAddExperience = async () => {
    if (!expForm.title || !expForm.host_name || !expForm.date) {
      alert("Title, host name, dan date wajib diisi");
      return;
    }

    try {
      const payload = {
        title: expForm.title.trim(),
        host_name: expForm.host_name.trim(),
        date: expForm.date,
        description: expForm.description?.trim() || "",
        ...(expForm.cover_image ? { cover_image: expForm.cover_image } : {}),
      };

      // 🔥 PENTING: ini yang kamu kurang sebelumnya
      const res = await addExperienceAPI(payload);

      console.log("ADD RESPONSE:", res.data);

      // 🔥 FIX: handle kemungkinan backend bentuknya beda
      const data = res.data?.data || res.data || {};

      const newExperience = {
        id: data.experience_id || data.id,
        title: data.title || expForm.title,
        organizer: data.host_name || expForm.host_name,
        date: data.date || expForm.date,
        description: data.description || expForm.description,
        cover: data.cover_image || expForm.cover_image || MOCK_CARD_IMAGE,
      };

      setExperienceList((prev) => [newExperience, ...prev]);

      setShowAddExpModal(false);

      setExpForm({
        title: "",
        host_name: "",
        date: "",
        description: "",
        cover_image: "",
      });
    } catch (err) {
      console.error(err?.response?.data || err);
      alert(err?.response?.data?.message || "Failed to add experience");
    }
  };

  /* ================= EDIT EXPERIENCE ================= */
  const [showEditExpModal, setShowEditExpModal] = useState(false);
  const [editingExpId, setEditingExpId] = useState(null);
  const handleDeleteExperience = async (expId) => {
    if (!expId) {
      console.error("DELETE FAILED: expId undefined");
      return;
    }

    if (!window.confirm("Yakin ingin menghapus experience ini?")) return;

    try {
      await deleteExperienceAPI(expId);
      setExperienceList((prev) => prev.filter((e) => e.id !== expId));
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || "Failed to delete experience");
    }
  };
  const toInputDate = (dateString) => {
    if (!dateString) return "";
    return dateString.split("T")[0]; // ambil YYYY-MM-DD
  };

  const openEditExperience = (exp) => {
    setEditingExpId(exp.id);

    setExpForm({
      title: exp.title,
      host_name: exp.organizer,
      date: toInputDate(exp.date), // 🔥 FIX UTAMA
      description: exp.description || "",
      cover_image: exp.cover || "",
    });

    setShowEditExpModal(true);
  };

  const handleEditExperience = async () => {
    if (!editingExpId) return;

    const payload = {
      title: expForm.title,
      host_name: expForm.host_name,
      description: expForm.description,
    };

    // 🔥 date WAJIB valid
    if (expForm.date?.trim()) {
      payload.date = expForm.date;
    }

    // cover_image opsional
    if (expForm.cover_image?.trim()) {
      payload.cover_image = expForm.cover_image;
    }

    try {
      await editExperienceAPI(editingExpId, payload);

      setExperienceList((prev) =>
        prev.map((e) =>
          e.id === editingExpId
            ? {
                ...e,
                title: payload.title,
                organizer: payload.host_name,
                date: payload.date || e.date,
                description: payload.description,
                cover: payload.cover_image || e.cover,
              }
            : e,
        ),
      );

      setShowEditExpModal(false);
      setEditingExpId(null);
    } catch (err) {
      console.error(err.response?.data || err);
      alert(err.response?.data?.message || "Failed to update experience");
    }
  };

  /* ================= FETCH PROFILE ================= */
  /* ================= FETCH PROFILE ================= */
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        setLoading(true);
        const res = await getProfileAPI(profileUserId);

        setProfile({
          name: res.name,
          username: res.username,
          role: res.status || "User",
          age: res.age ? `${res.age} Tahun` : "-",
          location: res.city || "-",
          bio: res.bio || "Belum ada bio.",
          skills: Array.isArray(res.skills)
            ? res.skills.map((s) => (typeof s === "string" ? s : s.skills))
            : [],
          image: res.image_url || avatarImg,
        });

        /* 🔥 SYNC EVENTS DARI BACKEND */
        if (Array.isArray(res.events)) {
          setEventList(
            res.events.map((ev) => ({
              id: ev.event_id,
              title: ev.title,
              organizer: ev.creator,
              date: ev.start_date,
              description: ev.description,
              cover: ev.cover_image || MOCK_CARD_IMAGE,
            })),
          );
        } else {
          setEventList([]);
        }

        /* 🔥 SYNC EXPERIENCE DARI BACKEND */
        if (Array.isArray(res.experiences)) {
          setExperienceList(
            res.experiences.map((e) => ({
              id: e.experience_id,
              title: e.title,
              organizer: e.creator,
              date: e.date,
              description: e.description,
              cover: e.cover_image || MOCK_CARD_IMAGE,
            })),
          );
        } else {
          setExperienceList([]);
        }
      } catch (err) {
        console.error("Failed to fetch profile:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, [profileUserId]);

  const formatDateEN = (dateString) => {
    if (!dateString) return "-";

    return new Date(dateString).toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
  };

  /* ================= TAB ================= */
  const [tab, setTab] = useState("experience");

  /* ================= LOGOUT ================= */
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user_id");
    navigate("/login");
  };

  /* ================= CHANGE PASSWORD ================= */
  const [showChangePwModal, setShowChangePwModal] = useState(false);
  const [passwordForm, setPasswordForm] = useState({
    current: "",
    newPw: "",
    confirm: "",
  });

  const handleChangePassword = async () => {
    if (!passwordForm.current || !passwordForm.newPw || !passwordForm.confirm) {
      alert("Semua field wajib diisi!");
      return;
    }

    if (passwordForm.newPw !== passwordForm.confirm) {
      alert("Password baru tidak sama!");
      return;
    }

    try {
      await changePasswordAPI({
        old_password: passwordForm.current,
        new_password: passwordForm.newPw,
      });

      alert("Password berhasil diubah ✅");
      setShowChangePwModal(false);
      setPasswordForm({ current: "", newPw: "", confirm: "" });
    } catch (err) {
      alert(err.response?.data?.message || "Gagal mengubah password");
    }
  };

  /* ================= LOADING ================= */
  if (loading) {
    return (
      <>
        <Header />
        <div className="min-h-screen flex items-center justify-center">
          Loading profile...
        </div>
        <Footer />
      </>
    );
  }

  return (
    <>
      <Header />

      <div className="min-h-screen bg-green-50 px-6 py-10">
        <div className="max-w-6xl mx-auto">
          {/* ================= PROFILE HEADER ================= */}
          <div className="bg-gradient-to-r from-green-200 to-green-100 p-10 rounded-xl shadow-md flex items-center gap-8">
            <img
              src={profile.image}
              alt="Profile"
              className="w-32 h-32 rounded-full object-cover"
            />

            <div>
              <h1 className="text-3xl font-bold text-green-800">
                {profile.name}
              </h1>

              <div className="flex flex-wrap gap-2 mt-2 text-sm">
                {[profile.role, profile.age, profile.location].map(
                  (item, i) => (
                    <span
                      key={i}
                      className="bg-green-700 text-white px-3 py-1 rounded-full"
                    >
                      {item}
                    </span>
                  ),
                )}
              </div>

              <p className="mt-4 italic text-green-900">{profile.bio}</p>
            </div>

            {isOwnProfile && (
              <button
                onClick={() => navigate("/edit_profile")}
                className="ml-auto px-4 py-2 bg-green-700 text-white rounded-lg"
              >
                Edit Profile
              </button>
            )}
          </div>

          {/* ================= MAIN ================= */}
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 mt-10">
            {/* LEFT */}
            <div className="bg-white p-6 rounded-xl shadow space-y-6">
              <div>
                <h2 className="font-bold text-green-800 mb-3">Skills</h2>
                <div className="flex flex-wrap gap-2">
                  {profile.skills.length > 0 ? (
                    profile.skills.map((s, i) => (
                      <span
                        key={i}
                        className="bg-green-100 text-green-700 px-3 py-1 text-sm rounded-full"
                      >
                        {s}
                      </span>
                    ))
                  ) : (
                    <p className="text-sm text-gray-400">No skills added</p>
                  )}
                </div>
              </div>

              <hr />

              {/* ================= ACCOUNT SETTINGS ================= */}
              {isOwnProfile && (
                <div className="mt-4 space-y-3">
                  <p className="font-bold text-green-800 mb-3">
                    Account Settings
                  </p>

                  {/* CHANGE PASSWORD */}
                  <button
                    onClick={() => setShowChangePwModal(true)}
                    className="w-full text-left px-4 py-3 rounded-lg bg-green-100 border border-green-200 
                              hover:bg-green-50 transition"
                  >
                    <p className="text-green-700 font-semibold">
                      Change Password
                    {/* </p>
                    <p className="text-xs text-gray-500">
                      Update your security */}
                    </p>
                  </button>

                  {/* LOGOUT (FULL RED) */}
                  <button
                    onClick={() => setShowLogoutModal(true)}
                    className="w-full text-left px-4 py-3 rounded-lg bg-red-600 
                              text-white font-semibold hover:bg-red-700 transition"
                  >
                    Log Out
                    {/* <p className="text-xs text-red-100 font-normal">
                      Sign out from this device
                    </p> */}
                  </button>
                </div>
              )}
            </div>

            {/* RIGHT */}
            <div className="lg:col-span-3 bg-white p-6 rounded-xl shadow">
              <div className="flex border-b mb-5 justify-between items-center">
                <div>
                  <button
                    onClick={() => setTab("experience")}
                    className={`px-6 py-2 font-semibold ${
                      tab === "experience"
                        ? "text-green-700 border-b-2 border-green-700"
                        : "text-gray-500"
                    }`}
                  >
                    Experience
                  </button>

                  <button
                    onClick={() => setTab("events")}
                    className={`px-6 py-2 font-semibold ${
                      tab === "events"
                        ? "text-green-700 border-b-2 border-green-700"
                        : "text-gray-500"
                    }`}
                  >
                    Impactin Experiance
                  </button>
                </div>

                {isOwnProfile && tab === "experience" && (
                  <button
                    onClick={() => setShowAddExpModal(true)}
                    className="px-4 py-2 bg-green-700 text-white rounded-lg"
                  >
                    + Add Experience
                  </button>
                )}
              </div>

              {/* EXPERIENCE TAB */}
              {tab === "experience" && (
                <div className="space-y-6">
                  {experienceList.length === 0 && (
                    <p className="text-gray-500 italic">
                      No experience added yet.
                    </p>
                  )}

                  {experienceList.map((e) => (
                    <div
                      key={e.id}
                      className="flex items-center gap-5 border-b pb-5"
                    >
                      <img
                        src={e.cover}
                        alt={e.title}
                        className="w-36 h-24 rounded-lg object-cover"
                      />

                      <div className="flex-1">
                        {isOwnProfile && (
                          <div className="flex gap-2 mb-2">
                            <button
                              onClick={() => openEditExperience(e)}
                              className="px-3 py-1 bg-amber-400 text-white rounded"
                            >
                              Edit
                            </button>
                            <button
                              onClick={() => handleDeleteExperience(e.id)}
                              className="px-3 py-1 bg-red-500 text-white rounded"
                            >
                              Delete
                            </button>
                          </div>
                        )}

                        <h3 className="font-semibold text-green-800 text-lg">
                          {e.title}
                        </h3>
                        <p className="text-sm text-gray-600">{e.organizer}</p>
                        <p className="text-xs text-gray-500 mt-1">
                          {formatDateEN(e.date)}
                        </p>

                        {e.description && (
                          <p className="text-sm mt-2 text-gray-600">
                            {e.description}
                          </p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* EVENTS TAB */}
              {tab === "events" && (
                <div className="space-y-6">
                  {eventList.length === 0 && (
                    <p className="text-gray-500 italic">No events available.</p>
                  )}

                  {eventList.map((ev) => (
                    <div
                      key={ev.id}
                      className="flex items-center gap-5 border-b pb-5"
                    >
                      <img
                        src={ev.cover}
                        alt={ev.title}
                        className="w-36 h-24 rounded-lg object-cover"
                      />

                      <div className="flex-1">
                        <h3 className="font-semibold text-green-800 text-lg">
                          {ev.title}
                        </h3>

                        <p className="text-sm text-gray-600">{ev.organizer}</p>

                        <p className="text-xs text-gray-500 mt-1">
                          {formatDateEN(ev.date)}
                        </p>

                        {ev.description && (
                          <p className="text-sm mt-2 text-gray-600">
                            {ev.description}
                          </p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>


      <Footer />

      {/* ================= ADD EXPERIENCE MODAL ================= */}
      {showAddExpModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl w-full max-w-md max-h-screen overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">Add Experience</h2>

            <input
              type="text"
              placeholder="Title"
              value={expForm.title}
              onChange={(e) =>
                setExpForm({ ...expForm, title: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="text"
              placeholder="Host / Organizer"
              value={expForm.host_name}
              onChange={(e) =>
                setExpForm({ ...expForm, host_name: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="date"
              value={expForm.date}
              max={today} // ✅ TIDAK BISA LEBIH DARI HARI INI
              onChange={(e) => setExpForm({ ...expForm, date: e.target.value })}
              className="w-full border p-2 rounded mb-3"
            />

            <textarea
              placeholder="Description"
              value={expForm.description}
              onChange={(e) =>
                setExpForm({ ...expForm, description: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">
                Cover Image
              </label>
              <input
                type="file"
                accept="image/*"
                onChange={async (e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;

                  try {
                    const url = await uploadImageToCloudinary(file);
                    setExpForm((prev) => ({
                      ...prev,
                      cover_image: url,
                    }));
                  } catch (err) {
                    console.error("Upload failed:", err);
                  }
                }}
                className="w-full border p-2 rounded"
              />

              {/* 🔥 PREVIEW IMAGE SETELAH UPLOAD */}
              {expForm.cover_image && (
                <div className="mt-3">
                  <img
                    src={expForm.cover_image}
                    alt="Preview"
                    className="w-full h-40 rounded object-cover border-2 border-green-500"
                  />
                  <p className="text-xs text-green-600 mt-1">
                    ✓ Gambar berhasil diupload
                  </p>
                </div>
              )}
            </div>

            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowAddExpModal(false)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleAddExperience}
                className="px-4 py-2 bg-green-700 text-white rounded"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
      {/* ================= EDIT EXPERIENCE MODAL ================= */}
      {showEditExpModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl w-full max-w-md max-h-screen overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">Edit Experience</h2>

            <input
              type="text"
              placeholder="Title"
              value={expForm.title}
              onChange={(e) =>
                setExpForm({ ...expForm, title: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="text"
              placeholder="Host / Organizer"
              value={expForm.host_name}
              onChange={(e) =>
                setExpForm({ ...expForm, host_name: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="date"
              value={expForm.date}
              max={today} // ✅ DIKUNCI SAMPAI HARI INI
              onChange={(e) => setExpForm({ ...expForm, date: e.target.value })}
              className="w-full border p-2 rounded mb-3"
            />

            <textarea
              placeholder="Description"
              value={expForm.description}
              onChange={(e) =>
                setExpForm({ ...expForm, description: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">
                Cover Image
              </label>
              <input
                type="file"
                accept="image/*"
                onChange={async (e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;

                  try {
                    const url = await uploadImageToCloudinary(file);
                    setExpForm((prev) => ({
                      ...prev,
                      cover_image: url,
                    }));
                  } catch (err) {
                    console.error("Upload failed:", err);
                  }
                }}
                className="w-full border p-2 rounded"
              />

              {/* 🔥 PREVIEW IMAGE SETELAH UPLOAD */}
              {expForm.cover_image && (
                <div className="mt-3">
                  <img
                    src={expForm.cover_image}
                    alt="Preview"
                    className="w-full h-40 rounded object-cover border-2 border-green-500"
                  />
                  <p className="text-xs text-green-600 mt-1">
                    ✓ Gambar terbaru
                  </p>
                </div>
              )}
            </div>

            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowEditExpModal(false)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleEditExperience}
                className="px-4 py-2 bg-green-700 text-white rounded"
              >
                Update
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= LOGOUT MODAL ================= */}
      {showLogoutModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl w-full max-w-sm">
            <h2 className="text-lg font-bold mb-4">Confirm Logout</h2>
            <p className="mb-6 text-gray-600">
              Are you sure you want to log out?
            </p>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleLogout}
                className="px-4 py-2 bg-red-600 text-white rounded"
              >
                Log Out
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= CHANGE PASSWORD MODAL ================= */}
      {showChangePwModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Change Password</h2>

            <input
              type="password"
              placeholder="Current password"
              value={passwordForm.current}
              onChange={(e) =>
                setPasswordForm({ ...passwordForm, current: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="password"
              placeholder="New password"
              value={passwordForm.newPw}
              onChange={(e) =>
                setPasswordForm({ ...passwordForm, newPw: e.target.value })
              }
              className="w-full border p-2 rounded mb-3"
            />

            <input
              type="password"
              placeholder="Confirm new password"
              value={passwordForm.confirm}
              onChange={(e) =>
                setPasswordForm({ ...passwordForm, confirm: e.target.value })
              }
              className="w-full border p-2 rounded mb-4"
            />

            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowChangePwModal(false)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleChangePassword}
                className="px-4 py-2 bg-green-700 text-white rounded"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ProfilePage;
