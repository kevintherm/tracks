import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/repositories/session_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/base_button.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/view_session_page.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final searchController = TextEditingController();
  String search = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          search = searchController.text;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionRepo = context.read<SessionRepository>();

    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AppBar(),

              _SearchBar(controller: searchController),

              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BaseButton(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text("Filter"),
                          const SizedBox(width: 8),
                          Icon(Iconsax.filter_outline, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<List<Session>>(
                  stream: sessionRepo.watchAllSessions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Something went wrong: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final List<Session> sessions = snapshot.data ?? [];
                    List<Session> filtered = sessions;

                    if (search.isNotEmpty) {
                      filtered = FuzzySearch.search(
                        items: sessions,
                        query: search,
                        getSearchableText: (s) => s.workout.value?.name ?? '',
                        threshold: 0.1,
                      );
                    }

                    if (sessions.isEmpty) {
                      return Center(
                        child: Text(
                          "No sessions available.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          "No matching sessions found.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return _SessionsList(sessions: filtered);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BackButton(),
          Text(
            "Sessions",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          _ActionButtons(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: "Back",
          child: Pressable(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Iconsax.arrow_left_2_outline, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: "Import Session",
          child: Pressable(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Placeholder(child: Text("Import Session")),
                ),
              );
            },
            child: const Icon(Iconsax.import_1_outline, size: 28),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 250),
                    child: Text(
                      'Searching for `${controller.text}`',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Pressable(
                    onTap: () {
                      controller.text = "";
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
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

class _SessionsList extends StatelessWidget {
  final List<Session> sessions;

  const _SessionsList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ListView.separated(
        itemCount: sessions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _SessionListItem(session: session);
        },
      ),
    );
  }
}

class _SessionListItem extends StatelessWidget {
  final Session session;

  const _SessionListItem({required this.session});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final sessionRepo = context.read<SessionRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return _ConfirmDeleteDialog(session: session);
      },
    );

    if (confirmed == true) {
      await sessionRepo.deleteSession(session);
      if (context.mounted) {
        Toast(context).success(content: const Text("Session deleted"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await _showDeleteConfirmation(context);
        return false;
      },
      background: _DismissBackground(
        alignment: Alignment.centerRight,
        color: Colors.red[200]!,
        icon: Icons.delete,
        padding: const EdgeInsets.only(right: 20),
      ),
      child: Pressable(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewSessionPage(session: session),
            ),
          );
        },
        child: _SessionCard(session: session),
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Delete Session?',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete this session? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final EdgeInsets padding;

  const _DismissBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.00),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEE, d MMM').format(session.start),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(session.start),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (session.end != null)
                      Text(
                        _formatDuration(session.end!.difference(session.start)),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        'Incomplete',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.orange[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTypeBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    if (session.workout.value != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MingCute.barbell_fill, size: 14, color: Colors.purple),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                session.workout.value!.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.flash_1_bold, size: 14, color: Colors.orange),
            const SizedBox(width: 6),
            Text(
              'Single Exercise',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
