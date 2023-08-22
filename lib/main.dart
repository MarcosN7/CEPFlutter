import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'e7b8HH6Jbf8vCbGEGhO2Pmx6OXzDaHjRjlxeimyj', // Substitua pelo seu App ID do Back4App
    'https://parseapi.back4app.com/',
    clientKey:
        'psB5LZXUeBq3hchObnNZgoKRTWiyolAYF5IXh17', // Substitua pelo seu Client Key do Back4App
    debug: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEP App',
      home: CEPScreen(),
    );
  }
}

class CEPScreen extends StatefulWidget {
  @override
  _CEPScreenState createState() => _CEPScreenState();
}

class _CEPScreenState extends State<CEPScreen> {
  TextEditingController _cepController = TextEditingController();
  String _result = '';

  Future<void> _fetchCEPFromViaCep(String cep) async {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      try {
        final viacepData = json.decode(response.body);
        setState(() {
          _result =
              'CEP: ${viacepData['cep']}\nLogradouro: ${viacepData['logradouro']}\nBairro: ${viacepData['bairro']}\nCidade: ${viacepData['localidade']}\nEstado: ${viacepData['uf']}';
        });

        final queryBuilder = QueryBuilder<ParseObject>(ParseObject('CEP'))
          ..whereEqualTo('cep', viacepData['cep']);
        final responseBack4App = await queryBuilder.query();
        if (responseBack4App.results.isEmpty) {
          final cepObject = ParseObject('CEP')
            ..set('cep', viacepData['cep'])
            ..set('logradouro', viacepData['logradouro'])
            ..set('bairro', viacepData['bairro'])
            ..set('cidade', viacepData['localidade'])
            ..set('estado', viacepData['uf']);
          await cepObject.save();
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      setState(() {
        _result = 'Error fetching data from ViaCEP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta e Cadastro de CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cepController,
              decoration: InputDecoration(labelText: 'Digite um CEP'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_cepController.text.isNotEmpty) {
                  _fetchCEPFromViaCep(_cepController.text);
                }
              },
              child: Text('Consultar e Cadastrar'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
