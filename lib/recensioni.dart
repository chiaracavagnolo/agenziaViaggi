import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecensionePage extends StatefulWidget {
  final String viaggioId;  // L'ID del viaggio che l'utente sta recensendo

  RecensionePage({required this.viaggioId});

  @override
  _RecensionePageState createState() => _RecensionePageState();
}

class _RecensionePageState extends State<RecensionePage> {
  final _testoController = TextEditingController();
  final _votoController = TextEditingController();
  //chiave globale associata al form, usata per validare i dati inseriti nei campi prima che vengano inviati al db
  final _formKey = GlobalKey<FormState>();

  // Funzione per inviare la recensione al database
  Future<void> inviaRecensione() async {
    //eseguo la validazioe del modulo, poi posso procedere all'invio
    if (_formKey.currentState!.validate()) {
      try {
        // Aggiungi la recensione al database
        await FirebaseFirestore.instance.collection('recensioni').add({
          'viaggioId': widget.viaggioId, // Riferimento al viaggio
          'utenteId': FirebaseAuth.instance.currentUser!.uid, // ID utente che lascia la recensione
          'testo': _testoController.text,
          'voto': int.parse(_votoController.text), // Voto numerico
          'data': Timestamp.now(), // Data di creazione della recensione
        });

        // Mostro un messaggio di conferma
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recensione inviata con successo!')),
        );

        // Torna alla pagina precedente
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel inviare la recensione: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scrivi una Recensione')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        //Form è il widget che si occupa dei campi di input, associato a _formKey
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _testoController,
                decoration: InputDecoration(labelText: 'Scrivi la tua recensione'),
                //gli utenti possono scrivere fino a massimo 5 righe
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La recensione non può essere vuota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _votoController,
                decoration: InputDecoration(labelText: 'Voto (1-5)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Il voto è obbligatorio';
                  }
                  int? voto = int.tryParse(value);
                  if (voto == null || voto < 1 || voto > 5) {
                    return 'Il voto deve essere un numero tra 1 e 5';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              //pulsante per inviare la recensione
              ElevatedButton(
                onPressed: inviaRecensione,
                child: Text('Invia Recensione'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
