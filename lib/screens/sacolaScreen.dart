import 'dart:io';
import 'package:flutter/material.dart';
import 'package:list_market/models/modelProduto.dart';
import 'package:list_market/SharedPreferencesHelper.dart';

class SacolaScreen extends StatefulWidget {
  @override
  _SacolaScreenState createState() => _SacolaScreenState();
}

class _SacolaScreenState extends State<SacolaScreen> {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();
  List<Produto> _sacola = [];

  @override
  void initState() {
    super.initState();
    _refreshSacola();
  }

  Future<void> _refreshSacola() async {
    final sacola = await _prefsHelper.getSacola();
    setState(() {
      _sacola = sacola;
    });
  }

  Future<void> _removeFromSacola(int produtoId) async {
    await _prefsHelper.removeFromSacola(produtoId);
    _refreshSacola();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(milliseconds: 300),
      content: Text('Produto removido da sacola'),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          title: const Text('Wishlist'),
        ),
        body: _sacola.isNotEmpty
            ? ListView.builder(
                itemCount: _sacola.length,
                itemBuilder: (context, index) {
                  final produto = _sacola[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SizedBox(
                      height: 150,
                      child: Card(
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 150,
                              child: produto.imagem.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          left: Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image:
                                              FileImage(File(produto.imagem)),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  : Container(), // Adicione um Container vazio se não houver imagem
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            SizedBox(
                              width: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    produto.nome,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  (produto.descricao != "")
                                      ? Text(
                                          produto.descricao,
                                          style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w300),
                                        )
                                      : const Text("N/A"),
                                  Text(
                                    "R\$ ${produto.preco.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _removeFromSacola(produto.id),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text("Wishlist Vazia"),
              ));
  }
}
