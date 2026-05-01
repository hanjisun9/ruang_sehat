import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ruang_sehat/theme/app_colors.dart';
import 'package:ruang_sehat/features/articles/presentation/widgets/my_articles_card.dart';
import 'package:provider/provider.dart';
import 'package:ruang_sehat/features/articles/providers/articles_provider.dart';
import 'package:ruang_sehat/features/articles/presentation/screens/form_article_screen.dart';

class MyArticleScreen extends StatefulWidget {
  const MyArticleScreen({super.key});

  @override
  State<MyArticleScreen> createState() => _MyArticleScreenState();
}

class _MyArticleScreenState extends State<MyArticleScreen> {
  @override
  void initState() {
    super.initState();

    // fetch ketika halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticlesProvider>().getMyArticles();
    });
  }

  Future<void> _goToCreateArticle() async {
    await Navigator.pushNamed(
      context,
      FormArticleScreen.routeName,
      arguments: {'isEdit': false},
    );

    // refresh lagi setelah balik dari form (biar langsung muncul)
    if (!mounted) return;
    await context.read<ArticlesProvider>().getMyArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Articles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<ArticlesProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          '${provider.myArticles.length} items',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.hintText,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const MyArticlesCard(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateArticle,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
      ),
    );
  }
}