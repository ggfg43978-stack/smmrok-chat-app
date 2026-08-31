import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// ==========================================
// نظام الألوان - أخضر / ذهبي (Yalla Style)
// ==========================================
class AppColors {
  static const primary = Color(0xFF1B7A4D);
  static const primaryDark = Color(0xFF0E4A2F);
  static const primaryLight = Color(0xFF2E9E68);
  static const gold = Color(0xFFFFC94A);
  static const goldDark = Color(0xFFE8A317);
  static const background = Color(0xFF0A2E1E);
  static const card = Color(0xFF123D28);
  static const cardLight = Color(0xFF1E5238);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB6D9C7);
}

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmmRok Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.gold,
          surface: AppColors.card,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      locale: const Locale('ar'),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// شاشة تسجيل الدخول / إنشاء حساب
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegisterMode = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> result;
      if (_isRegisterMode) {
        result = await ApiService.register(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      } else {
        result = await ApiService.login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      }

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        await prefs.setString('username', result['user']['username']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        setState(() => _error = result['error'] ?? 'حدث خطأ غير متوقع');
      }
    } catch (e) {
      setState(() => _error = 'فشل الاتصال بالسيرفر');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, size: 46, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 20),
                Text(
                  _isRegisterMode ? 'إنشاء حساب جديد' : 'مرحباً بعودتك',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                if (_isRegisterMode) ...[
                  TextField(
                    controller: _usernameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'اسم المستخدم'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _isRegisterMode ? 'البريد الإلكتروني' : 'البريد الإلكتروني أو اسم المستخدم',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'كلمة المرور'),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                        )
                      : Text(_isRegisterMode ? 'إنشاء حساب' : 'دخول'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                  child: Text(
                    _isRegisterMode ? 'عندك حساب؟ سجل دخول' : 'ما عندك حساب؟ أنشئ واحد',
                    style: const TextStyle(color: AppColors.gold),
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

// ==========================================
// شريط علوي مشترك (عملات + صورة + مستوى)
// ==========================================
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  const TopBar({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: AppColors.primaryDark,
      child: Row(
        children: [
          _pill(Icons.settings, null),
          const SizedBox(width: 8),
          _pill(Icons.diamond, '0'),
          const SizedBox(width: 8),
          _pill(Icons.monetization_on, '2000'),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gold,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: -4, left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                  child: const Text('1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          if (value != null) ...[
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

// ==========================================
// الشاشة الرئيسية - Bottom Navigation
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  String _token = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      RoomsTab(token: _token, username: _username),
      const GroupsTab(),
      const FriendsTab(),
      ProfileTab(username: _username),
    ];

    return Scaffold(
      appBar: TopBar(username: _username),
      body: tabs[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            children: [
              _navItem(0, Icons.groups_rounded, 'الغرف'),
              _navItem(1, Icons.diversity_3_rounded, 'المجموعات'),
              _navItem(2, Icons.people_alt_rounded, 'الأصدقاء'),
              _navItem(3, Icons.person_rounded, 'البروفايل'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final selected = _index == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.gold : AppColors.textSecondary, size: 26),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? AppColors.gold : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// تبويب الغرف - عرض شبكي (Grid) بستايل الكروت
// ==========================================
class RoomsTab extends StatefulWidget {
  final String token;
  final String username;
  const RoomsTab({super.key, required this.token, required this.username});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<dynamic> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.listRooms();
      setState(() => _rooms = result['rooms'] ?? []);
    } catch (e) {
      // تجاهل الخطأ
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showCreateRoomDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('إنشاء غرفة جديدة', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'اسم الغرفة')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'الوصف (اختياري)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.createRoom(widget.token, nameCtrl.text, descCtrl.text);
              _loadRooms();
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinAndOpenRoom(int roomId, String roomName) async {
    await ApiService.joinRoom(widget.token, roomId);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(roomId: roomId, roomName: roomName, token: widget.token, username: widget.username),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.explore_rounded, color: AppColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('اكتشاف الغرف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              IconButton(icon: const Icon(Icons.refresh, color: AppColors.gold), onPressed: _loadRooms),
              IconButton(icon: const Icon(Icons.add_circle, color: AppColors.gold), onPressed: _showCreateRoomDialog),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : _rooms.isEmpty
                  ? const Center(child: Text('لا توجد غرف حالياً، أنشئ واحدة!', style: TextStyle(color: AppColors.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        return InkWell(
                          onTap: () => _joinAndOpenRoom(room['id'], room['name']),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        const Center(child: Icon(Icons.groups, color: Colors.white, size: 40)),
                                        Positioned(
                                          top: 6, right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.person, size: 11, color: Colors.white),
                                                const SizedBox(width: 2),
                                                Text('${room['members_count']}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(room['name'] ?? '',
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(room['description'] ?? '',
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
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

// ==========================================
// تبويب المجموعات (قريباً)
// ==========================================
class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonTab(icon: Icons.diversity_3_rounded, title: 'المجموعات', subtitle: 'قريباً راح تقدر تنشئ مجموعات وتضيف أصدقاءك فيها');
  }
}

// ==========================================
// تبويب الأصدقاء (قريباً)
// ==========================================
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonTab(icon: Icons.people_alt_rounded, title: 'الأصدقاء', subtitle: 'قريباً راح تقدر تضيف أصدقاء وتتابع نشاطهم');
  }
}

class _ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ComingSoonTab({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, size: 44, color: AppColors.gold),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// تبويب البروفايل - بستايل Yalla الأخضر
// ==========================================
class ProfileTab extends StatelessWidget {
  final String username;
  const ProfileTab({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('ID: ------', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                        child: const Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0,
                            minHeight: 8,
                            backgroundColor: AppColors.cardLight,
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('المستوى', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _sectionCard('اللعبة', [
                  _statRow('المجموع', '0'),
                  _statRow('احتمال الفوز', '0.0%'),
                ]),
                const SizedBox(height: 14),
                _sectionCard('الإنجازات', [
                  _statRow('مستوى رويال', '0'),
                  _statRow('الشارات', '0'),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.gold),
                      const SizedBox(width: 10),
                      const Text('الرصيد', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const Spacer(),
                      const Text('0', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================================
// شاشة الدردشة داخل غرفة
// ==========================================
class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String token;
  final String username;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.token,
    required this.username,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgCtrl = TextEditingController();
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final result = await ApiService.getMessages(widget.roomId);
    setState(() => _messages = result['messages'] ?? []);
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final text = _msgCtrl.text.trim();
    _msgCtrl.clear();
    await ApiService.sendMessage(widget.token, widget.roomId, text);
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Text(widget.roomName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender_username'] == widget.username;
                return Align(
                  alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['sender_username'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gold)),
                        Text(msg['message'] ?? '', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.gold,
                    child: IconButton(icon: const Icon(Icons.send, color: AppColors.primaryDark), onPressed: _send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
