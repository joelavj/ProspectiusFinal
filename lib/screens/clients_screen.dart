import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospect_provider.dart';
import 'prospect_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    final authProvider = context.read<AuthProvider>();
    final prospectProvider =
        Provider.of<ProspectProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      prospectProvider.loadProspects(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        elevation: 0,
      ),
      body: Consumer<ProspectProvider>(
        builder: (context, prospectProvider, child) {
          if (prospectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = prospectProvider.prospects
              .where((prospect) => prospect.status == 'converti')
              .toList();

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun client converti',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les prospects convertis en clients apparaîtront ici',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: clients.length,
            itemBuilder: (context, index) => _buildClientCard(
              context,
              clients[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Prospect client) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProspectDetailScreen(prospect: client),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[500],
                child: Text(
                  client.prenom[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                client.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  client.type.capitalize(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Status badge
              Chip(
                label: const Text('Converti'),
                backgroundColor: Colors.green[200],
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Email and phone (truncated)
              if (client.email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    client.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
              if (client.telephone.isNotEmpty)
                Text(
                  client.telephone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
