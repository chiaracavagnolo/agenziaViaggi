import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//importo funzionalità di firebase per l'autenticazione
import 'package:firebase_auth/firebase_auth.dart';
//file generato automaticamente da firebase, che contiene configurazioni
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  //imposto il gestore di errori, per catturare tutti gli errori e farli visualizzare nella console
  FlutterError.onError = (FlutterErrorDetails details) {
    // Logga l'errore in console
    print('Errore Flutter: ${details.exception}');
    print('StackTrace: ${details.stack}');
  };

  // Inizializzo l'applicazione e Firebase
  WidgetsFlutterBinding.ensureInitialized();
  //inizializzo in modo asincrono
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Avvio l'app partendo dal widget MyApp
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // materialApp è un widget, la struttura base dell'app in stile Material Design
    return MaterialApp(
      title: 'Agenzia di Viaggi',
      //imposto su false per nascondere il banner di debug che appare dopo lo sviluppo
      debugShowCheckedModeBanner: false,
      //imposto il tema dell'app
      theme: ThemeData(primarySwatch: Colors.blue),
      //imposto widget di partenza per l'app
      home: AuthWrapper(),
    );
  }
}

//questo widget gestisce login e determina quali pagine mostrare
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Uso StreamBuilder per controllare lo stato di login
    //questo widget ascolta il flusso di dati
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //se lo stato è in attesa, mostra indicatore di caricamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return HomePage(); // Mostra HomePage se l'utente è loggato
        }

        return LoginPage(); // Mostra LoginPage se l'utente non è loggato
      },
    );
  }
}
