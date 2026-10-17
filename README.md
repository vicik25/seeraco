# Seera.co_

Flutter storefront and admin panel backed by Supabase.

## Run

```powershell
flutter pub get
flutter run
```

Supabase is initialized in `lib/main.dart`. The client uses the project's
publishable key, which is intended for client applications; never replace it
with a `service_role` secret. Configure Row Level Security (RLS) and Storage
policies in Supabase before enabling production writes.

## Supabase tables and data mapping

- `Produk`: customer screens query rows with `status_tampil = true`.
  Product data maps `kode_produk`, `nama_produk`, `kategori`, `deskripsi`,
  `harga_jual`, `hpp_satuan`, `penanda`, `gambar`, and `stok`.
- `Penjualan`: checkout inserts customer/address/contact fields, `ongkir`,
  `kode_unik`, `total_bayar`, and initial `status`. The returned
  `id_transaksi` is the order code used by payment and tracking.
- `Detail_Penjualan`: rows use `id` as the foreign key to `Penjualan.id_transaksi`,
  plus `kode_produk` and `jumlah`.
- `Review`: reads and writes `id_transaksi`, `nama_customer`, `rating`, and
  `komentar`. Customer reviews can be submitted without an `id_transaksi`;
  reviews written from a completed order may include it. The current table has
  no product-name column.
- `Pengaturan`: row `id = 1` stores `nama_bank`, `nomor_rekening`, and
  `qris_url`. The admin settings page updates bank details and uploads QRIS
  images into the `uploads` Storage bucket. Customer payment reads the same
  row and falls back to the bundled QRIS asset if no URL is configured.

The current database schema does not expose a checkout note, item variant,
line-item price/subtotal, or order subtotal column. Those values cannot be
persisted by this client without a matching database migration. The application
does not fabricate those fields or send unknown columns.

## Storage

Product images and payment proof files are uploaded to the `uploads` bucket.
The current client stores the bucket's public URL in `Produk.gambar` and
`Penjualan.bukti_bayar`; configure the bucket as public and add Storage upload
policies for the intended roles if using this setup. Public buckets make every
object URL readable by anyone who has it. For production payment receipts,
prefer a separate private bucket and signed-URL/server-function flow instead
of making receipts public.

## Admin access and security

The current `/admin` form checks `username` and `password` against the `Users`
table and stores only the matching user's non-password fields in in-memory
client state. This is a UI session, not Supabase authentication. Do not store
plaintext passwords or add an anonymous `SELECT` policy that exposes the
`Users` table to make this login work. Prefer Supabase Auth with admin roles in
trusted JWT `app_metadata`, or a server-side RPC/Edge Function that verifies
hashed credentials and issues a properly scoped session. Until then, the
client-side admin state is not an authorization boundary and admin operations
still need valid RLS policies; do not create broad anonymous `UPDATE`/`DELETE`
policies on orders, products, or reviews.

Customer checkout and review inserts must be allowed by narrowly scoped RLS
policies. Proof upload and the `Penjualan` status update must also be scoped to
the owner of that order. Since this storefront has no customer authentication,
do not authorize order updates based only on an ID supplied by the client;
use an Edge Function/RPC that verifies the order ID together with the
customer's WhatsApp number before updating `bukti_bayar` and status. Configure
the `uploads` Storage policies to match the same access model.

The configured project currently returns no rows from `Produk`,
`Penjualan`, and `Detail_Penjualan`; `Review` has records. Populate the Supabase
product table and configure policies before expecting products or admin data
to appear. Empty tables are shown as empty states rather than replaced with
sample data.

## Branding

The local logo is `assets/logo.jpg` and the default QRIS is
`assets/images/qris.jpeg`. Both are bundled with the app.
