# ShopDekho — Customer App (Flutter)

Yeh app aapki existing website (`index.html` + `s/index.html`) ka Flutter port hai —
same Cloudflare Worker APIs, same JSON data structure, same UI flow, bas native app me.

## Kya-kya banaya gaya hai

- **Home** → Nearby Shops / Scan QR / Search by Shop ID
- **Nearby Shops** → GPS se location, 10km radius filter (Haversine — same formula jo website me hai)
- **QR Scanner** → sirf `https://shopdekho.the-web.top/s/{SHOPID}` format accept karta hai
- **Search by Shop ID**
- **Shop Detail** → banner, rating, open/closed status (live calculate hota hai openTime/closeTime se), call/directions, info grid
- **Product List** → grid/list toggle, category chips, quantity selector (preset dropdown + custom quantity dialog — weight ke liye g/kg, piece items ke liye count)
- **Cart / Bill Summary** → subtotal, ₹100+ pe ₹10 discount, "Show to Shopkeeper" popup, Share/Save bill

Koi bhi Worker code touch nahi kiya — sirf wahi 2 Workers call kiye jo aapne diye:
- `shopdekho-customer-discovery.quizpulse-com.workers.dev` (nearby + search by ID)
- `shopdekho-customer-worker.quizpulse-com.workers.dev/website` (shop/product/master JSON)

Ye URLs `lib/services/api_config.dart` me ek jagah rakhe hain — agar kabhi Worker URL change ho, bas yahi file edit karni hai.

## Setup (pehli baar)

Ye sirf Dart/Flutter source files (`lib/` folder) hain — Android/iOS platform folders khud generate karne honge, kyunki wo `flutter create` command se banate hain jo sirf aapke local machine pe chalega (mujhe Flutter SDK / pub.dev access nahi hai is sandbox me).

1. Apne computer pe [Flutter SDK install](https://docs.flutter.dev/get-started/install) karo (agar pehle se nahi hai)
2. Is `shopdekho_customer` folder ko kisi bhi jagah rakho, phir terminal me:
   ```
   cd shopdekho_customer
   flutter create --org com.shopdekho --project-name shopdekho_customer .
   ```
   Ye command `android/`, `ios/`, aur baaki platform folders generate karega — humara `lib/` folder aur `pubspec.yaml` overwrite nahi honge (agar pooche to "No" mat karna sirf lib/pubspec ke liye, baaki ke liye "Yes" chalega — practically ye command sirf missing platform folders hi banata hai, existing `lib/` ko touch nahi karta)
3. Dependencies install karo:
   ```
   flutter pub get
   ```

## Permissions add karna (zaroori)

**Android** — `android/app/src/main/AndroidManifest.xml` me `<application>` tag ke **upar** ye lines add karo:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS** — `ios/Runner/Info.plist` me `<dict>` ke andar ye add karo:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ShopDekho aapke paas ki dukaanein dikhane ke liye location use karta hai.</string>
<key>NSCameraUsageDescription</key>
<string>ShopDekho QR code scan karne ke liye camera use karta hai.</string>
```

## Run karna

```
flutter run
```

## App structure

```
lib/
  main.dart                    — app entry point
  theme/app_theme.dart         — website jaise hi colors/fonts
  models/
    shop.dart                  — shops/{city}/{shopId}.json
    product.dart                — master/products.json + inventory merge
  services/
    api_config.dart            — Worker URLs (yahi ek jagah change karo agar URL badle)
    api_service.dart           — sab HTTP calls
    location_service.dart      — GPS + distance calculation
    cart_model.dart            — cart state + bill calculation
    qty_helper.dart            — quantity presets (g/kg/piece) — website jaisa hi
  screens/
    home_screen.dart
    nearby_screen.dart
    search_screen.dart
    qr_scanner_screen.dart
    shop_screen.dart           — shop landing page
    products_screen.dart       — product list + qty selector
    cart_screen.dart           — bill + shopkeeper modal
```

## Aage Merchant App ke liye

Jab bhi merchant app banana ho, bataiyega — same pattern follow karenge:
merchant login/register (Firestore), dashboard, aur products add/update
karne ka form jo private-repo JSON update karta hai (Worker ke through).
