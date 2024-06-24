import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_market/main.dart';
import 'package:list_market/SharedPreferencesHelper.dart';
import 'package:list_market/models/modelCategoria.dart';

class AddCategoriaScreen extends StatefulWidget {
  final VoidCallback onSave;

  AddCategoriaScreen({required this.onSave});

  @override
  _AddCategoriaScreenState createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  File? _image;
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenhuma imagem selecionada.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao selecionar imagem: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveCategoria() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final categorias = await _prefsHelper.getCategorias();
        final novoId = categorias.isNotEmpty
            ? categorias.length +
                1 +
                Random().nextInt(1000) +
                Random().nextInt(100)
            : Random().nextInt(1000) + Random().nextInt(100) + 5;
        final novaCategoria = Categoria(
          id: novoId,
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          imagem: _image!.path,
        );

        categorias.add(novaCategoria);
        await _prefsHelper.saveCategorias(categorias);

        widget.onSave();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MainScreen(),
        )); // Retorna para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao salvar categoria: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Por favor, preencha todos os campos e selecione uma imagem.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = new FocusNode();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Nova Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLength: 15,
                controller: _nomeController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                  filled: true,
                  fillColor: Color.fromARGB(255, 245, 245, 245),
                  labelText: 'Nome',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.label_outline),
                  filled: true,
                  fillColor: Color.fromARGB(255, 245, 245, 245),
                  labelText: 'Descrição (Opcional)',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40.0),
              _image == null
                  ? SizedBox(
                      width: 300,
                      height: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          enableFeedback: true,
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 245, 245, 245),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        onPressed: _pickImage,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Color.fromARGB(255, 55, 71, 79),
                              size: 40,
                            ),
                            Text(
                              "Upload Images here",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 55, 71, 79)),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveCategoria,
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    ContinuousRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromARGB(255, 94, 196, 1),
                  ),
                ),
                child: const Stack(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        color: Colors.white,
                        Icons.save_outlined,
                        size: 20,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Salvar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
