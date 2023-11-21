import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FacebookLoginScreen(),
    );
  }
}

class FacebookLoginScreen extends StatefulWidget {
  @override
  _FacebookLoginScreenState createState() => _FacebookLoginScreenState();
}

class _FacebookLoginScreenState extends State<FacebookLoginScreen> {
  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_user == null)
              ElevatedButton(
                onPressed: () async {
                  LoginResult result = await FacebookAuth.instance.login();
                  AccessToken? accessToken = result.accessToken;

                  final AuthCredential credential =
                      FacebookAuthProvider.credential(
                    accessToken!.token,
                  );

                  try {
                    final UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithCredential(
                      credential,
                    );
                    final User? user = userCredential.user;

                    setState(() {
                      _user = user;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Inicio de sesión exitoso como ${_user?.displayName}',
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Error al iniciar sesión con Facebook: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al iniciar sesión'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Iniciar sesión con Facebook',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            SizedBox(height: 20),
            if (_user != null)
              Column(
                children: [
                  Text(
                    'Información del usuario:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (_user!.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_user!.photoURL!),
                    ),
                  SizedBox(height: 10),
                  Text(
                    'Nombre: ${_user?.displayName}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Correo electrónico: ${_user?.email}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'UID: ${_user?.uid}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _user = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sesión cerrada correctamente'),
                          ),
                        );
                      } catch (e) {
                        print('Error al cerrar sesión: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
