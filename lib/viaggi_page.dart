import 'package:agenzia_viaggi_definitivo/viaggi_pagina_dettagli.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viaggi.dart';  // Importa il ViaggioService
//pagina responsabile della visualizzazione di un catalogo di viaggi, con la possibilità di filtrare i viaggi

class ViaggiPage extends StatefulWidget {
  @override
  _ViaggiPageState createState() => _ViaggiPageState();
}

class _ViaggiPageState extends State<ViaggiPage> {
  String? meta;
  DateTime? data;
  double? maxPrezzo;
  int? durata;
  int? minPartecipanti;
  int? maxPartecipanti;

  //Viaggioservice è una classe che si occupa di recuperare i dati dei viaggi dal db
  ViaggioService viaggioService = ViaggioService();

  // Funzione per aggiornare i filtri
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

  // Funzione generica per ottenere i valori in modo sicuro
  //defaultValue viene restituito se campo non esiste e se il valore è null
  T getValue<T>(DocumentSnapshot doc, String key, T defaultValue) {
    var data = doc.data() as Map<String, dynamic>?; // Cast esplicito a mappa

    // Verifica se data non sia null e se la chiave esiste
    if (data != null && data.containsKey(key)) {
      var value = data[key]; // Ottengo il valore corrispondente alla chiave

      if (value == null) {
        print('Campo $key è null.'); // Log per identificare quando il campo è null
        return defaultValue; // Se il valore è null, restituisco il valore predefinito
      }

      if (T == DateTime && value is Timestamp) {
        print('Campo $key è un Timestamp e sarà convertito in DateTime');
        return value.toDate() as T; // Converte il Timestamp in DateTime
      }

      // Controllo il tipo del campo
      if (T == num && value is! num) {
        print('Il campo $key non è del tipo corretto. Servono numeri.');
        return defaultValue; // Se il tipo è errato, restituisci il valore predefinito
      }

      return value as T; // Restituisci il valore, convertito nel tipo corretto
    }

    print('Campo $key non trovato nei dati.');
    return defaultValue; // Se il campo non esiste, restituisci il valore predefinito
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Catalogo Viaggi")),
      body: Column(
        children: [
          // Filtro per meta, durata, numero di partecipanti
          ElevatedButton(
            onPressed: () {
              // Esempio di filtro
              _aggiornaFiltri(
                meta: "Roma",
                data: DateTime(2025, 5, 20),
                maxPrezzo: 600,
                durata: 7,  // Ad esempio, durata del viaggio
                minPartecipanti: 5,  // Minimo numero di partecipanti
                maxPartecipanti: 20,  // Massimo numero di partecipanti
              );
            },
            child: Text("Filtra Viaggi"),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //recupero i viaggi dal db, applicando i filtri
              stream: viaggioService.getViaggi(
                meta: meta,
                data: data,
                maxPrezzo: maxPrezzo,
                durata: durata,
                minPartecipanti: minPartecipanti,
                maxPartecipanti: maxPartecipanti,
              ),
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

                //visualizzo i dati
                //listview builder crea una lista dinamica di elementi
                return ListView.builder(
                  // il valore di itemCount viene preso dalla lunghezza dell'elenco viaggi
                  itemCount: viaggi.length,
                  //itemBuilder = funzione chiamata per ogni indice della lista
                  //context è il contesto corrente in cui il widget viene costruito
                  //index è l'indice dell'elemento corrente nella lista
                  itemBuilder: (context, index) {
                    //viaggio = il documento del viaggio corrente nell'indice index di viaggi
                    var viaggio = viaggi[index];

                    // Uso getValue per recuperare i dati in modo sicuro
                    var prezzo = getValue<num>(viaggio, 'prezzo', 0);
                    var meta = getValue<String>(viaggio, 'meta', 'N/D');
                    var dataPartenza = getValue<DateTime>(viaggio, 'data_di_partenza', DateTime.now());

                    //listTitle è un widget che rappresenta un elemento di una lista
                    return ListTile(
                      title: Text(meta),
                      subtitle: Text(
                        //formatto la data localmente con il metodo toLocal()
                        'Data di partenza: ${dataPartenza.toLocal()} - Prezzo: $prezzo€',
                      ),
                      onTap: () {
                        // quando l'utente tocca una riga, naviga alla pagina dei dettagli
                      Navigator.push (
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViaggioDetailPage(viaggio: viaggio),
                        ),
                      );
                      },
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
