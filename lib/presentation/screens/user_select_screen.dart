import 'package:flutter/material.dart';
import 'package:time_table/data/database_helper.dart';
import 'package:time_table/domain/models/user.dart';
import 'package:time_table/presentation/screens/timetable_screen.dart';

class UserSelectScreen extends StatefulWidget {
  @override
  _UserSelectScreenState createState() => _UserSelectScreenState();
}

class _UserSelectScreenState extends State<UserSelectScreen> {
  final TextEditingController _userController = TextEditingController();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final rows = await DatabaseHelper.instance.queryUsers();
    return rows.map((row) => User.fromMap(row)).toList();
  }

  void _addUser() async {
    if (_userController.text.trim().isEmpty) return;
    await DatabaseHelper.instance.insertUser({'name': _userController.text.trim()});
    _userController.clear();
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  void _deleteUser(User user) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("삭제하시겠습니까?"),
        content: Text("해당 사용자의 시간표도 삭제되며 복구 불가능합니다. 그래도 삭제하시겠어요?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("아니요")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("예")),
        ],
      ),
    );
    if (confirm && user.id != null) {
      await DatabaseHelper.instance.deleteUser(user.id!);
      setState(() {
        _usersFuture = _fetchUsers();
      });
    }
  }

  void _updateUser(User user) async {
    final _editController = TextEditingController(text: user.name);
    bool updated = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("이름 수정"),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(labelText: "새로운 이름"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("취소")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("저장")),
        ],
      ),
    );
    if (updated) {
      String newName = _editController.text.trim();
      if (newName.isNotEmpty && user.id != null) {
        await DatabaseHelper.instance.updateUser(user.id!, newName);
        setState(() {
          _usersFuture = _fetchUsers();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastelColors = [
      Colors.pink.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
    ];

    return Scaffold(
      backgroundColor: Color(0xFFFDF6F0),
      appBar: AppBar(
        title: Text("누가 사용할까요?", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pinkAccent.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사용자 입력 및 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "이름 입력",
                      hintText: "예: 말랑이",
                      prefixIcon: Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: Text("추가", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text("오류: ${snapshot.error}"));

                  final users = snapshot.data ?? [];
                  if (users.isEmpty)
                    return Center(child: Text("등록된 사용자가 없어요!", style: TextStyle(fontSize: 16)));

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final cardColor = pastelColors[index % pastelColors.length];
                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: Icon(Icons.person, size: 28, color: Colors.black54),
                          title: Text(
                            user.name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () => _updateUser(user),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteUser(user),
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TimetableScreen(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
