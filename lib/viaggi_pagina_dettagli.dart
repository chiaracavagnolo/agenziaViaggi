import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recensioni.dart';

class ViaggioDetailPage extends StatefulWidget {
  //riceve un oggetto documentsnapshot, ovvero un documento di Firestore
  final DocumentSnapshot viaggio;

  const ViaggioDetailPage({Key? key, required this.viaggio}) : super(key: key);

  @override
  _ViaggioDetailPageState createState() => _ViaggioDetailPageState();
}

class _ViaggioDetailPageState extends State<ViaggioDetailPage> {
  TextEditingController numPartecipantiController = TextEditingController();

  Future<void> prenotaViaggio(String viaggioId) async {
    // Recupera l'utente attualmente loggato
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Aggiungi l'utenteId alla lista dei partecipanti del viaggio
        await FirebaseFirestore.instance.collection('viaggi')
            .doc(viaggioId) // Seleziona il documento del viaggio
            .update({
          'partecipanti': FieldValue.arrayUnion([user.uid]), // Aggiunge l'utenteId
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prenotazione effettuata!'))
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nella prenotazione: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var viaggioData = widget.viaggio.data() as Map<String, dynamic>;
    //leggo i campi da widget.viaggio
    int maxPartecipanti = viaggioData['max_partecipanti'];
    int minPartecipanti = viaggioData['min_partecipanti'];
    int prezzo = viaggioData['prezzo'];

    // Verifica se l'utente è loggato come ospite
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viaggio['meta'], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,  // Colore della barra di navigazione
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          //allineamento dei figli sull'asse incrociato
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Meta: ${widget.viaggio['meta']}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Data di partenza: ${widget.viaggio['data_di_partenza']?.toDate() ?? DateTime.now()}", style: TextStyle(fontSize: 16)),
            Text("Durata: ${widget.viaggio['durata']} giorni", style: TextStyle(fontSize: 16)),
            Text("Prezzo: $prezzo €", style: TextStyle(fontSize: 16)),
            Text("Numero partecipanti: Minimo $minPartecipanti, Massimo $maxPartecipanti", style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),
            //qui l'utente scrive quanti partecipanti vuole prenotare
            TextField(
              controller: numPartecipantiController,
              decoration: InputDecoration(
                labelText: 'Numero di partecipanti',
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isGuest
                  ? null // Disabilita il pulsante se l'utente è ospite
                  : () {
                int numPartecipanti = int.tryParse(numPartecipantiController.text) ?? 0;

                if (numPartecipanti >= minPartecipanti && numPartecipanti <= maxPartecipanti) {
                  prenotaViaggio(widget.viaggio.id); // Passa l'id del viaggio e il contesto
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Il numero di partecipanti non è valido')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Colore di sfondo del bottone
                foregroundColor: Colors.white, // Colore del testo del bottone
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(isGuest ? 'Accedi per prenotare' : 'Prenota'),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isGuest
                  ? null // Disabilita il pulsante per gli utenti ospiti
                  : () {
                //per navigare alla pagina delle recensioni
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecensionePage(viaggioId: widget.viaggio.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent, // Colore di sfondo del bottone
                foregroundColor: Colors.white, // Colore del testo del bottone
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(isGuest ? 'Accedi per aggiungere una recensione' : 'Aggiungi una Recensione'),
            ),

            SizedBox(height: 20),
            Text("Recensioni:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),


            //recupero tutte le recensioni
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recensioni')
                  .where('viaggioId', isEqualTo: widget.viaggio.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("Nessuna recensione ancora");
                }

                var recensioni = snapshot.data!.docs;

                //se le recensioni sono presenti, le mostro in una ListView (lista scrollabile)
                return ListView.builder(
                  //la lista non occupa tutto lo spazio disponibile
                  shrinkWrap: true,
                  itemCount: recensioni.length,
                  itemBuilder: (context, index) {
                    var recensione = recensioni[index];
                    return ListTile(
                      tileColor: Colors.purple[50],
                      title: Text('Voto: ${recensione['voto']}', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(recensione['testo']),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
