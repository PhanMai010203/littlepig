import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sheep_premium_background.dart';
import '../widgets/sheep_pro_banner.dart';

class SheepPremiumPage extends StatelessWidget {
  const SheepPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated background with blob effects
          const SheepPremiumBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                
                // Premium content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header section
                        Column(
                          children: [
                            const SheepProBanner(large: true),
                            const SizedBox(height: 4),
                            Text(
                              'Budget like a pro with Sheep Pro',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Features section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              _PremiumFeature(
                                icon: Icons.favorite,
                                title: 'Support the Developer',
                                description: 'Help support continued development and new features',
                              ),
                              _PremiumFeature(
                                icon: Icons.donut_small,
                                title: 'Unlimited Budgets & Goals',
                                description: 'Create as many budgets and financial goals as you need',
                              ),
                              _PremiumFeature(
                                icon: Icons.history,
                                title: 'Past Budget Periods',
                                description: 'View and analyze your historical budget data',
                              ),
                              _PremiumFeature(
                                icon: Icons.color_lens,
                                title: 'Unlimited Color Picker',
                                description: 'Customize your budget categories with any color',
                              ),
                              _PremiumFeature(
                                icon: Icons.analytics,
                                title: 'Advanced Analytics',
                                description: 'Get detailed insights into your spending patterns',
                              ),
                              _PremiumFeature(
                                icon: Icons.sync,
                                title: 'Premium Sync Features',
                                description: 'Enhanced cloud synchronization capabilities',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Subscription options
                        _SubscriptionOptions(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
  
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 23,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SubscriptionOption(
            label: 'Yearly',
            price: '\$19.99',
            originalPrice: '\$59.88',
            onTap: () => _showPurchaseDialog(context, 'Yearly'),
            extraPadding: const EdgeInsets.only(top: 6.5),
          ),
          _SubscriptionOption(
            label: 'Monthly',
            price: '\$4.99',
            onTap: () => _showPurchaseDialog(context, 'Monthly'),
          ),
          _SubscriptionOption(
            label: 'Lifetime',
            price: '\$49.99',
            onTap: () => _showPurchaseDialog(context, 'Lifetime'),
            extraPadding: const EdgeInsets.only(bottom: 6.5),
          ),
        ],
      ),
    );
  }
  
  void _showPurchaseDialog(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$plan Purchase'),
        content: Text('This is a demo. In a real app, this would initiate the $plan purchase flow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatelessWidget {
  const _SubscriptionOption({
    required this.label,
    required this.price,
    this.originalPrice,
    required this.onTap,
    this.extraPadding,
  });
  
  final String label;
  final String price;
  final String? originalPrice;
  final VoidCallback onTap;
  final EdgeInsets? extraPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: extraPadding ?? EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (originalPrice != null)
                    Text(
                      originalPrice!,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Colors.black.withOpacity(0.65),
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}