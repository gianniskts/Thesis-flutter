import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  final TextEditingController _controller = TextEditingController();
  Map<int, bool> expandedState = {};

  @override
  void initState() {
    super.initState();
    // Initialize the expanded state to false for each FAQ item
    for (int i = 0; i < faqs.length; i++) {
      expandedState[i] = false;
    }
  }

  Future<void> sendData() async {
    var uri = Uri.parse('http://127.0.0.1:5000/user/submit-complaint');

    try {
      var response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'complaint': _controller.text, // Changed 'query' to 'complaint'
        }),
      );

      if (response.statusCode == 200) {
        // Handle the response from the server
        print('Response from server: ${response.body}');
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Επιτυχία'),
                content: const Text('Η αναφορά σας στάλθηκε με επιτυχία.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('Εντάξει'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Handle the error differently based on status code
        print(
            'Failed to send data. Status code: ${response.statusCode}, Response: ${response.body}');
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Αποτυχία'),
                content: const Text(
                    'Παρακαλούμε στείλτε ξανά την αναφορά σας στο contact@ecoeats.gr. Ευχαριστούμε!'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('Εντάξει'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error occurred while sending data: $e');
    }
  }

  // List of FAQs
  final List<Map<String, String>> faqs = [
    {
      "question": "Πώς λειτουργεί η εφαρμογή;",
      "answer":
          '''Με το Too Good To Go μπορείτε να αποθηκεύσετε φαγητό από τα εστιατόρια, τις καφετέριες και τα καταστήματα που υπάρχουν στην εφαρμογή. Αντί να χρειάζεται να πετάξετε φαγητό στο τέλος της ημέρας, αυτά τα μέρη προσφέρουν ό,τι έχουν στα γεύματα έκπληξη. Το πραγματικό περιεχόμενο θα είναι έκπληξη μέχρι να φτάσετε εκεί!

Βρείτε ένα γεύμα κοντά σας, αγοράστε το μέσω της εφαρμογής και εμφανιστείτε στο κατάστημα εντός του δεδομένου χρόνου συλλογής. Δείξτε στο προσωπικό την παραγγελία σας για να λάβετε το γεύμα έκπληξής σας - και δώστε τους ένα high-five για να γιορτάσετε ότι μόλις κάνατε τη διαφορά μαζί.

Το 1/3 του φαγητού σπαταλάται, οπότε κάνετε πολύ καλά και ελπίζουμε να διασκεδάζετε όσο το κάνετε!'''
    },
    {
      "question": "Γιατί δεν μπορώ να ξέρω τι περιέχει το γεύμα έκπληξη μου;",
      "answer":
          "Τα καταστήματα δεν μπορούν να προβλέψουν ακριβώς τι είδους φαγητό θα τους μείνει στο τέλος της ημέρας. Αντί να πετάξουν φρέσκο καλό φαγητό, το μοιράζουν σε γεύματα έκπληξη. Είναι πάντα μια έκπληξη!"
    },
    {
      "question": "Έχω αλλεργίες ή διατροφικές απαιτήσεις",
      "answer":
          '''Εάν έχετε αλλεργίες, ρωτήστε το κατάστημα όταν παραλάβετε το γεύμα σας. Εάν το γεύμα περιλαμβάνει τρόφιμα στο οποία είστε αλλεργικοί, επικοινωνήστε μαζί μας. 
          
Εάν έχετε διατροφικές απαιτήσεις, όπως η χορτοφαγία, σας προτείνουμε να χρησιμοποιήσετε την επιλογή φίλτρου στην καρτέλα αναζήτησης για να αναζητήσετε γεύμα που σας ταιριάζει.
          '''
    },
    {
      "question": "Γιατί δεν υπάρχουν καταστήματα κοντά μου;",
      "answer":
          "Το δουλεύουμε! Θέλουμε να καταπολεμήσουμε τη σπατάλη τροφίμων παντού, γι'αυτό έλεγξε ξανά αργότερα. Είστε επίσης ευπρόσδεκτοι να πείτε στα καταστήματα της περιοχής σας για την EcoEats και να τα ενθαρρύνετε να συμμετάσχουν μαζί μας!"
    },
    {
      "question":
          "Χρειάζεται να φέρω το κινητό μαζί μου για να παραλάβω την παραγγελία μου;",
      "answer":
          "Ναι, πάρτε το τηλέφωνο μαζί σας κατά την παραλαβή της παραγγελίας γιατί θα χρειαστεί να πείτε τον μοναδικό κωδικό στο προσωπικό, το οποίο στη συνέχεια θα σας παραδώσει το γεύμα έκπληξη."
    },
    {
      "question": "Μπορώ να πληρώσω με μετρητά στο κατάστημα;",
      "answer": "Όχι, όλες οι αγορές γίνονται μέσω της εφαρμογής."
    },
    {
      "question": "Έχασα την ώρα παραλαβής",
      "answer":
          '''Οι EcoEats παραγγελίες πρέπει να συλλέγονται εντός του καθορισμένου χρονικού πλαισίου που εμφανίζεται στην εφαρμογή. Επομένως, είναι σημαντικό να παρακολουθείτε τον χρόνο που έχετε κάνει μια παραγγελία. 
          
Εάν αντιληφθείτε ότι δεν μπορείτε να τα καταφέρετε, μπορείτε να ακωρώσετε την παραγγελία σας έως και 2 ώρες πριν την έναρξη του χρόνου παραλαβής.'''
    },
    {
      "question": "Είχα κακή εμπειρία με την παραγγελία μου",
      "answer":
          "Λυπούματε που είχατε μια κακή εμπειρία. Το φαγητό που εξοικονομείτε με την EcoEats είναι αυτό που έχει μείνει στο κατάστημα στο τέλος της ημέρας. Εάν λάβατε φαγητό που έχει χαλάσει, δεν πληρούσε την αναμενόμενη αξίαή είχατε άλλη ατυχή εμπειρία με την παραγγελία σας, επικοινωνήστε μαζί μας."
    },
    {
      "question": "Έχω ανησυχία για την ασφάλεια του γεύματος μου",
      "answer":
          "Εάν είχατε αλλεργική αντίδραση, αρρωστήσατε μετά την κατανάλωση ενός γεύματος που παραλάβατε ή θέλετε να αναφέρετε ένα επικείμενο πρόβλημα υγιεινής στο κατάστημα, επικοινωνήστε μαζί μας. "
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Υποστήριξη'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'Αναφορά προβλήματος',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            CupertinoTextField(
              placeholder:
                  "Λαμβάνουμε υπόψη τα προβλήματά σου και θα δωθεί λύση το συντομότερο δυνατό.",
              controller: _controller,
              decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.darkBackgroundGray),
                  borderRadius: BorderRadius.circular(16.0)),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            CupertinoButton(
              onPressed: sendData,
              child: const Text('Αποστολή'),
            ),
            const SizedBox(height: 20),

            const Text(
              'Συχνές ερωτήσεις',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // FAQ List
            for (int i = 0; i < faqs.length; i++) buildFAQItem(i),
          ],
        ),
      ),
    );
  }

  Widget buildFAQItem(int index) {
    bool isExpanded = expandedState[index]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CupertinoButton(
          onPressed: () {
            setState(() {
              expandedState[index] = !isExpanded;
            });
          },
          child: Text(faqs[index]["question"]!,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        isExpanded
            ? Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 10),
                child: Text(
                  faqs[index]["answer"]!,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : Container()
      ],
    );
  }
}
