BEGIN;

ALTER TABLE public."Penjualan"
  ADD COLUMN IF NOT EXISTS catatan text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS tampilkan_nama_pembeli boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.public_completed_buyer_stories()
RETURNS TABLE (
  display_name text,
  product_summary text,
  purchase_date timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
  WITH completed_orders AS (
    SELECT
      sale.id_transaksi,
      sale.nama_customer,
      sale.tampilkan_nama_pembeli,
      sale.tanggal_transaksi,
      row_number() OVER (
        ORDER BY sale.tanggal_transaksi DESC, sale.id_transaksi DESC
      ) AS buyer_number
    FROM public."Penjualan" AS sale
    WHERE sale.status = 'Selesai'
  ),
  purchased_items AS (
    SELECT
      item.id_transaksi,
      string_agg(
        format('%s × %s', COALESCE(product.nama_produk, item.kode_produk), item.jumlah),
        ', '
        ORDER BY COALESCE(product.nama_produk, item.kode_produk)
      ) AS product_summary
    FROM (
      SELECT
        detail.id_transaksi,
        detail.kode_produk,
        SUM(detail.jumlah) AS jumlah
      FROM public."Detail_Penjualan" AS detail
      GROUP BY detail.id_transaksi, detail.kode_produk
    ) AS item
    LEFT JOIN public."Produk" AS product
      ON product.kode_produk = item.kode_produk
    GROUP BY item.id_transaksi
  )
  SELECT
    CASE
      WHEN sale.tampilkan_nama_pembeli
        AND NULLIF(BTRIM(sale.nama_customer), '') IS NOT NULL
      THEN (
        SELECT string_agg(
          LEFT(word, 1) || repeat('*', GREATEST(char_length(word) - 1, 0)),
          ' '
        )
        FROM regexp_split_to_table(BTRIM(sale.nama_customer), '\s+') AS words(word)
      )
      ELSE 'Pembeli Seera #' || sale.buyer_number::text
    END AS display_name,
    item.product_summary,
    sale.tanggal_transaksi AS purchase_date
  FROM completed_orders AS sale
  JOIN purchased_items AS item
    ON item.id_transaksi = sale.id_transaksi
  ORDER BY sale.tanggal_transaksi DESC, sale.id_transaksi DESC;
$$;

REVOKE ALL ON FUNCTION public.public_completed_buyer_stories() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_completed_buyer_stories()
  TO anon, authenticated;

COMMIT;
