import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/model_provinsi.dart';
import 'page_kabupaten.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({Key? key}) : super(key: key);

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {
  bool isLoading = false;
  List<Datum> listProvinsi = [];
  List<Datum> filteredProvinsi = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProvinsi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getProvinsi() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("http://192.168.156.142/project_rumah_sakit/getProvinsi.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ModelProvinsi modelProvinsi = ModelProvinsi.fromJson(data);
          listProvinsi = modelProvinsi.data;
          filteredProvinsi = List.from(listProvinsi);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  void searchProvinsi(String query) {
    setState(() {
      filteredProvinsi = listProvinsi.where((provinsi) {
        return provinsi.namaProvinsi.toLowerCase().contains(query.toLowerCase()) ||
            provinsi.id.toLowerCase() == query.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'List Provinsi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: searchProvinsi,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari Provinsi...',
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProvinsi.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageKabupaten(idProv: filteredProvinsi[index].id),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: Stack(
                          children: [
                            Container(
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: LinearGradient(
                                  colors: [Colors.pinkAccent.withOpacity(0.7), Colors.white.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'gambar/rs1.jpeg',
                                      width: 65,
                                    ),
                                  ),
                                  title: Text(
                                    filteredProvinsi[index].namaProvinsi,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
