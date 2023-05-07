import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jxlssfjavyzwwxumxgue.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4bHNzZmphdnl6d3d4dW14Z3VlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODM0NDc2NzcsImV4cCI6MTk5OTAyMzY3N30.BEjHjvp8s-FOoOiPVsZTz8jDpQgyfdVEF505n_evrSA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Flutter Tinker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Supabase Flutter Tinker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notesStream = Supabase.instance.client
      .from('Notes') // Table name
      .stream(primaryKey: ['id']);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _notesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            }
            if (snapshot.hasData) {
              final notes = snapshot.data!;

              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note['body']),
                    subtitle: Text(note['created_at'].toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await Supabase.instance.client
                            .from('Notes')
                            .delete()
                            .eq('id', note['id']);
                      },
                    ),
                  );
                },
              );
            }
            return const Center(
                child:
                    CircularProgressIndicator()); // Make progress bar if no data
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: ((context) {
                  return SimpleDialog(
                      // Pop out a dialogue
                      title: const Text('Add Note'),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        TextFormField(
                          // Add a place to put in text
                          onFieldSubmitted: (value) async {
                            // Sync to Supabase on submission
                            await Supabase.instance.client
                                .from('Notes') // Table name
                                .insert(
                                    {'body': value}); // Column name with value
                          },
                        ),
                      ]);
                }));
          },
          child: const Icon(Icons.add)),
    );
  }
}
