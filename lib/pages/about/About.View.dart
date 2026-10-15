import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/product.dart';
import 'About.Ctrl.dart';
import 'About.Data.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const _controller = AboutCtrl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: SeeraColors.pinkDeep,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => RM.navigate.back(),
        ),
        title: const Text(
          'Tentang Seera',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _StoryNote()),
                            const SizedBox(width: 22),
                            const SizedBox(width: 330, child: _Polaroid()),
                          ],
                        )
                      else ...[
                        _StoryNote(),
                        const SizedBox(height: 18),
                        const _Polaroid(),
                      ],
                      const SizedBox(height: 22),
                      const _ValuesSection(),
                      const SizedBox(height: 22),
                      _SocialSection(
                        onChannelTap: (channel, handle) => _controller.showChannel(context, channel, handle),
                      ),
                      const SizedBox(height: 22),
                      _PolicySection(onBuyers: () => _controller.openBuyers(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StoryNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        border: Border.all(color: const Color(0xFFE9D987)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: SeeraColors.pinkDeep),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'CERITA KECIL DARI SEERA',
                  style: TextStyle(
                    color: SeeraColors.pinkDeep,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aksesori ceria, dirangkai dengan hati.',
            style: TextStyle(color: SeeraColors.ink, fontSize: 25, height: 1.15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(aboutStory, style: const TextStyle(color: SeeraColors.ink, fontSize: 14, height: 1.65)),
        ],
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  const _Polaroid();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.025,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 225,
              width: double.infinity,
              child: ProductArtwork(product: _aboutStoryProduct, large: true),
            ),
            const SizedBox(height: 12),
            Text(
              'Dirangkai satu per satu ♡',
              style: TextStyle(
                color: SeeraColors.ink,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _aboutStoryProduct = Product(
  name: 'Aksesori Seera',
  price: 0,
  colors: [SeeraColors.pinkPop, SeeraColors.lemon, SeeraColors.lilac],
  description: 'Ilustrasi aksesori Seera.',
);

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Hal yang kami percaya',
          subtitle: 'Keceriaan kecil yang dibuat dengan perhatian.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: aboutValues.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: constraints.maxWidth >= 700 ? 116 : 150,
              ),
              itemBuilder: (context, index) {
                final value = aboutValues[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: SeeraColors.pinkSoft),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.$1,
                        style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 7),
                      Text(value.$2, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12, height: 1.4)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.onChannelTap});

  final void Function(String channel, String handle) onChannelTap;

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.camera_alt_outlined, Icons.play_circle_outline, Icons.storefront_outlined];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: SeeraColors.pinkSoft, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(title: 'Temukan Seera', subtitle: 'Ikuti kabar koleksi dan cerita terbaru kami.'),
          const SizedBox(height: 12),
          OnFormSubmissionBuilder(
            listenTo: aboutSocialActionForm,
            onSubmitting: () => const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: SeeraColors.pinkDeep),
                ),
                SizedBox(width: 10),
                Text('Membuka kanal Seera...'),
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < aboutSocialChannels.length; index++)
                  ActionChip(
                    avatar: Icon(icons[index], size: 18, color: SeeraColors.pinkDeep),
                    label: Text('${aboutSocialChannels[index].$1} · ${aboutSocialChannels[index].$2}'),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    onPressed: () => onChannelTap(aboutSocialChannels[index].$1, aboutSocialChannels[index].$2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.onBuyers});

  final VoidCallback onBuyers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Kebijakan Privasi & Syarat',
          subtitle: 'Informasi yang jelas untuk pengalaman belanja yang nyaman.',
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => Column(
            children: [
              for (final section in aboutPolicySections.state) ...[
                _PolicyTile(section: section),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OnFormSubmissionBuilder(
            listenTo: aboutBuyerNavigationForm,
            onSubmitting: () => TextButton.icon(
              onPressed: null,
              icon: SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2, color: SeeraColors.pinkDeep),
              ),
              label: Text('Membuka halaman pembeli'),
            ),
            child: TextButton.icon(
              onPressed: onBuyers,
              icon: const Icon(Icons.people_outline),
              label: const Text('Lihat Pembeli Seera'),
              style: TextButton.styleFrom(foregroundColor: SeeraColors.pinkDeep),
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({required this.section});

  final AboutPolicySection section;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        iconColor: SeeraColors.pinkDeep,
        collapsedIconColor: SeeraColors.greyMauve,
        title: Text(
          section.title,
          style: const TextStyle(color: SeeraColors.ink, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.body, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 13, height: 1.55)),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: SeeraColors.ink, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
      ],
    );
  }
}
