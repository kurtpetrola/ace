import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class CommonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hintText;
  final String? statusText;
  final bool isError;
  final ValueChanged<String>? onChanged;

  const CommonSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search...',
    this.statusText,
    this.isError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: hintText,
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: onSearch,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ColorPalette.primary, width: 2),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          if (statusText != null) ...[
            const SizedBox(height: 6),
            Text(
              statusText!,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isError ? Colors.red : Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
