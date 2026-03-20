import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
  url: 'https://kfelnflvpsymrkdredpo.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmZWxuZmx2cHN5bXJrZHJlZHBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4MzY3NTksImV4cCI6MjA4OTQxMjc1OX0.-GANEZDBRpQ_MI0IYSlcYRE0Z2eDBU91q59ECitIY6U',
);

  // Restaure la session si l'utilisateur était déjà connecté
  await AuthService.restaurerSession();

  runApp(const CESIZenApp());
}