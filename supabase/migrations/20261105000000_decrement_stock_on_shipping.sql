BEGIN;

ALTER TABLE public."Penjualan"
  ADD COLUMN IF NOT EXISTS stok_dikurangi boolean NOT NULL DEFAULT false;

UPDATE public."Penjualan"
SET stok_dikurangi = true
WHERE status = 'Dikirim'
  AND stok_dikurangi = false;

CREATE OR REPLACE FUNCTION public.decrement_product_stock_when_shipped()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_item record;
  v_item_count integer := 0;
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status
     AND NEW.status = 'Dikirim'
     AND NOT NEW.stok_dikurangi THEN
    FOR v_item IN
      SELECT
        detail.kode_produk,
        SUM(detail.jumlah) AS jumlah
      FROM public."Detail_Penjualan" AS detail
      WHERE detail.id_transaksi = NEW.id_transaksi
      GROUP BY detail.kode_produk
    LOOP
      IF v_item.jumlah IS NULL OR v_item.jumlah <= 0 THEN
        RAISE EXCEPTION 'Jumlah produk pada pesanan % tidak valid.',
          NEW.id_transaksi;
      END IF;

      UPDATE public."Produk"
      SET stok = stok - v_item.jumlah
      WHERE kode_produk = v_item.kode_produk
        AND stok >= v_item.jumlah;

      IF NOT FOUND THEN
        RAISE EXCEPTION
          'Stok produk % tidak cukup untuk mengirim pesanan %.',
          v_item.kode_produk,
          NEW.id_transaksi;
      END IF;

      v_item_count := v_item_count + 1;
    END LOOP;

    IF v_item_count = 0 THEN
      RAISE EXCEPTION 'Pesanan % tidak memiliki barang untuk dikirim.',
        NEW.id_transaksi;
    END IF;

    NEW.stok_dikurangi := true;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS decrement_product_stock_on_shipping
  ON public."Penjualan";

CREATE TRIGGER decrement_product_stock_on_shipping
BEFORE UPDATE OF status ON public."Penjualan"
FOR EACH ROW
EXECUTE FUNCTION public.decrement_product_stock_when_shipped();

COMMIT;
