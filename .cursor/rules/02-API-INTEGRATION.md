# Taekworld Master — Backend API Integration Guide

Prepared 2026-09-11 for the mobile rewrite vendor. Every endpoint below was traced from the shipped Flutter app to the C# controller that serves it (`API/API/Controllers/API/*.cs`), so paths, bodies and response shapes are what production answers today. Import `taekworld-master-app.postman_collection.json` + `taekworld-master-app.postman_environment.json` to try them.

Companion: `01-UI-SPEC.md` (screens and flows).

---

## 1. Environment

| | Value |
|---|---|
| Production API | `https://api.taekworld.com` (alias `https://api.blackbelthw.com`) |
| UAT API | Cloud Run service `api-uat` (URL shared with the vendor on request; UAT DB is separate and holds test dojangs only) |
| Health probe | `GET /api/health` → `200 {"status":"API healthy","timestamp":"…"}` (anonymous). The app only trusts a JSON body whose `status` contains "api healthy". |
| Backend stack | ASP.NET Core 8, EF Core, PostgreSQL. JSON is camelCase on the wire; request bodies bind case-insensitively. |
| Auth | Self-issued HS256 JWT, `Authorization: Bearer <token>`. Access token lifetime **60 min**; refresh token **7 days**. |
| CORS | Not relevant for native clients. |
| Rate limiting | Login for operator roles is locked after 5 failures / 5 min; other routes have no client-visible limit. |

The current app hard-codes the production host for dev, staging and prod alike. The new build should take the host from a build flavour so UAT can be targeted.

## 2. Authentication

### 2.1 Login — `POST /api/Auth/login` (anonymous)

Request:
```json
{ "email": "master@example.com", "password": "•••", "role": "master" }
```
Other accepted fields: `rememberMe` (bool), `dojangId` (int, used by the web for dojang-scoped student logins; not needed here).

Response `200`:
```json
{
  "success": true,
  "token": "<jwt>",
  "refreshToken": "<opaque>",
  "expiresAt": "2026-09-11T05:00:00Z",
  "expiresIn": 3600,
  "user": {
    "uid": "…", "email": "…", "firstName": "…", "lastName": "…", "displayName": "…",
    "phoneNumber": "7037601000", "role": "master", "roles": ["master"],
    "academyId": "5688", "academyName": "Taekworld Academy", "academyPhoneNumber": "7037601000",
    "isActive": true, "status": "…", "statusText": "…", "userCode": "…",
    "isTrialUser": false, "trialType": null, "trialEndDate": null
  },
  "message": "…"
}
```
Fields the app uses: `token`, `refreshToken`, `user.uid`, `user.email`, `user.firstName/lastName`, `user.phoneNumber`, `user.academyId`, `user.academyName`, `user.status/statusText`. `academyId` is the **dojang id** used by every other call. Store it as an integer.

Errors: `400` validation, `401 {"success":false,"message":"That email or password doesn't seem to match…"}` (also for locked/deactivated), `403 {"success":false,"errorCode":"DOJANG_SCOPE_MISMATCH"}` (only when `dojangId` is sent), `429` too many attempts.

**Important:** the server ignores `role` and does not restrict this route to masters. The new app must check `user.roles` contains `master` (case-insensitive) after login and refuse other accounts. We will also add a server-side gate; treat both as required.

### 2.2 Refresh — `POST /api/Auth/refresh-token` (anonymous)

Request `{ "refreshToken": "<opaque>" }` → same `AuthResponse` shape with a new `token`, `refreshToken`, `expiresAt`, `expiresIn`. The current app never calls this and simply dies after 60 minutes; the new app must refresh proactively (before `expiresAt`) and on any `401`.

### 2.3 Session check — `GET /api/Auth/profile` (Bearer)

Returns the same `AuthResponse` shape for the caller (`token` echoes the request token). `401` means the session is gone. Use it on cold start when a stored token exists.

### 2.4 Logout

There is no server logout. On logout the app must: call `POST /api/Notification/delete-device` (see §5.2) so pushes stop, then wipe local storage. Tokens must live in the platform secure store (Keychain / Keystore), never in plain preferences.

### 2.5 Common error envelope

Most JSON errors look like `{ "success": false, "message": "…" }`, sometimes with `errorCode`/`code`. Two codes the app must handle explicitly:

| Status / code | Meaning | App behaviour |
|---|---|---|
| `403` `{"success":false,"code":"MASTER_TOOL_LOCKED","message":"…"}` | The master's tools are locked (unpaid referral fee, or an operator lock). Returned by applications, application detail, trial students, enroll. | Show a "Your master tools are locked — open the website for details" state instead of an empty list. |
| `403` (empty body, `Forbid`) | Caller has no verified association with that dojang. | Treat as "wrong account", force logout. |

## 3. Dashboard and lists

All Bearer unless noted. `{dojangId}` = `user.academyId` from login.

### 3.1 Statistics — `GET /api/TrialMember/statistics/{dojangId}`

Response `200`:
```json
{ "currentStudents": 146, "sevenDaysTrial": 31, "thirtyDaysTrial": 101, "newStudents": 12, "totalMembers": 290, "recommendationCount": 56 }
```
`404 {"message":"Dojang not found"}`. Used by the My Dojang cards and the Trial Members summary. (The current app displays `currentStudents - 1`; we will fix the count server-side so the new app should display the value as returned.) Note: this route is currently `[AllowAnonymous]`; it will be put behind auth, so always send the Bearer token.

### 3.2 Trial members — `GET /api/TrialMember/students/{dojangId}?category={category}`

`category` ∈ `7 days trial` | `30 days trial` (also accepts `current student`, `new students`, `family members`). Response `200` is a **bare array**:
```json
[
  { "id": 123, "name": "Jay Smith", "email": "p@example.com", "parentName": "Pat Smith", "parentPhone": "7035550100",
    "joinDate": "2026-09-01", "status": "new", "trialEndDate": "2026-09-08", "isTrialUser": true, "trialType": "7" }
]
```
Card mapping: title `name` (fallback `parentName`), subtitle `email` / `parentPhone`, pill `trialType` days, "days left" = `trialEndDate` − today, "New Student" = `status == "new" || isTrialUser`. `403 MASTER_TOOL_LOCKED` possible.

### 3.3 Applications — `GET /api/NewStudent/applications/{dojangId}`

Response `200`:
```json
{
  "pendingApplications": [
    { "id": 501, "studentFirstName": "Olivia", "studentLastName": "Davis", "studentName": "Olivia Davis",
      "parentName": "Emma Davis", "parentEmail": "…", "parentPhone": "…",
      "applicationDate": "2026-09-10", "applicationDateValue": "2026-09-10T14:03:11Z",
      "status": "Pending", "isViewed": false, "viewedDate": null, "viewedDateFormatted": "",
      "paymentStatus": null, "paymentAmount": null, "scheduledChargeDate": null }
  ],
  "enrolledApplications": [ { "id": 480, "studentName": "…", "parentName": "…", "applicationDate": "2026-08-30", "status": "Enrolled", "paymentStatus": "Completed" } ],
  "totalPending": 1, "totalEnrolled": 1
}
```
Enrolled items have no `isViewed`/`viewedDate`. Contact fields may be masked when the master has no card on file (`ContactMasking`). `403 MASTER_TOOL_LOCKED` possible. The current app polls this every 10 s; with FCM in place the new app should refresh on push, on resume and on pull, not on a timer.

### 3.4 Application detail — `GET /api/NewStudent/application/{applicationId}`

Response `200` (`StudentApplicationDetailDto`):
```json
{ "id": 501, "studentFirstName": "…", "studentLastName": "…", "dateOfBirth": "2016-04-02", "gender": "F", "schoolNameGrade": "…",
  "parentFullName": "…", "relationshipToStudent": "Mother", "parentPhoneNumber": "…", "parentEmail": "…",
  "streetAddress": "…", "city": "…", "state": "VA", "zipCode": "22102",
  "emergencyContactName": "…", "emergencyContactPhone": "…",
  "hasMedicalConditions": "yes", "allergies": "…", "medicalConditionDetails": "…", "currentMedication": "…",
  "liabilityWaiverAccepted": true, "photoPermissionGranted": true,
  "applicationDate": "2026-09-10T14:03:11Z", "applicationStatus": "Pending", "receiptDate": null, "enrollmentDate": null,
  "notes": null, "hasPaymentMethod": true, "paymentStatus": null, "scheduledChargeDate": null }
```
Note `applicationStatus` here vs `status` in the list. First read stamps the application as viewed. `404 {"message":"Application not found"}`.

### 3.5 Enroll — `POST /api/TrialMember/enroll/{applicationId}`

Body `{ "enrollmentDate": "2026-09-11T00:00:00Z" }` (only field). Returns `200 { "success": true, … }`. The current app does not call it and instead opens the web page `https://www.blackbelthw.com/master/newstudent`. Keep the web hand-off for v1 (enrollment can trigger a $150 referral-fee charge and a confirmation flow that lives on the web); if in-app enrollment is wanted later, this is the endpoint.

### 3.6 Counters used for in-app alerts (optional)

| Endpoint | Response |
|---|---|
| `GET /api/NewStudent/registration-count/{dojangId}` | `{ "newRegistrationsCount": 2, "hasNewRegistrations": true, "latestRegistration": { "studentName", "parentName", "registrationDate", "trialType" } }` |
| `GET /api/Recommendation/invitation-count/{dojangId}` | `{ "newInvitationsCount": 3, "hasNewInvitations": true, "inviterName": "…", "invitationsSent": [ { "childName", "phoneNumber", "email", "sentDate" } ] }` (requires a verified master association) |
| `GET /api/TrialMemberNotification/new-trials/{dojangId}?userId={uid}` | `{ "newSevenDayTrials": [TrialMemberDto], "newThirtyDayTrials": [...], "totalNewTrials", "totalSevenDay", "totalThirtyDay", "alreadyNotifiedCount", "hasNewMembers" }` where `TrialMemberDto` = `{ userId, userCode, fullName, email, phoneNumber, trialType, trialStartDate, trialEndDate, isNewStudent, registrationDate, daysRemaining }` |
| `POST /api/TrialMemberNotification/mark-notified` | body `{ "userIds": ["…"], "masterId": "<uid>", "dojangId": 5688 }` → `{ "success", "message", "notifiedCount", "failedUserIds" }`. Call it after showing new trials, otherwise `new-trials` returns the same people forever (the current app never calls it). |
| `GET /api/TrialMemberNotification/check-updates/{dojangId}?userId={uid}&lastCheckTime={iso}` | `{ "hasNewMembers", "newMemberCount", "lastCheckTime", "latestMembers": [ { "name", "trialType", "registeredAt" } ] }` |
| `GET /api/TrialMemberNotification/history/{dojangId}?userId={uid}&days=7` | `{ "history": [ { "userId", "memberName", "trialType", "notifiedDate", "notifiedBy" } ], "totalCount", "dateRange" }` |

The iOS build polls the first three every 5 seconds in the foreground. With FCM this polling is unnecessary; keep at most a refresh-on-resume.

## 4. Push notifications (FCM)

The backend already sends FCM messages per device token (`FcmNotificationService`), and also queues every event as a "pending notification" row for the polling path. **The new app should use FCM on both platforms** and drop the Android 10-second polling service.

### 4.1 Firebase project

Project `taekworld`, sender id `433251623503`, bundle/package `com.taekworld.master`. `GoogleService-Info.plist` exists in `App/Apple/ios/Runner/`; an Android `google-services.json` must be generated for the same project (the old Android build never used FCM).

### 4.2 Register a device — `POST /api/Notification/register-device`

Body:
```json
{ "fcmToken": "<token>", "platform": "ios" | "android", "dojangId": 5688, "deviceInfo": "iPhone 15 - iOS 17.5" }
```
`200 {"success":true,"message":"Device token registered successfully"}`; `401` not authenticated; `403` no access to that dojang. Upserts by token (user id from the JWT). Call after login, whenever FCM rotates the token, and on app resume if more than a day has passed.

### 4.3 Unregister — `POST /api/Notification/delete-device`

Body `{ "fcmToken": "<token>" }` → `{"success":true}`. Call on logout.

### 4.4 Message format the server sends

```json
{
  "notification": { "title": "🎓 New Student Application", "body": "Olivia Davis applied…" },
  "data": {
    "dojangId": "5688", "notificationId": "1234",
    "title": "…", "body": "…",
    "action": "open_browser", "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "timestamp": "2026-09-11T02:00:00.0000000Z"
  },
  "apns": { "headers": { "apns-priority": "10", "apns-push-type": "alert" },
            "payload": { "aps": { "alert": {…}, "content-available": true, "sound": "notification.caf", "badge": 1, "thread-id": "taekworld_notifications" } } }
}
```
Event types (from `NotificationType`): `NewApplication`, `NewTrialMember`, `NewRegistration`, `ParentInvitation`. **Today the FCM `data` block does not carry the type**; we will add `"type": "NewApplication"` and `"entityId"` to the data payload before the new app ships, so the app can pick an icon and, if desired, open the matching tab. Until then treat unknown types generically. The server sets `badge: 1` on every push; the app should compute its own badge from unread local items.

Tap behaviour today: open `https://www.blackbelthw.com/{masterPhone}` in the browser. The new app may instead open the Applications / Trial Members tab based on `type` and refresh; keep the browser hand-off as the fallback.

### 4.5 Pending-notification queue (polling path, optional)

Kept for completeness; the new app does not need it if FCM is reliable, but it is useful as a catch-up on cold start.

| Endpoint | Notes |
|---|---|
| `GET /api/Notification/pending/{dojangId}?deviceId={id}` | `{ "dojangId", "totalCount", "notifications": [ { "id", "type": "NewApplication", "title", "message", "payload": "<json string>", "createdAt", "entityType", "entityId" } ], "timestamp" }`. `payload` per type: NewApplication `{applicationId, studentName, parentName, parentEmail, parentPhone, timestamp}`; NewTrialMember / NewRegistration `{userId, userName, email, phone, timestamp}`; ParentInvitation `{invitationId, inviterName, inviterEmail, inviterPhone, inviteeName, inviteePhone, inviteeEmail, timestamp}`. Rows expire after 7 days (30 for invitations). `deviceId` is any stable client id; it is stored, not filtered on. |
| `POST /api/Notification/mark-delivered` | `{ "notificationIds": [1234], "deviceId": "…" }` → `{ "success", "count", "deliveredIds" }`. |
| `POST /api/Notification/acknowledge/{notificationId}` | Marks read on the server (never used today). |

### 4.6 Diagnostics (do not use)

`POST /api/Notification/test`, `test-fcm`, `test-all-platforms`, `direct-fcm-test`, `GET test-flow/{id}`, `diagnose/{id}`, `quick-test/{id}`, `test-firebase`, `firebase-init-test`, `firebase-fallback-test` all answer `404` outside a Development environment with an Admin token. They are excluded from the Postman collection.

## 5. Recommended contract for the new app

| Screen / moment | Calls |
|---|---|
| Cold start with stored session | `GET /api/Auth/profile` → on 401 try `POST /api/Auth/refresh-token` → else login screen |
| Login | `POST /api/Auth/login` → role check → `POST /api/Notification/register-device` |
| My Dojang | `GET /api/TrialMember/statistics/{dojangId}` |
| Applications | `GET /api/NewStudent/applications/{dojangId}`; tap → `GET /api/NewStudent/application/{id}`; enroll → web hand-off |
| Trial Members | statistics + `GET /api/TrialMember/students/{dojangId}?category=7 days trial` and `…=30 days trial` |
| Push received | refresh the relevant list; append to local history |
| App resume | refresh visible tab; re-register the device token if stale |
| Logout | `POST /api/Notification/delete-device` → wipe secure storage |

Refresh cadence: on push, on resume, on pull-to-refresh. No periodic polling.

## 6. Server-side work we will do before the vendor starts (tracked)

1. Restrict `POST /api/Auth/login` for the mobile app to master accounts (role gate) and put `TrialMember/statistics` behind auth.
2. Add `type` and `entityId` to the FCM data payload.
3. Fix the "current students includes the master" off-by-one at the source.
4. Provide UAT API URL and a UAT master account.

## 7. Known discrepancies in the current app (for reference only)

- `?userId=` query parameters sent by the old app are ignored by the server.
- The old Android build sends `register-device` in camelCase without `deviceInfo`; both casings bind.
- `functions/index.js` (Firebase Cloud Function) is orphaned: it reads a Firestore collection the app never writes and uses the retired `sendToDevice` API. Ignore it.
- Local "offline cache" for applications was read but never written.
- Seven working endpoints were never called (`refresh-token`, `enroll`, `mark-notified`, `check-updates`, `history`, `delete-device`, `acknowledge`).
