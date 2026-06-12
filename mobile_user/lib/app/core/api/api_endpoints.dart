class ApiEndpoints {
  static const register = '/user/register';
  static const login = '/user/login';
  static const logout = '/user/logout';

  static const profile = '/user/profile';
  static const experience = '/user/profile/experience';

  static const updatePassword = '/user/profile/password';
  static const cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/dscz9j9ui/image/upload';
  static const cloudinaryUploadPreset = 'impactin_unsigned';

  static const getProfile = "/user/profile";

  static const getAllEvents = "/user/events";

  static String getEventDetail(int eventId) => "$getAllEvents/$eventId";

  static String getEventsByCategory(String category) =>
      "/user/events?category=$category";

  static const getRecommendationEvents = "/user/events/recommendation";

  static String getJoinedEvents(String status) =>
      "/user/events/joined?status=$status";

  static String getCreatedEvents(String status) =>
      "/user/events/your?status=$status";
  static const createEvent = "/user/events/";
  static String getCreatedEventDetail(int eventId) =>
      "/user/events/your/$eventId";

  static String cancelEvent(int eventId) => "/user/events/cancel/$eventId";

  static String closeEvent(int eventId) => "/user/events/close/$eventId";

  static String openEvent(int eventId) => "/user/events/open/$eventId";

  static String approveApplicant(int userId) =>
      "/user/events/applicants/$userId";
  static String removeParticipant(int userId) =>
      "/user/events/participants/$userId";

  static String joinEvent(int eventId) => "/user/events/join/$eventId";
  static String reportEvent(int eventId) => "/user/events/report/$eventId";

  static const saveFcmToken = "/user/fcm-token";
  static const getNotifications = "/notifications";
  static const bellStatus = "/notification/bell-status";
  static const markBellRead = "/notification";
  static const getNearbyEvents = "/user/events/nearby";
}
