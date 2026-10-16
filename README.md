# Seera.co_

Flutter storefront for Seera.co_ with pink locker branding.

## Run

```sh
flutter pub get
flutter run
```

The storefront reads products from `get_produk.php` and reviews from
`get_review.php`. It posts checkouts to `simpan_transaksi.php`, uploads JPG/PNG
payment proof to `upload_bukti.php`, posts reviews to `simpan_review.php`, and
exposes product/review administration through `/admin` using
`update_produk.php` and `hapus_review.php`.

The Flutter client accepts list responses as a JSON array or as a `data`,
`produk`, `review`, or `reviews` array. Product records should provide
`nama_produk` and `harga` or `harga_jual`; `id_produk` and `kode_produk` are
supported as identifiers. The client also accepts `hpp_satuan`,
`gambar_produk`, and other common aliases. Review records should provide an
ID, customer name (`nama_customer` is supported), review text, and rating.

Override the API origin when running or building against a different backend:

```powershell
flutter run --dart-define=SEERA_API_BASE_URL=https://api.example.com/
```

The transaction endpoint receives form-encoded customer details, subtotal,
`ongkir`, unique code, total, and an `items` field containing a JSON array. Its
success response must return an order identifier such as `kode_pesanan` or
`order_code`. Payment proof uploads
use multipart field `bukti` and include `kode_pesanan` and `status=Proses`.
Product edits use multipart field `gambar`; review deletion sends `id_review`.
The bank name, account number, and account holder can be supplied at build time:

```powershell
flutter run --dart-define=SEERA_BANK_NAME=BCA `
  --dart-define=SEERA_BANK_ACCOUNT=YOUR_ACCOUNT_NUMBER `
  --dart-define=SEERA_BANK_HOLDER=Seera.co_
```

`assets/images/qris.jpeg` is the default QRIS image. The logo is read from
`assets/images/logo.jpg`.

## Backend requirements still needed

The supplied API list does not include endpoints/contracts for admin order
listing and status/refund updates, dashboard metrics and external sales,
persisted bank/QRIS settings, customer order lookup, or the public buyer
listing. Those sections are deliberately left without fabricated data.
Product creation is also not exposed by the supplied `update_produk.php`
contract. The admin endpoints must enforce authentication/authorization on the
server; a hidden Flutter route is not an access-control boundary.

The current `seeraco.kesug.com` host serves a JavaScript/cookie challenge
instead of JSON to HTTP clients, and its API responses do not include
`Access-Control-Allow-Origin`. This makes browser `fetch` fail even though the
same URL can show data after being opened directly in a browser. Configure the
hosting/WAF to skip that challenge for the PHP API endpoints and return JSON
directly. Also configure every endpoint (including `OPTIONS` preflight) to
allow the exact storefront origin, `GET, POST, OPTIONS`, and the request
headers used by the client. Flutter Web cannot add response-side CORS headers
or execute an HTML challenge returned in place of API JSON. Deploy the API over
HTTPS; the app now reports this server issue explicitly instead of showing only
a generic fetch exception.
