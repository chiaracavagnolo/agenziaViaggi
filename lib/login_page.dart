import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

//la classe login page è statefulwidget perché l'interfaccia cambia dinamicamente in base allo stato
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  //crea lo stato associato alla pagina di login
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //queste due variabili sono oggetti TextEditing, che si occupano di gestire il testo inserito
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Funzione per il login
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inserisci sia email che password')),
      );
      return;
    }

    try {
      //usa FirebaseAuth per tentare di effettuare il login con le credenziali fornite
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Se il login è riuscito, vai alla HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      //in caso di errori, viene mostrato un messaggio di errore con SnackBar
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password errata')),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email non valida')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore login: ${e.message}')),
        );
      }
    }
  }

  // Funzione per la registrazione
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inserisci sia email che password')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrazione completata')),
      );
      // Dopo la registrazione, invia l'utente alla HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('L\'email è già in uso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore registrazione: ${e.message}')),
        );
      }
    }
  }

  // Funzione per login anonimo
  Future<void> loginAnonimo() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${e.toString()}')),
      );
    }
  }

  @override
  //costruisco l'interfaccia
  Widget build(BuildContext context) {
    //Scaffold è la struttura di base con barra dell'app, corpo, fondo, layout,...
    return Scaffold(
      backgroundColor: Colors.purple[50],  // Colore di sfondo della pagina
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,  // Colore della barra superiore
        title: Text("Login"),
      ),

      body: Padding(
        //padding: aggiunge uno spazio di 20 attorno agli elementi
        padding: const EdgeInsets.all(20),
        child: Column(
          //column organizza i suoi figli in una colonna verticale
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Accedi o continua come ospite",
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            //SizedBox aggiunge spazio verticale di 20 tra il testo e i widget sottostanti
            SizedBox(height: 20),

            //TextField è il widget usato per raccogliere input di testo dall'utente
            TextField(
              //collega il campo di input dell'email al controller emailController
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                //imposto il colore dell'etichetta su viola scuro
                labelStyle: TextStyle(color: Colors.deepPurple),
                //quando il campo è selezionato, il bordo inferiore de campo sarà viola scuro
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            TextField(
              controller: passwordController,
              //viene mascherata la pwd
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Colors.deepPurple),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            //bottone premuto quando l'utente vuole fare login, cosi viene chiamata la funzione login()
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,  // Colore di sfondo del nottone
                foregroundColor: Colors.white,        // Colore del testo
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Login"),
            ),
            SizedBox(height: 10),

            //elevatedButton anche per registrazione
            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,  // Colore di sfondo
                foregroundColor: Colors.white,          // Colore del testo
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text("Registrati"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: loginAnonimo,
              child: Text(
                "Continua come Ospite",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
