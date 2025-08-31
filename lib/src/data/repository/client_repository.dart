import 'package:hive/hive.dart';
import '../../domain/models/client.dart';
import '../hive/hive_services.dart';

class ClientRepository {
  final box = Hive.box<Client>(HiveService.clientsBox);

  List<Client> getAll() => box.values.toList();

  Future<void> add(Client client) => box.add(client);

  Future<void> update(Client client) => client.save();

  Future<void> delete(Client client) => client.delete();
}
