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
    return Scaffold(
      appBar: AppBar(title: Text("누가 사용할거에요?")),
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
                      hintText: "사용자 이름을 입력하세요",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text("추가", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(thickness: 2, color: Colors.grey[400]),
            SizedBox(height: 16),
            // 사용자 리스트
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text("Error: ${snapshot.error}"));
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) return Center(child: Text("등록된 사용자가 없습니다."));
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Icon(Icons.person, color: Colors.deepPurple),
                          title: Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _updateUser(user)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(user)),
                              Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TimetableScreen(user: user)),
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
