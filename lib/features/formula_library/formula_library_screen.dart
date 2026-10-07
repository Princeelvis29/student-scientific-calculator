import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'formula_catalog.dart';
import 'formula_entry.dart';
import 'formula_favorites_repository.dart';

class FormulaLibraryScreen extends StatefulWidget {
  const FormulaLibraryScreen({super.key});

  @override
  State<FormulaLibraryScreen> createState() =>
      _FormulaLibraryScreenState();
}

class _FormulaLibraryScreenState
    extends State<FormulaLibraryScreen> {
  final FormulaFavoritesRepository _favoritesRepository =
      FormulaFavoritesRepository();

  final TextEditingController _searchController =
      TextEditingController();

  FormulaSubject _subject =
      FormulaSubject.mathematics;
  String? _topic;
  bool _favoritesOnly = false;
  bool _loadingFavorites = true;
  Set<String> _favoriteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final Set<String> ids =
        await _favoritesRepository.load();

    if (!mounted) return;

    setState(() {
      _favoriteIds = ids;
      _loadingFavorites = false;
    });
  }

  Future<void> _toggleFavorite(
    FormulaEntry entry,
  ) async {
    final Set<String> ids =
        await _favoritesRepository.toggle(entry.id);

    if (!mounted) return;

    setState(() {
      _favoriteIds = ids;
    });
  }

  void _changeSubject(FormulaSubject subject) {
    setState(() {
      _subject = subject;
      _topic = null;
    });
  }

  List<FormulaEntry> get _visibleEntries {
    final String query =
        _searchController.text
            .trim()
            .toLowerCase();

    return FormulaCatalog.entries.where(
      (FormulaEntry entry) {
        if (entry.subject != _subject) {
          return false;
        }

        if (_topic != null &&
            entry.topic != _topic) {
          return false;
        }

        if (_favoritesOnly &&
            !_favoriteIds.contains(entry.id)) {
          return false;
        }

        if (query.isNotEmpty &&
            !entry.searchableText.contains(query)) {
          return false;
        }

        return true;
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> topics =
        FormulaCatalog.topicsFor(_subject);

    final List<FormulaEntry> entries =
        _visibleEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Library'),
        actions: <Widget>[
          IconButton(
            tooltip: _favoritesOnly
                ? 'Show all formulas'
                : 'Show favourites only',
            onPressed: () {
              setState(() {
                _favoritesOnly =
                    !_favoritesOnly;
              });
            },
            icon: Icon(
              _favoritesOnly
                  ? Icons.star
                  : Icons.star_border,
              color: _favoritesOnly
                  ? AppTheme.equals
                  : AppTheme.secondaryText,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 900),
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller:
                        _searchController,
                    onChanged: (_) =>
                        setState(() {}),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search formulas, symbols, topics...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          _searchController
                                  .text
                                  .isEmpty
                              ? null
                              : IconButton(
                                  tooltip:
                                      'Clear search',
                                  onPressed: () {
                                    _searchController
                                        .clear();
                                    setState(() {});
                                  },
                                  icon:
                                      const Icon(
                                    Icons.close,
                                  ),
                                ),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                ),
                _buildSubjectSelector(),
                _buildTopicSelector(topics),
                Expanded(
                  child: _loadingFavorites
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : entries.isEmpty
                          ? _EmptyFormulaState(
                              favoritesOnly:
                                  _favoritesOnly,
                              hasSearch:
                                  _searchController
                                      .text
                                      .trim()
                                      .isNotEmpty,
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                16,
                                8,
                                16,
                                24,
                              ),
                              itemCount:
                                  entries.length,
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
                                final FormulaEntry
                                    entry =
                                    entries[index];

                                return _FormulaCard(
                                  entry: entry,
                                  isFavorite:
                                      _favoriteIds
                                          .contains(
                                    entry.id,
                                  ),
                                  onFavorite:
                                      () =>
                                          _toggleFavorite(
                                    entry,
                                  ),
                                  onOpen: () =>
                                      _showFormulaDetails(
                                    entry,
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

  Widget _buildSubjectSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: SegmentedButton<FormulaSubject>(
        segments: FormulaSubject.values
            .map(
              (FormulaSubject subject) =>
                  ButtonSegment<
                      FormulaSubject>(
                value: subject,
                label:
                    Text(subject.label),
              ),
            )
            .toList(),
        selected:
            <FormulaSubject>{_subject},
        onSelectionChanged:
            (Set<FormulaSubject> selection) {
          _changeSubject(selection.first);
        },
      ),
    );
  }

  Widget _buildTopicSelector(
    List<String> topics,
  ) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(
              right: 8,
            ),
            child: FilterChip(
              label: const Text('All topics'),
              selected: _topic == null,
              onSelected: (_) {
                setState(() {
                  _topic = null;
                });
              },
            ),
          ),
          ...topics.map(
            (String topic) => Padding(
              padding:
                  const EdgeInsets.only(
                right: 8,
              ),
              child: FilterChip(
                label: Text(topic),
                selected: _topic == topic,
                onSelected: (_) {
                  setState(() {
                    _topic = topic;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFormulaDetails(
    FormulaEntry entry,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          AppTheme.numberKey,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.86,
            child: StatefulBuilder(
              builder: (
                BuildContext context,
                StateSetter modalSetState,
              ) {
                final bool isFavorite =
                    _favoriteIds.contains(
                  entry.id,
                );

                Future<void> toggle() async {
                  await _toggleFavorite(entry);

                  if (context.mounted) {
                    modalSetState(() {});
                  }
                }

                return ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    28,
                  ),
                  children: <Widget>[
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: <Widget>[
                              Text(
                                entry.title,
                                style:
                                    const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '${entry.subject.label} • ${entry.topic}',
                                style:
                                    const TextStyle(
                                  color: AppTheme
                                      .mutedText,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: isFavorite
                              ? 'Remove favourite'
                              : 'Save favourite',
                          onPressed: toggle,
                          icon: Icon(
                            isFavorite
                                ? Icons.star
                                : Icons
                                    .star_border,
                            color: isFavorite
                                ? AppTheme.equals
                                : AppTheme
                                    .secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _DetailPanel(
                      label: 'Formula',
                      value: entry.formula,
                      prominent: true,
                    ),
                    _DetailPanel(
                      label: 'Symbols',
                      value: entry.symbols,
                    ),
                    _DetailPanel(
                      label: 'Units',
                      value: entry.units,
                    ),
                    _DetailPanel(
                      label: 'Explanation',
                      value: entry.explanation,
                    ),
                    _DetailPanel(
                      label: 'Example',
                      value: entry.example,
                    ),
                    _DetailPanel(
                      label:
                          'Related calculator mode',
                      value:
                          entry.relatedMode,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.entry,
    required this.isFavorite,
    required this.onFavorite,
    required this.onOpen,
  });

  final FormulaEntry entry;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.display,
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: isFavorite
                  ? AppTheme.equals
                      .withValues(alpha: 0.55)
                  : const Color(
                      0xFF334155,
                    ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                AppTheme.numberKey,
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Text(
                            entry.topic,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                              color: AppTheme
                                  .mutedText,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: AppTheme
                                .equals
                                .withValues(alpha: 
                              0.14,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Text(
                            entry.relatedMode,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                              color: Color(
                                0xFFFBBF24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      entry.formula,
                      style: const TextStyle(
                        fontSize: 20,
                        color:
                            AppTheme.primaryText,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      entry.explanation,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Remove favourite'
                    : 'Save favourite',
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.star
                      : Icons.star_border,
                  color: isFavorite
                      ? AppTheme.equals
                      : AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.label,
    required this.value,
    this.prominent = false,
  });

  final String label;
  final String value;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: prominent
            ? AppTheme.equals.withValues(alpha: 0.10)
            : AppTheme.display,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: prominent
              ? AppTheme.equals
                  .withValues(alpha: 0.5)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: TextStyle(
              fontSize:
                  prominent ? 22 : 16,
              fontWeight: prominent
                  ? FontWeight.w800
                  : FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFormulaState extends StatelessWidget {
  const _EmptyFormulaState({
    required this.favoritesOnly,
    required this.hasSearch,
  });

  final bool favoritesOnly;
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final String message;

    if (favoritesOnly) {
      message =
          'No favourite formulas match this filter.';
    } else if (hasSearch) {
      message =
          'No formulas match your search.';
    } else {
      message =
          'No formulas are available for this filter.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.menu_book_outlined,
              size: 58,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
