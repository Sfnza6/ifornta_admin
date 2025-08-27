import 'package:flutter/material.dart';

class MostOrderedList extends StatelessWidget {
  final int period;
  final ValueChanged<int> onChange;
  final List<(int, String, String, String, String)> items;
  const MostOrderedList({
    super.key,
    required this.period,
    required this.onChange,
    required this.items,
  });

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _tabs(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الأكثر طلبًا',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(_row).toList(),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('عرض المزيد')),
        ],
      ),
    );
  }

  Widget _tabs() {
    final labels = ['شهر', 'أسبوع', 'يوم', 'الكل'];
    return Row(
      children: List.generate(4, (i) {
        final selected = i == period;
        return Padding(
          padding: EdgeInsets.only(left: i < 3 ? 8 : 0),
          child: GestureDetector(
            onTap: () => onChange(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? brown : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1D8CF)),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? Colors.white : brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _row((int, String, String, String, String) it) {
    final (rank, name, count, date, img) = it;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          title: Text(name, textAlign: TextAlign.right),
          subtitle: Text(date, textAlign: TextAlign.right),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(count, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  img,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 8),
      ],
    );
  }

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 10,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
