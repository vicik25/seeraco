import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import 'Buyers.Ctrl.dart';
import 'Buyers.Data.dart';

class BuyersView extends StatelessWidget {
  const BuyersView({super.key});

  static const _controller = BuyersCtrl();

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
          'Pembeli Seera',
          style: TextStyle(
            color: SeeraColors.pinkDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          OnFormSubmissionBuilder(
            listenTo: openAboutFromBuyersForm,
            onSubmitting: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SeeraColors.pinkDeep,
                  ),
                ),
              ),
            ),
            child: IconButton(
              tooltip: 'Tentang Seera',
              onPressed: () => _controller.openAbout(context),
              icon: const Icon(Icons.info_outline),
              color: SeeraColors.pinkDeep,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _BuyersBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: OnReactive(() {
                      final profiles = seeraBuyers.state
                          .take(visibleBuyerCount.state)
                          .toList();
                      if (profiles.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Text(
                            'Data pembeli belum tersedia.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: SeeraColors.greyMauve),
                          ),
                        );
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 850
                              ? 3
                              : constraints.maxWidth >= 560
                              ? 2
                              : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: profiles.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 186,
                                ),
                            itemBuilder: (context, index) =>
                                _BuyerCard(profile: profiles[index]),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: OnReactive(() {
                      if (seeraBuyers.state.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (visibleBuyerCount.state >= seeraBuyers.state.length) {
                        return const Center(
                          child: Text(
                            'Kamu sudah melihat semua cerita pembeli terbaru.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: SeeraColors.greyMauve),
                          ),
                        );
                      }
                      return Center(
                        child: OnFormSubmissionBuilder(
                          listenTo: loadMoreBuyersForm,
                          onSubmitting: () =>
                              const _LoadMoreButton(isLoading: true),
                          child: _LoadMoreButton(
                            onPressed: _controller.loadMore,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyersBanner extends StatelessWidget {
  const _BuyersBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: SeeraColors.pinkLocker,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final content = Column(
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pembeli Seera',
                    textAlign: compact ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                      color: SeeraColors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Terima kasih sudah jadi bagian dari Seera!',
                    textAlign: compact ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                      color: SeeraColors.ink,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Cerita pembeli akan ditampilkan setelah data tersedia.',
                    style: TextStyle(color: SeeraColors.ink, fontSize: 12),
                  ),
                ],
              );

              return content;
            },
          ),
        ),
      ),
    );
  }
}

class _BuyerCard extends StatelessWidget {
  const _BuyerCard({required this.profile});

  final BuyerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: profile.avatarColor,
            child: Icon(
              profile.isAnonymous ? Icons.person_outline : Icons.face_3_rounded,
              color: profile.isAnonymous
                  ? SeeraColors.greyMauve
                  : SeeraColors.ink,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SeeraColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  profile.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SeeraColors.pinkDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: SeeraColors.greyMauve,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.city,
                        style: const TextStyle(
                          color: SeeraColors.greyMauve,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      profile.date,
                      style: const TextStyle(
                        color: SeeraColors.greyMauve,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SeeraColors.pinkDeep,
              ),
            )
          : const Icon(Icons.expand_more),
      label: Text(isLoading ? 'Memuat pembeli' : 'Muat lebih banyak'),
      style: OutlinedButton.styleFrom(
        foregroundColor: SeeraColors.pinkDeep,
        side: const BorderSide(color: SeeraColors.pinkPop, width: 1.5),
        minimumSize: const Size(210, 48),
        shape: const StadiumBorder(),
      ),
    );
  }
}
