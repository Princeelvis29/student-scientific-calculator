import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'calculation_history_item.dart';
import 'calculation_history_repository.dart';

enum _HistoryMenuAction {
  clearRecent,
  clearEverything,
}

class CalculationHistoryScreen
    extends StatefulWidget {
  const CalculationHistoryScreen({
    super.key,
    required this.repository,
  });

  final CalculationHistoryRepository repository;

  @override
  State<CalculationHistoryScreen> createState() =>
      _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState
    extends State<CalculationHistoryScreen> {
  List<CalculationHistoryItem> _items =
      <CalculationHistoryItem>[];

  bool _favoritesOnly = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final List<CalculationHistoryItem> items =
        await widget.repository.load();

    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(
    CalculationHistoryItem item,
  ) async {
    await widget.repository.toggleFavorite(item.id);
    await _reload();
  }

  Future<void> _delete(
    CalculationHistoryItem item,
  ) async {
    await widget.repository.delete(item.id);
    await _reload();
  }

  Future<void> _handleMenu(
    _HistoryMenuAction action,
  ) async {
    if (action == _HistoryMenuAction.clearRecent) {
      final bool confirmed = await _confirm(
        title: 'Clear recent history?',
        message:
            'All non-favourite calculations will be deleted. '
            'Favourites will stay saved.',
        confirmLabel: 'Clear history',
      );

      if (!confirmed) return;

      await widget.repository.clearNonFavorites();
      await _reload();
      return;
    }

    final bool confirmed = await _confirm(
      title: 'Delete all history?',
      message:
          'This will permanently delete recent calculations '
          'and favourites.',
      confirmLabel: 'Delete all',
    );

    if (!confirmed) return;

    await widget.repository.clearAll();
    await _reload();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final List<CalculationHistoryItem> visible =
        _favoritesOnly
            ? _items
                .where(
                  (CalculationHistoryItem item) =>
                      item.isFavorite,
                )
                .toList()
            : _items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: <Widget>[
          PopupMenuButton<_HistoryMenuAction>(
            tooltip: 'History options',
            onSelected: _handleMenu,
            itemBuilder: (BuildContext context) =>
                const <
                    PopupMenuEntry<
                        _HistoryMenuAction>>[
              PopupMenuItem<_HistoryMenuAction>(
                value:
                    _HistoryMenuAction.clearRecent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.cleaning_services_outlined),
                  title: Text(
                    'Clear non-favourites',
                  ),
                ),
              ),
              PopupMenuItem<_HistoryMenuAction>(
                value:
                    _HistoryMenuAction.clearEverything,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.delete_forever_outlined),
                  title: Text('Delete everything'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 760),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments:
                          const <ButtonSegment<bool>>[
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.history),
                          label: Text('All'),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon:
                              Icon(Icons.star_outline),
                          label: Text('Favourites'),
                        ),
                      ],
                      selected:
                          <bool>{_favoritesOnly},
                      onSelectionChanged:
                          (Set<bool> selection) {
                        setState(() {
                          _favoritesOnly =
                              selection.first;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : visible.isEmpty
                          ? _EmptyHistory(
                              favoritesOnly:
                                  _favoritesOnly,
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                24,
                              ),
                              itemCount:
                                  visible.length,
                              separatorBuilder:
                                  (
                                    BuildContext context,
                                    int index,
                                  ) =>
                                      const SizedBox(
                                height: 10,
                              ),
                              itemBuilder:
                                  (
                                    BuildContext context,
                                    int index,
                                  ) {
                                final CalculationHistoryItem
                                    item =
                                    visible[index];

                                return _HistoryCard(
                                  item: item,
                                  onFavorite: () =>
                                      _toggleFavorite(
                                    item,
                                  ),
                                  onDelete: () =>
                                      _delete(item),
                                  onUse: () =>
                                      Navigator.pop(
                                    context,
                                    item,
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.onFavorite,
    required this.onDelete,
    required this.onUse,
  });

  final CalculationHistoryItem item;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback onUse;

  String _dateText(DateTime value) {
    final DateTime local = value.toLocal();

    String two(int number) =>
        number.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isFavorite
              ? AppTheme.equals.withOpacity(0.65)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.numberKey,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Text(
                  item.mode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _dateText(item.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
              IconButton(
                tooltip: item.isFavorite
                    ? 'Remove favourite'
                    : 'Save as favourite',
                onPressed: onFavorite,
                icon: Icon(
                  item.isFavorite
                      ? Icons.star
                      : Icons.star_border,
                  color: item.isFavorite
                      ? AppTheme.equals
                      : AppTheme.secondaryText,
                ),
              ),
            ],
          ),
          SelectableText(
            item.expression,
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: SelectableText(
                  '= ${item.result}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onUse,
                icon: const Icon(
                  Icons.replay_outlined,
                ),
                label: const Text('Use'),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    required this.favoritesOnly,
  });

  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              favoritesOnly
                  ? Icons.star_outline
                  : Icons.history,
              size: 56,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 14),
            Text(
              favoritesOnly
                  ? 'No favourite calculations yet'
                  : 'No calculations yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              favoritesOnly
                  ? 'Tap the star on a history item to keep it here.'
                  : 'Successful COMP calculations will appear here automatically.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
