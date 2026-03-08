import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/ProfilePhoto.dart';

// ─── Design constants ────────────────────────────────────────────────────────
const Color kHeaderBlue = Color(0xFF0B3BA3);
const Color kTextDark   = Color(0xFF1A1A2E);
const Color kSubtleGrey = Color(0xFF6B7280);

const Map<String, Color> kTypeBadgeColor = {
  'events':        Color(0xFF0B3BA3),
  'promotions':    Color(0xFF6A0DAD),
  'announcements': Color(0xFF0B6E4F),
};

const Map<String, IconData> kTypeIcon = {
  'events':        Icons.event,
  'promotions':    Icons.local_offer,
  'announcements': Icons.campaign,
};

// ─── Data model ──────────────────────────────────────────────────────────────
class HistoryEntry {
  final String type;
  final String title;
  final String actionUid;
  final DateTime timestamp;

  const HistoryEntry({
    required this.type,
    required this.title,
    required this.actionUid,
    required this.timestamp,
  });
}

// ─── Widget ───────────────────────────────────────────────────────────────────
class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  User? user;
  bool informationLoaded = false;

  String name     = '';
  String role     = '';
  String email    = '';
  String location = '';
  File?   _imageFile;
  String? profileImageUrl;

  List<HistoryEntry> _allHistory   = [];
  bool _historyLoading             = true;
  String? _selectedHistoryFilter;

  static const List<String> _historyTypes = [
    'events',
    'promotions',
    'announcements',
  ];

  String resolveRole(dynamic roleField, {String? orgName}) {
    if (roleField == null) return 'Unknown';
    if (roleField is String) return roleField;
    if (roleField is Map) {
      final roleMap = Map<String, dynamic>.from(roleField);
      if (orgName != null) return roleMap[orgName]?.toString() ?? 'user';
      if (roleMap.values.any((r) => r.toString() == 'super_admin')) return 'super_admin';
      if (roleMap.values.any((r) => r.toString() == 'admin'))       return 'admin';
      if (roleMap.values.isNotEmpty) return roleMap.values.first.toString();
    }
    return 'user';
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _init();
  }

  Future<void> _init() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    setState(() {
      try { profileImageUrl = userDoc['profileImageUrl']; }
      catch (_) {
        profileImageUrl = null;
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'profileImageUrl': null});
      }

      try {
        name     = userDoc['name']     ?? '';
        role     = resolveRole(userDoc['role']);
        email    = userDoc['email']    ?? '';
        location = userDoc['location'] ?? '';
        _loadHistory(currentUser.uid);
      } catch (_) {
        name = role = email = location = '';
      }
      informationLoaded = true;
    });
  }

  Future<void> _loadHistory(String uid) async {
    setState(() => _historyLoading = true);

    final List<HistoryEntry> entries = [];

    for (final type in _historyTypes) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('history')
            .doc(type)
            .get();

        if (!doc.exists) continue;

        final actionField = doc.data()?['action'];
        if (actionField == null) continue;

        final actionMap = Map<String, dynamic>.from(actionField as Map);

        for (final entry in actionMap.entries) {
          try {
            final val       = Map<String, dynamic>.from(entry.value as Map);
            final rawTs     = val['timestamp'];
            final title     = val['title']?.toString()     ?? entry.key;
            final actionUid = val['actionuid']?.toString() ?? '';

            DateTime ts;
            if (rawTs is Timestamp) {
              ts = rawTs.toDate();
            } else if (rawTs is String) {
              ts = DateTime.tryParse(rawTs) ?? DateTime(1970);
            } else {
              ts = DateTime(1970);
            }

            entries.add(HistoryEntry(
              type:      type,
              title:     title,
              actionUid: actionUid,
              timestamp: ts,
            ));
          } catch (_) {}
        }
      } catch (_) {}
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _allHistory     = entries;
      _historyLoading = false;
    });
  }

  void _showSettingsMenu() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout),
              title:   const Text('Logout'),
              onTap:   () => Navigator.pop(context, 'logout'),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == 'logout') {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    } else if (action == 'delete') {
      await user?.delete();
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    try {
      String? newImageUrl;
      if (_imageFile != null) {
        newImageUrl = await _uploadProfileImage();
        if (newImageUrl == null) throw Exception('Failed to upload image');
      }
      final updateData = <String, dynamic>{};
      if (newImageUrl != null) updateData['profileImageUrl'] = newImageUrl;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update(updateData);
      setState(() {
        if (newImageUrl != null) profileImageUrl = newImageUrl;
        _imageFile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      _saveProfile();
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_imageFile == null || user == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours   < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays    < 1) return '${diff.inHours}h ago';
    if (diff.inDays    < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedHistoryFilter == null
        ? _allHistory
        : _allHistory.where((e) => e.type == _selectedHistoryFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kHeaderBlue,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color:      Colors.white,
            fontSize:   20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                ),
                child: const Icon(Icons.settings, color: Colors.white, size: 20),
              ),
              onPressed: _showSettingsMenu,
            ),
          ),
        ],
      ),
      body: informationLoaded
          ? CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildSectionHeader('Activity History', Icons.history)),
          SliverToBoxAdapter(child: _buildHistoryFilterBar()),
          _buildHistorySliver(filtered),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      )
          : const Center(child: CircularProgressIndicator(color: kHeaderBlue)),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: kHeaderBlue,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white.withOpacity(0.30),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!) as ImageProvider
                        : const AssetImage('assets/images/person-icon.png'),
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color:  Colors.white,
                      shape:  BoxShape.circle,
                      border: Border.all(color: kHeaderBlue, width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt, size: 13, color: kHeaderBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _profileChip(Icons.shield_outlined, _capitalize(role)),
                const SizedBox(height: 6),
                _profileChip(Icons.email_outlined, email),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kHeaderBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w700,
              color:      kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(label: 'All', value: null),
            ..._historyTypes.map(
                  (t) => _filterChip(label: _capitalize(t), value: t),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({required String label, required String? value}) {
    final selected = _selectedHistoryFilter == value;
    final color    = value == null
        ? kHeaderBlue
        : (kTypeBadgeColor[value] ?? kHeaderBlue);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedHistoryFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color:        selected ? color : color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null) ...[
                Icon(kTypeIcon[value], size: 14, color: selected ? Colors.white : color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySliver(List<HistoryEntry> entries) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _historyLoading
            ? const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: kHeaderBlue)),
        )
            : entries.isEmpty
            ? _emptyState('No history yet.')
            : ListView.builder(
          shrinkWrap:  true,
          physics:     const NeverScrollableScrollPhysics(),
          itemCount:   entries.length,
          itemBuilder: (ctx, i) => _historyCard(entries[i]),
        ),
      ),
    );
  }

  Widget _historyCard(HistoryEntry entry) {
    final badgeColor = kTypeBadgeColor[entry.type] ?? kHeaderBlue;
    final icon       = kTypeIcon[entry.type]       ?? Icons.info_outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: badgeColor.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color:      badgeColor.withOpacity(0.07),
              blurRadius: 6,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: badgeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:        badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _capitalize(entry.type),
                          style: TextStyle(
                            fontSize:   10,
                            fontWeight: FontWeight.w700,
                            color:      badgeColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(entry.timestamp),
                        style: const TextStyle(fontSize: 11, color: kSubtleGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      kTextDark,
                    ),
                  ),
                  if (entry.actionUid.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${entry.actionUid}',
                      style: const TextStyle(fontSize: 11, color: kSubtleGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: kSubtleGrey, fontSize: 14),
        ),
      ),
    );
  }
}