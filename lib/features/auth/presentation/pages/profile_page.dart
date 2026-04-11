import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/foto_notifier.dart';
import '../../../../services/foto_service.dart';
import '../widgets/profile_photo_widget.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String? usuarioId;
  final String nombreDocente;

  const ProfilePage({
    Key? key,
    this.usuarioId,
    required this.nombreDocente,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FotoNotifier _fotoNotifier;

  @override
  void initState() {
    super.initState();
    _fotoNotifier = FotoNotifier(
      FotoService(httpClient: http.Client()),
    );
    // Cargar foto guardada
    if (widget.usuarioId != null) {
      _fotoNotifier.loadSavedPhoto(widget.usuarioId!);
    }
  }

  void _handlePhotoSelected(File photo) async {
    if (widget.usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de usuario no disponible')),
      );
      return;
    }

    await _fotoNotifier.uploadFotoDocente(
      usuarioId: widget.usuarioId!,
      fotoFile: photo,
    );

    if (_fotoNotifier.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${_fotoNotifier.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: ChangeNotifierProvider.value(
        value: _fotoNotifier,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<FotoNotifier>(
                builder: (context, fotoNotifier, _) {
                  return ProfilePhotoWidget(
                    userName: widget.nombreDocente,
                    initialPhotoUrl: fotoNotifier.fotoUrl,
                    onPhotoSelected: _handlePhotoSelected,
                    isLoading: fotoNotifier.isLoading,
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Información Personal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nombre:', widget.nombreDocente),
                      const Divider(),
                      _buildInfoRow('Rol:', 'Docente'),
                      const Divider(),
                      _buildInfoRow('ID:', widget.usuarioId ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí puede ir la lógica para cambiar contraseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Función de cambiar contraseña próximamente')),
                    );
                  },
                  child: const Text('Cambiar Contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fotoNotifier.dispose();
    super.dispose();
  }
}
