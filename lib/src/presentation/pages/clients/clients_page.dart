import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'client_detail_page.dart';
import '../../providers/providers.dart';
import 'client_form_page.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _State();
}

class _State extends ConsumerState<ClientsPage> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(clientsProvider);
    final list = q.isEmpty ? data : ref.read(clientsProvider.notifier).search(q);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (context) => const ClientFormDialog(),
          ).then((result) {
            if (result == true) {
              ref.invalidate(clientsProvider); // تحديث قائمة العملاء
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'ابحث',
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
              child: Text(
                'لا يوجد عملاء، أضف واحدًا جديدًا',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final c = list[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(c.name.isNotEmpty ? c.name[0] : '؟'),
                    ),
                    title: Text(c.name),
                    trailing: IconButton(
                      onPressed: () async {
                        final url = Uri.parse('tel:${c.phone}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لا يمكن إجراء المكالمة')),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.phone_callback,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientDetailPage(id: c.key.toString()),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}