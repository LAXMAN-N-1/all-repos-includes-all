# 🚀 Google Play Store Deployment Checklist - Evination

This checklist provides a comprehensive roadmap for deploying the **Evination Customer, Vendor, and Admin/Logistic** applications to the Google Play Store for testing and full release.

---

## 🛠️ Phase 1: Application Configuration & Branding

### 1.1 Platform Initialization (If missing)
- [x] **Customer App**: Already has Android platform.
- [ ] **Vendor App**: Run `flutter create --platforms android .` in `frontend-vendor/`.
- [ ] **Admin/Logistic App**: Run `flutter create --platforms android .` in `frontend-admin/`.

### 1.2 Package Name Verification
- [ ] **Customer App**: `com.evination.customer.evination_customer_app` (Verify in `android/app/build.gradle.kts`)
- [ ] **Vendor App**: Set a unique ID (e.g., `com.evination.vendor`) during initialization or in Gradle.
- [ ] **Admin/Logistic App**: Set a unique ID (e.g., `com.evination.admin`) during initialization or in Gradle.
    > [!IMPORTANT]
    > Package names (Application IDs) cannot be changed once the app is uploaded to the Play Store. Ensure they follow the `com.company.app` format.

### 1.3 App Naming & Versioning
- [ ] Set "User Friendly" names in `AndroidManifest.xml` (`android:label`).
- [ ] Update labels for all 3 apps:
    - Customer: `Evination`
    - Vendor: `Evination Vendor`
    - Admin: `Evination Admin`
- [ ] Set initial versioning in `pubspec.yaml`: `version: 1.0.0+1`.
    - `1.0.0` is the **Version Name** (Visible to users).
    - `1` is the **Version Code** (Must increase with every upload).

### 1.4 App Icons & Splash Screens
- [ ] **App Icons**: Generate adaptive icons (1024x1024px) for all apps.
    - [ ] Foreground & Background layers.
    - [ ] Legacy round/square icons.
- [ ] **Splash Screens**: Configure Flutter/Native splash screens to match branding.

---

## 🔐 Phase 2: Security & Signing (Crucial)

### 2.1 Generate Release Keystores
- [ ] Generate a unique `.jks` file for **each app** (recommended) or one common key.
- [ ] **Command**: `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release`
    > [!CAUTION]
    > **NEVER LOSE YOUR KEYSTORE FILE OR PASSWORD.** If lost, you cannot update your apps. Back them up in a secure vault (e.g., 1Password, Bitwarden).

### 2.2 Configure Gradle Signing
- [ ] Create `key.properties` (exclude from Git!) in each `android` folder.
- [ ] Update `android/app/build.gradle.kts` to reference the signing config:
    ```kotlin
    signingConfigs {
        create("release") {
            keyAlias = properties["keyAlias"] as String
            keyPassword = properties["keyPassword"] as String
            storeFile = file(properties["storeFile"] as String)
            storePassword = properties["storePassword"] as String
        }
    }
    ```

### 2.3 Proguard / R8 (Obfuscation)
- [ ] Ensure `minifyEnabled true` and `shrinkResources true` are set in release builds to protect code and reduce app size.

---

## 🎨 Phase 3: Play Store Listing Assets

### 3.1 Metadata (For each of the 3 apps)
- [ ] **App Title**: Max 30 chars.
- [ ] **Short Description**: Max 80 chars.
- [ ] **Full Description**: Max 4000 chars.
- [ ] **Category**: (e.g., Shopping, Business, Tools).
- [ ] **Contact Details**: Support email, website.

### 3.2 Visuals (Per app)
- [ ] **Feature Graphic**: 1024x500px (Crucial for Play Store promotion).
- [ ] **Phone Screenshots**: 4-8 screenshots (1242x2208px or 1242x2688px).
- [ ] **7" Tablet Screenshots**: 1-8 screenshots.
- [ ] **10" Tablet Screenshots**: 1-8 screenshots.

---

## 🏛️ Phase 4: Google Play Console Setup

### 4.1 Account & Permissions
- [ ] Ensure Google Play Developer Account is active ($25 one-time fee).
- [ ] Link apps to the developer console.

### 4.2 Legal & Policies
- [ ] **Privacy Policy**: Host a privacy policy URL for each app.
- [ ] **App Content Declarations**:
    - [ ] Ads (Yes/No).
    - [ ] Content Rating (Questionnaire).
    - [ ] Target Audience (Ages).
    - [ ] Data Safety (Declare what data you collect: Profile, Location, etc.).

### 4.3 Testing Tracks
- [ ] **Internal Testing**: Up to 100 testers. Immediate availability.
- [ ] **Closed Testing**: Release to a specific group (Alpha). Requires Google review.
- [ ] **Open Testing**: Public Beta.

---

## 🚀 Phase 5: The Deployment Workflow

1. **Clean Project**: `flutter clean`
2. **Get Dependencies**: `flutter pub get`
3. **Build Bundle**: `flutter build appbundle` (Builds `.aab` for Play Store).
4. **Upload**: Drag & Drop the `.aab` file from `build/app/outputs/bundle/release/` to the Play Console.
5. **Rollout**: Start rollout to Internal Testing for initial validation.

---

## 📝 App-Specific Notes

| Feature | Customer App | Vendor App | Admin App |
| :--- | :--- | :--- | :--- |
| **Primary Goal** | Booking & Payment | Managing Bids | Ops Management |
| **Critical SDKs** | Razorpay, Geolocator | Notifications | Maps/Tracking |
| **Target Track** | Internal Testing | Internal Testing | Internal Testing |

---
*Created on: 2026-01-28*
