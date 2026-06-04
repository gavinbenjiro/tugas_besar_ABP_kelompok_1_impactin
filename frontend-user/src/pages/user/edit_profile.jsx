import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Header from "../../components/navbar";
import avatarImg from "../../assets/photo avatar of user profile.png";
import { getProfileAPI, updateProfileAPI } from "../../api/profile";
import { uploadImageToCloudinary } from "../../api/cloudinary";

/* ================= CLOUDINARY CONFIG ================= */
const CLOUD_NAME = "YOUR_CLOUD_NAME";
const UPLOAD_PRESET = "YOUR_UPLOAD_PRESET";

/* ================= SKILLS NORMALIZER ================= */
/**
 * Menjamin output: array of STRING
 * Aman untuk semua bentuk response BE:
 * - null
 * - { id, user_id, skills: [...] }
 * - [{ id, user_id, skills: "React" }]
 * - ["React", "UI"]
 */
const normalizeSkills = (rawSkills) => {
  if (!rawSkills) return [];

  // case: { skills: [...] }
  if (!Array.isArray(rawSkills) && Array.isArray(rawSkills.skills)) {
    return rawSkills.skills.filter(Boolean);
  }

  // case: array (string / object)
  if (Array.isArray(rawSkills)) {
    return rawSkills
      .map((s) => {
        if (typeof s === "string") return s;
        if (typeof s === "object" && s.skills) return s.skills;
        return null;
      })
      .filter(Boolean);
  }

  return [];
};

const EditProfile = () => {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);

  const [formData, setFormData] = useState({
    username: "",
    name: "",
    age: "",
    location: "",
    status: "",
    bio: "",
    skills: [],
    avatar: avatarImg,
  });

  const [newSkill, setNewSkill] = useState("");

  /* ================= FETCH PROFILE ================= */
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const userId = localStorage.getItem("user_id"); // ✅ AMBIL ID

        if (!userId) {
          throw new Error("User not logged in");
        }

        const res = await getProfileAPI(userId); // ✅ KIRIM ID

        setFormData({
          username: res.username || "",
          name: res.name || "",
          age: res.age ?? "",
          location: res.city || "",
          status: res.status || "",
          bio: res.bio || "",
          skills: normalizeSkills(res.skills),
          avatar: res.image_url || avatarImg,
        });
      } catch (err) {
        console.error("Fetch profile failed:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  /* ================= IMAGE UPLOAD (CLOUDINARY) ================= */
  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    // 1️⃣ preview langsung (local)
    const localPreview = URL.createObjectURL(file);
    setFormData((prev) => ({
      ...prev,
      avatar: localPreview,
    }));

    try {
      // 2️⃣ upload ke Cloudinary
      const imageUrl = await uploadImageToCloudinary(file);

      // 3️⃣ ganti avatar ke URL cloudinary
      setFormData((prev) => ({
        ...prev,
        avatar: imageUrl,
      }));
    } catch (err) {
      console.error(err);
      alert("Upload image failed");
    }
  };

  /* ================= SAVE PROFILE ================= */
  const handleSave = async () => {
    try {
      const payload = {
        username: formData.username,
        name: formData.name,
        status: formData.status,
        age: formData.age ? Number(formData.age) : null,
        city: formData.location,
        bio: formData.bio,
        skills: formData.skills, // ⬅️ PASTI array string
        image_url: formData.avatar,
      };

      await updateProfileAPI(payload);

      alert("Profile updated successfully 🎉");
      navigate("/profile");
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || "Failed to update profile");
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
      </>
    );
  }

  return (
    <>
      <Header />

      <div className="min-h-screen bg-green-50 px-6 py-10">
        <div className="max-w-5xl mx-auto bg-white p-8 rounded-xl shadow-md">
          <h1 className="text-3xl font-bold text-green-800">Edit Profile</h1>

          <button
            onClick={() => navigate("/profile")}
            className="mt-2 text-sm text-green-700 hover:text-green-900"
          >
            ← Back to Profile
          </button>

          <hr className="my-6" />

          {/* PHOTO */}
          <div className="flex flex-col items-center mb-10">
            <img
              src={formData.avatar}
              alt="avatar"
              className="w-56 h-56 rounded-full object-cover
                         border-4 border-green-600 shadow-lg mb-4"
            />

            <label
              htmlFor="avatar-upload"
              className="cursor-pointer px-4 py-2
                         bg-green-700 text-white rounded-lg
                         text-sm hover:bg-green-800 transition"
            >
              Change Photo
            </label>

            <input
              id="avatar-upload"
              type="file"
              accept="image/*"
              onChange={handleImageUpload}
              className="hidden"
            />
          </div>

          {/* FORM */}
          <div className="space-y-5">
            {[
              ["*Username", "username"],
              ["*Nama", "name"],
              ["*Umur", "age"],
              ["*Lokasi", "location"],
              ["*Status", "status"],
            ].map(([label, key]) => (
              <div key={key}>
                <label className="font-semibold">{label}</label>
                <input
                  value={formData[key]}
                  onChange={(e) =>
                    setFormData({ ...formData, [key]: e.target.value })
                  }
                  className="w-full p-2 border rounded mt-1"
                />
              </div>
            ))}

            <div>
              <label className="font-semibold">*Bio</label>
              <textarea
                value={formData.bio}
                onChange={(e) =>
                  setFormData({ ...formData, bio: e.target.value })
                }
                className="w-full p-2 border rounded mt-1 h-28"
              />
            </div>

            {/* SKILLS */}
            <div>
              <label className="font-semibold">Skills</label>

              <div className="flex flex-wrap gap-2 mt-2">
                {formData.skills.length > 0 ? (
                  formData.skills.map((skill, i) => (
                    <span
                      key={`${skill}-${i}`}
                      className="bg-green-100 text-green-700
                                 px-3 py-1 rounded-full
                                 flex items-center gap-2"
                    >
                      {skill}
                      <button
                        onClick={() =>
                          setFormData({
                            ...formData,
                            skills: formData.skills.filter(
                              (_, idx) => idx !== i
                            ),
                          })
                        }
                        className="text-red-500 text-xs"
                      >
                        ✕
                      </button>
                    </span>
                  ))
                ) : (
                  <p className="text-sm text-gray-400">No skills added</p>
                )}
              </div>

              <div className="flex gap-2 mt-3">
                <input
                  type="text"
                  placeholder="Add skill..."
                  value={newSkill}
                  onChange={(e) => setNewSkill(e.target.value)}
                  className="flex-1 p-2 border rounded"
                />
                <button
                  onClick={() => {
                    if (newSkill.trim()) {
                      setFormData({
                        ...formData,
                        skills: [...formData.skills, newSkill.trim()],
                      });
                      setNewSkill("");
                    }
                  }}
                  className="px-6 py-2 bg-green-700 text-white rounded-lg"
                >
                  Add
                </button>
              </div>
            </div>
          </div>

          {/* SAVE */}
          <div className="mt-10 flex justify-end">
            <button
              onClick={handleSave}
              className="px-6 py-2 bg-green-700 text-white rounded-lg"
            >
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default EditProfile;
