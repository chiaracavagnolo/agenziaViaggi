//faccio import del pacchetto cloud firestore, che serve per interagire con firebase firestore
//il db nosql di firebase
//contiene la logica per aggiungere viaggi a firestore + logica per recuperare i viaggi con funzione getViaggi,
//che restituisce i dati in base ai filtri
import 'package:cloud_firestore/cloud_firestore.dart';

//definisco un servizio che gestisce la lettura dei viaggi da firestore
class ViaggioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Funzione getViaggi per recuperare i viaggi con filtri
  Stream<QuerySnapshot> getViaggi({String? meta, DateTime? data, double? maxPrezzo, int? durata, int? minPartecipanti, int? maxPartecipanti}) {
    //definisco la variabile viaggi per accedere alla collezione viaggi
    CollectionReference viaggi = _db.collection('viaggi');
    Query query = viaggi;

    //se l'utente mette dei filtri, essi vengono applicati alla query in base ai vari parametri
    if (meta != null && meta.isNotEmpty) {
      query = query.where('meta', isEqualTo: meta);
    }

    if (data != null) {
      // Confronto con Timestamp
      query = query.where('data_di_partenza', isGreaterThanOrEqualTo: Timestamp.fromDate(data));
    }

    if (maxPrezzo != null) {
      query = query.where('prezzo', isLessThanOrEqualTo: maxPrezzo);
    }

    if (durata != null) {
      query = query.where('durata', isEqualTo: durata);
    }

    if (minPartecipanti != null) {
      query = query.where('min_partecipanti', isLessThanOrEqualTo: minPartecipanti);
    }

    if (maxPartecipanti != null) {
      query = query.where('max_partecipanti', isGreaterThanOrEqualTo: maxPartecipanti);
    }

    //restituisco i risultati
    return query.snapshots();
  }
}
