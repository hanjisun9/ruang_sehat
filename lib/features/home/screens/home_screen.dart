import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruang_sehat/features/articles/providers/articles_provider.dart';
import 'package:ruang_sehat/features/home/widgets/featured_card.dart';
import 'package:ruang_sehat/features/home/widgets/recommend_card.dart';
import 'package:ruang_sehat/theme/app_colors.dart';
import 'package:ruang_sehat/widgets/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:ruang_sehat/features/auth/providers/auth_providers.dart';
import 'package:ruang_sehat/utils/snackbar_helper.dart';
import 'package:ruang_sehat/features/auth/presentation/screens/auth_screen.dart';
import 'package:ruang_sehat/features/articles/providers/articles_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticlesProvider>().getArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const SizedBox.square(
                dimension: 44,
                child: Image(
                  image: AssetImage('assets/images/nana.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProviders>(
                  builder: (context, provider, _) {
                    return Text(
                      'Hi, ${provider.profile?.name ?? 'user'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                Text(
                  'How are you feeling today ?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, size: 28),
              offset: const Offset(0, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              color: AppColors.secondary,
              onSelected: (value) {
                ModalBottomSheet.show(
                  context: context,
                  label: 'Are you sure you want to log out?',
                  isLogout: true,
                  onConfirm: () async {
                    final authProvider = context.read<AuthProviders>();
                    await authProvider.logout();

                    if (authProvider.errorMessage == null) {
                      SnackbarHelper.show(
                        context,
                        message: authProvider.successMessage ?? 'succes',
                        isError: false,
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AuthScreen.routeName,
                        (route) => false,
                      );
                    } else {
                      SnackbarHelper.show(
                        context,
                        message: authProvider.errorMessage ?? 'error',
                        isError: true,
                      );
                    }
                  },
                );
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification:  (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            final provider = context.read<ArticlesProvider>();

            if (!provider.isFetchingMore && provider.hasNextPage) {
              provider.getArticles(isRefresh: false);
            }
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: _FeaturedHeader(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 16),
                child: FeaturedCard(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _RecommendHeader(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: RecommendCard(),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedHeader extends StatelessWidget {
  const _FeaturedHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Featured',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Text(
          'See More >',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.hintText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecommendHeader extends StatelessWidget {
  const _RecommendHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Recomended for you',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Text(
          'See More >',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.hintText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
