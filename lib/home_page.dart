import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'viaggi_pagina_dettagli.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // dichiaro variabili per i filtri
  String? meta;
  DateTime? data;
  double? maxPrezzo;
  int? durata;
  int? minPartecipanti;
  int? maxPartecipanti;

  // Controller per il numero di partecipanti
  TextEditingController numPartecipantiController = TextEditingController();

  // Funzione che aggiornare le variabili dei filtri ogni volta che l'utente interagisce con i campi
  void _aggiornaFiltri({String? meta, DateTime? data, double? maxPrezzo, int? durata, int? minPartecipanti, int? maxPartecipanti}) {
    setState(() {
      this.meta = meta;
      this.data = data;
      this.maxPrezzo = maxPrezzo;
      this.durata = durata;
      this.minPartecipanti = minPartecipanti;
      this.maxPartecipanti = maxPartecipanti;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se l'utente è loggato
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home - Agenzia Viaggi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Cambia colore della barra
        actions: [
          IconButton(
            //bottone di logout
    icon: Icon(Icons.logout),
    onPressed: () async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    },
  )
],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filtra i tuoi viaggi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                SizedBox(height: 10),

                //ogni textfield consente all'utente di inserire un valore per uno dei filtri
                TextField(
                  onChanged: (val) => _aggiornaFiltri(meta: val),
                  decoration: InputDecoration(
                    labelText: 'Meta',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (val) => _aggiornaFiltri(maxPrezzo: double.tryParse(val)),
                  decoration: InputDecoration(
                    labelText: 'Max Prezzo',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (val) => _aggiornaFiltri(durata: int.tryParse(val)),
                  decoration: InputDecoration(
                    labelText: 'Durata',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: user == null || user.isAnonymous
                      ? null // Disabilito il pulsante per gli utenti anonimi
                      : () {
                    String inputPartecipanti = numPartecipantiController.text.trim();

                    // Verifica se il campo è vuoto
                    if (inputPartecipanti.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Per favore, inserisci un numero di partecipanti')),
                      );
                      return;
                    }

                    // Converte l'input in intero
                    int? numPartecipanti = int.tryParse(inputPartecipanti);
                    if (numPartecipanti == null) {
                      // Se non è un numero valido
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Il numero di partecipanti deve essere un numero valido')),
                      );
                      return;
                    }

                    // Verifica che il numero di partecipanti sia nel range valido
                    if (numPartecipanti >= minPartecipanti! && numPartecipanti <= maxPartecipanti!) {
                      // Prenotazione confermata
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Prenotazione confermata!')),
                      );
                    } else {
                      // Se il numero non è valido, mostriamo il motivo
                      String erroreMessaggio = '';
                      if (numPartecipanti < minPartecipanti!) {
                        erroreMessaggio = 'Il numero di partecipanti è troppo basso. Il minimo è $minPartecipanti.';
                      } else if (numPartecipanti > maxPartecipanti!) {
                        erroreMessaggio = 'Il numero di partecipanti è troppo alto. Il massimo è $maxPartecipanti.';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(erroreMessaggio)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Colore di sfondo
                    foregroundColor: Colors.white, // Colore del testo
                  ),
                  child: Text('Prenota'),
                )
              ],
            ),
          ),
          Expanded(
            //recupero e visualizzo i dati dalla collezione viaggi di firebase
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('viaggi').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nessun viaggio trovato.'));
                }

                var viaggi = snapshot.data!.docs;

                //costruisce una lista di viaggi
                return ListView.builder(
                  itemCount: viaggi.length,
                  itemBuilder: (context, index) {
                    var viaggio = viaggi[index];

                    // Converti il Timestamp in DateTime per la visualizzazione
                    var dataDiPartenza = viaggio['data_di_partenza']?.toDate() ?? DateTime.now();

                    // Formatta la data per mostrarla solo con giorno, mese, anno, ora e minuti
                    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dataDiPartenza);

                    //ogni elemento della lista è cliccabile e porta ad una pagina di dettaglio
                    return ListTile(
                      title: Text(viaggio['meta']),
                      subtitle: Text(
                        'Data di partenza: $formattedDate - Prezzo: ${viaggio['prezzo']}€',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViaggioDetailPage(viaggio: viaggio),
                          ),
                        );
                      },
                      //se l'utente è anonimo, viene mostrata un'icona di blocco
                      trailing: user == null || user.isAnonymous
                          ? Icon(Icons.lock, color: Colors.red)
                          : Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
