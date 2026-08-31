import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// ==========================================
// نظام الألوان
// ==========================================
class AppColors {
  static const primary = Color(0xFF6C4FD6);
  static const primaryDark = Color(0xFF4A2FB8);
  static const gold = Color(0xFFFFC94A);
  static const background = Color(0xFF1A1330);
  static const card = Color(0xFF2A1F4D);
  static const cardLight = Color(0xFF352A5E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB6ACD9);
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
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
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
            colors: [AppColors.primaryDark, AppColors.background],
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
      body: SafeArea(child: tabs[_index]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
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
// تبويب الغرف
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text('الغرف', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.groups, color: Colors.white),
                            ),
                            title: Text(room['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('${room['description'] ?? ''} • أعضاء: ${room['members_count']}', style: const TextStyle(color: AppColors.textSecondary)),
                            trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                            onTap: () => _joinAndOpenRoom(room['id'], room['name']),
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
    return _ComingSoonTab(icon: Icons.diversity_3_rounded, title: 'المجموعات', subtitle: 'قريباً راح تقدر تنشئ مجموعات وتضيف أصدقاءك فيها');
  }
}

// ==========================================
// تبويب الأصدقاء (قريباً)
// ==========================================
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _ComingSoonTab(icon: Icons.people_alt_rounded, title: 'الأصدقاء', subtitle: 'قريباً راح تقدر تضيف أصدقاء وتتابع نشاطهم');
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
// تبويب البروفايل
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
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
          const Spacer(),
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
      appBar: AppBar(title: Text(widget.roomName)),
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
