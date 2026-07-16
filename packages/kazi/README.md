<h1>Kazi</h1>

<h2 align="center">Topics 📋</h2>

   <p>
   
   - [About 📖](#About-)
   - [How to use 🤔](#How-to-use-)

   </p>

---

<h2 align="center">About 📖</h2>
   
<p>
  Kazi is an app to keep track of your personal or work services. For example, if you are a hairdresser, you can register and track all hair styles that you have done in that day.
</p>

---

<h2 align="center">How to use🤔</h2>

<p>
    You can download it to use <a href="https://github.com/lucas-242/Kazi/releases/">here</a> or you can clone the repository and create your own project on Firebase.
</p>

   1. Clone this repository:
   ```
   $ git clone https://github.com/lucas-242/Kazi
   ```

   2. Enter in the directory:
   ```
   $ cd Kazi
   ```

   3. Generate your keys in the project android/app folder
   ```
   $ keytool -genkey -v -keystore \android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   4. Create and configure a firebase project to use Firestore Database and Google Authentication.
   Make sure to use the flutterfire cli to generate the firebase_options.dart and firebase_options_staging.dart files in lib folder.
   ```
   $ flutterfire config
   ```

   5. Place the google-services.json files in the correct Android flavor folders:
   - For staging: `android/app/src/staging/google-services.json`
   - For prod: `android/app/src/prod/google-services.json`

   6. Create environment configuration files (.env files) in the project root:
   - `.env.staging` - Configuration for staging environment
   - `.env.prod` - Configuration for production environment
   - `.env.prod_test` - Configuration for testing prod with staging ads

   Each env file should contain:
   ```
   # Ad Keys
   TEST_DEVICE_IDS=your_test_device_id
   SERVICE_CREATE_ANDROID=your_android_ad_unit_id
   SERVICE_CREATE_IOS=your_ios_ad_unit_id
   SERVICE_LIST_ANDROID=your_android_ad_unit_id
   SERVICE_LIST_IOS=your_ios_ad_unit_id

   # Google Server Client Id
   GOOGLE_SERVER_CLIENT_ID=your_server_client_id
   ```

   7. Add your adMob app id in the android/key.properties
   ```
   adMobAppId.debug=ca-app-pub-3940256099942544~3347511713
   adMobAppId.release=ca-app-pub-xxxxx~xxxxx
   ```

   8. Add metadata in Android/app/src/main/AndroidManifest
   ```
   <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="@string/ADMOB_APPID"/>
   ```

   9. Install the dependencies.
   ```
   $ flutter pub get
   ```

   10. Run the app with the desired flavor:
   ```
   # Staging
   $ flutter run --dart-define="APP_ENV=staging" --flavor staging

   # Production
   $ flutter run --dart-define="APP_ENV=prod" --flavor prod

   # Production test (prod config with staging ads)
   $ flutter run --dart-define="APP_ENV=prod_test" --flavor prod
   ```
