import 'package:flutter/material.dart';

import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';

/// Horizontal interactive bar highlighting top student hangout/shopping spots
/// (Cascavelle, Timo, Campus Tuck Shop, etc.).
/// Tapping a spot filters the feed or opens quick-log for that merchant.
/// Directly establishes the data foundation for the V2 student marketplace.
class MerchantSpotsBar extends StatelessWidget {
  const MerchantSpotsBar({
    super.key,
    required this.merchants,
    required this.selectedFilter,
    required this.onSelectSpot,
  });

  final List<MerchantSpot> merchants;
  final String? selectedFilter;
  final ValueChanged<String?> onSelectSpot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, size: 16, color: FvColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'STUDENT SPOTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: FvColors.ink,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD97706), width: 1),
                ),
                child: const Text(
                  'V2 MARKETPLACE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: merchants.length + (selectedFilter != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (selectedFilter != null && index == 0) {
                // Clear filter chip
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onSelectSpot(null),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: FvColors.ink,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: FvColors.ink, width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.clear_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Show All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final itemIndex = selectedFilter != null ? index - 1 : index;
              final spot = merchants[itemIndex];
              final isSelected = selectedFilter?.toLowerCase() == spot.name.toLowerCase();

              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => onSelectSpot(spot.name),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? FvColors.wash : FvColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? FvColors.primary : FvColors.ink,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: FvColors.primary,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: FvColors.ink,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: FvColors.ink, width: 1),
                          ),
                          child: Text(
                            spot.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                spot.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: FvColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                spot.totalSpent > 0
                                    ? 'Rs ${spot.totalSpent.toStringAsFixed(0)} • ${spot.visitCount}x'
                                    : 'Student spot',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: FvColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
