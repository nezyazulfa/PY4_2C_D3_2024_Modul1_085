import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Admin', 'Anggota'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    // 1. Izin Dasar (Read & Create bisa dilakukan siapa saja)
    if (action == actionRead || action == actionCreate) return true;

    // 2. TASK 5: KEDAULATAN DATA (Sovereignty)
    // HANYA Owner yang bisa Update & Delete. Role Admin/Ketua diabaikan untuk aksi ini.
    if (action == actionUpdate || action == actionDelete) {
      return isOwner; 
    }

    return false;
  }
}