/// A reward granted to the user for engaging with a rewarded ad.
class RewardItem {
  /// Creates a [RewardItem].
  const RewardItem({required this.amount, required this.type});

  /// Builds a [RewardItem] from a native map payload.
  factory RewardItem.fromMap(Map<dynamic, dynamic> map) {
    return RewardItem(
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      type: map['type'] as String? ?? '',
    );
  }

  /// The reward amount.
  final int amount;

  /// The reward type/label.
  final String type;

  @override
  String toString() => 'RewardItem(amount: $amount, type: $type)';
}

/// Callback invoked when the user earns a reward.
typedef OnUserEarnedReward = void Function(RewardItem reward);
