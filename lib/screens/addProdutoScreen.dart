import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_market/SharedPreferencesHelper.dart';
import 'package:list_market/models/modelProduto.dart';

class AddProdutoScreen extends StatefulWidget {
  final int categoriaId;
  final VoidCallback onSave;

  AddProdutoScreen({required this.categoriaId, required this.onSave});

  @override
  _AddProdutoScreenState createState() => _AddProdutoScreenState();
}

class _AddProdutoScreenState extends State<AddProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  File? _image;
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduto() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final produtos =
          await _prefsHelper.getProdutosByCategoria(widget.categoriaId);
      final novoId = produtos.isNotEmpty
          ? produtos.length + 1 + Random().nextInt(1000) + Random().nextInt(100)
          : Random().nextInt(1000) + Random().nextInt(100) + 5;
      final novoProduto = Produto(
        id: novoId,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        preco: double.parse(_precoController.text),
        imagem: _image!.path,
        categoriaId: widget.categoriaId,
      );

      produtos.add(novoProduto);
      await _prefsHelper.saveProdutos(produtos);

      widget.onSave();
      Navigator.of(context).pop();

      if (kDebugMode) {
        print(widget.categoriaId.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Adicionar Produto'),
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
                height: 20,
              ),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.keyboard_double_arrow_right),
                  filled: true,
                  fillColor: Color.fromARGB(255, 245, 245, 245),
                  labelText: 'Preço',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
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
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 16.0),
              _image == null
                  ? SizedBox(
                      width: 300,
                      height: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
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
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProduto,
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
