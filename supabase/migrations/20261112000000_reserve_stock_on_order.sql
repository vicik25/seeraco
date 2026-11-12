BEGIN;

DO $$
DECLARE
  v_item record;
BEGIN
  FOR v_item IN
    SELECT
      detail.kode_produk,
      SUM(detail.jumlah) AS jumlah
    FROM public."Detail_Penjualan" AS detail
    JOIN public."Penjualan" AS sale
      ON sale.id_transaksi = detail.id_transaksi
    WHERE NOT sale.stok_dikurangi
      AND sale.status IN ('Menunggu Pembayaran', 'Proses')
    GROUP BY detail.kode_produk
  LOOP
    IF v_item.jumlah IS NULL OR v_item.jumlah <= 0 THEN
      RAISE EXCEPTION 'Jumlah produk yang dipesan tidak valid.';
    END IF;

    UPDATE public."Produk"
    SET stok = stok - v_item.jumlah
    WHERE kode_produk = v_item.kode_produk
      AND stok >= v_item.jumlah;

    IF NOT FOUND THEN
      RAISE EXCEPTION
        'Stok produk % tidak cukup untuk menyimpan pesanan yang sudah ada.',
        v_item.kode_produk;
    END IF;
  END LOOP;
END;
$$;

UPDATE public."Penjualan" AS sale
SET stok_dikurangi = true
WHERE NOT sale.stok_dikurangi
  AND sale.status IN ('Menunggu Pembayaran', 'Proses')
  AND EXISTS (
    SELECT 1
    FROM public."Detail_Penjualan" AS detail
    WHERE detail.id_transaksi = sale.id_transaksi
  );

DROP TRIGGER IF EXISTS decrement_product_stock_on_shipping
  ON public."Penjualan";
DROP FUNCTION IF EXISTS public.decrement_product_stock_when_shipped();

CREATE OR REPLACE FUNCTION public.reserve_product_stock_on_order_detail()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  IF NEW.jumlah IS NULL OR NEW.jumlah <= 0 THEN
    RAISE EXCEPTION 'Jumlah produk pada pesanan % tidak valid.',
      NEW.id_transaksi;
  END IF;

  UPDATE public."Produk"
  SET stok = stok - NEW.jumlah
  WHERE kode_produk = NEW.kode_produk
    AND stok >= NEW.jumlah;

  IF NOT FOUND THEN
    RAISE EXCEPTION
      'Stok produk % tidak cukup untuk pesanan %.',
      NEW.kode_produk,
      NEW.id_transaksi;
  END IF;

  UPDATE public."Penjualan"
  SET stok_dikurangi = true
  WHERE id_transaksi = NEW.id_transaksi
    AND NOT stok_dikurangi;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS reserve_product_stock_on_order_detail
  ON public."Detail_Penjualan";

CREATE TRIGGER reserve_product_stock_on_order_detail
AFTER INSERT ON public."Detail_Penjualan"
FOR EACH ROW
EXECUTE FUNCTION public.reserve_product_stock_on_order_detail();

COMMIT;
