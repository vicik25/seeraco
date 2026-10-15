import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import 'Checkout.Ctrl.dart';
import 'Checkout.Data.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  static const _controller = CheckoutCtrl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Checkout',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
      ),
      // MENGGUNAKAN LISTVIEW LANGSUNG AGAR AMAN DARI UNBOUNDED HEIGHT DI WEB
      body: Center(
        child: SizedBox(
          width: 800, // Membatasi lebar agar rapi di web
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // --- FORM PENERIMA ---
              const Text(
                'Data Penerima',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SeeraColors.ink),
              ),
              const SizedBox(height: 16),
              OnReactive(
                () => TextField(
                  controller: TextEditingController(text: checkoutName.state)
                    ..selection = TextSelection.collapsed(offset: checkoutName.state.length),
                  onChanged: _controller.updateName,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OnReactive(
                () => TextField(
                  controller: TextEditingController(text: checkoutWhatsapp.state)
                    ..selection = TextSelection.collapsed(offset: checkoutWhatsapp.state.length),
                  onChanged: _controller.updateWhatsapp,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp',
                    prefixText: '+62 ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OnReactive(
                () => TextField(
                  controller: TextEditingController(text: checkoutAddress.state)
                    ..selection = TextSelection.collapsed(offset: checkoutAddress.state.length),
                  onChanged: _controller.updateAddress,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // --- RINGKASAN BAYAR ---
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SeeraColors.ink),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SeeraColors.pinkSoft),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Subtotal'), Text('Rp50.000')], // Dummy sementara
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Rp50.000',
                          style: TextStyle(fontWeight: FontWeight.bold, color: SeeraColors.pinkPop),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SeeraColors.pinkPop),
            onPressed: () => _controller.submit(context),
            child: const Text(
              'Buat Pesanan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
