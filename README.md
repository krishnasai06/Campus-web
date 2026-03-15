# SRM Unofficial Client

A privacy-first, client-side-only Flutter app for SRM University students to view Attendance, Marks, and Timetable from the official Academia portal.

## 🔐 Security
- **No Backend:** All logic runs strictly on your device.
- **No Data Storage:** We never store your passwords permanently. Only session cookies are kept in encrypted storage.
- **Privacy:** No analytics, no tracking, and no external calls except to the official university portal.
- **Open Source:** Verify the code yourself.

## 🔄 Updates
Since this app scrapes information directly from the SRM portal, updates may be required if the university changes their website structure:
1. Check GitHub Issues for reports of broken features.
2. Wait for a new release with updated HTML selectors.
3. Download and install the latest APK.

## 🛠️ Troubleshooting
- **Login Failed:** Double-check your NetID and Password. Sometimes the portal requires a CAPTCHA; try logging in on a browser first.
- **Data Not Loading:** Your portal session might have expired. Try logging out and logging back in.
- **App Crashing:** Ensure you are on the latest version and have a stable internet connection.

## 🚀 Development
- **Framework:** Flutter
- **State Management:** Provider
- **Security:** flutter_secure_storage
- **Scraping:** dio + html parser
