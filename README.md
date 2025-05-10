# Agenzia Viaggi - Applicazione Flutter

Questo progetto è un'applicazione mobile sviluppata con Flutter per la gestione di un'agenzia di viaggi. L'app consente agli utenti di visualizzare offerte di viaggio, effettuare il login, cercare viaggi in base a vari criteri e lasciare recensioni dopo aver completato il viaggio.

L'applicazione si connette a **Firebase** per la gestione degli utenti, dei viaggi e delle recensioni, con l'autenticazione degli utenti e la memorizzazione dei dati nel database Firestore.

## Funzionalità principali

### 1. **Accesso come Ospite o Cliente**

- Gli utenti possono accedere come **ospiti** per visualizzare le offerte di viaggio senza effettuare il login.
- I **clienti** possono effettuare il login utilizzando la loro **e-mail** tramite Firebase.

### 2. **Gestione Viaggi**

Ogni offerta di viaggio include le seguenti informazioni:

- **Meta** del viaggio
- **Data di partenza**
- **Durata** del viaggio
- **Descrizione** del viaggio
- **Prezzo** del viaggio
- **Numero min/max di partecipanti**
- **Recensioni** da parte dei clienti

### 3. **Ricerca Viaggi**

I clienti possono cercare i viaggi in base ai seguenti criteri:

- **Costo**
- **Durata**
- **Data di partenza**
- **Meta**
- **Voto delle recensioni**

In questo modo, non è necessario esaminare tutta la lista dei viaggi, ma si può filtrare facilmente per trovare l'offerta desiderata.

### 4. **Selezione Viaggio**

I clienti possono selezionare un viaggio dal catalogo, scegliere il **numero di partecipanti** e il sistema verifica se la richiesta è soddisfacibile (ad esempio, se ci sono posti disponibili).

### 5. **Recensioni**

Dopo aver completato un viaggio, i clienti possono lasciare una **recensione** per il viaggio scelto.

## Tecnologie Utilizzate

- **Flutter**: Framework per lo sviluppo dell'applicazione mobile.
- **Firebase**: Utilizzato per l'autenticazione degli utenti e per la gestione dei dati (Firestore).
- **Firestore**: Database NoSQL di Firebase per memorizzare informazioni su utenti, viaggi e recensioni.
- **Firebase Authentication**: Per la gestione del login e dell'autenticazione tramite e-mail.

## Setup e Installazione

### 1. **Clonare il Repository**

Per clonare il progetto, esegui il seguente comando:

```bash
git clone https://github.com/chiaracavagnolo/agenziaViaggi.git
```
