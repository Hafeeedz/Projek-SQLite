import 'package:flutter/material.dart';

import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  // **Membaca semua data dari database**
  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  // **Menampilkan dialog untuk menambah atau mengedit data**
  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
      _genreController.text = existingItem['genre'];
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _genreController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(labelText: 'Genre'),
          ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 183, 23, 23),
                foregroundColor: Colors.white
              ),
              onPressed: () async {
                if (_titleController.text.isEmpty ||  _genreController.text.isEmpty) {
                  return;
                }

                if (id == null) {
                  await SQLHelper.createItem(
                      _titleController.text, _descriptionController.text,  _genreController.text);
                } else {
                  await SQLHelper.updateItem(
                      id, _titleController.text, _descriptionController.text,  _genreController.text);
                }

                Navigator.of(context).pop();
                _refreshItems();
              },
              child: Text(id == null ? 'Add Item' : 'Update Item')
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() {}); // Memastikan UI diperbarui setelah modal ditutup
    });
  }

  // **Menghapus data berdasarkan ID**
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshItems();                                                                                                                                                
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite CRUD Example',
      style: TextStyle(color: Colors.white),),
      backgroundColor: const Color.fromARGB(255, 183, 23, 23),),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
  title: Text(
    _items[index]['title'],
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_items[index]['description'] ),
      SizedBox(
        height: 5,
      ),
      Text(_items[index]['genre'],
      style: TextStyle(fontWeight: FontWeight.bold)
      ),
    ],
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showForm(_items[index]['id'])),
      IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteItem(_items[index]['id'])),
    ],
  ),
)
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 183, 23, 23),
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add,
        color: Colors.white,),
      ),
    );
  }
}
