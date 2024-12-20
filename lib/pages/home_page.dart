import 'dart:convert';
import 'package:catataja/components/catataja_button.dart';
import 'package:catataja/components/catataja_drawer_navigation.dart';
import 'package:catataja/components/catataja_logo.dart';
import 'package:catataja/components/catataja_note_card.dart';
import 'package:catataja/components/catataja_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _notesFuture;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String searchKeyword = "";
  bool _isSearching = false;

  final String noteUrl = "http://10.0.2.2:8000/api/notes";
  final String searchNotesUrl = "http://10.0.2.2:8000/api/notes/search";

  Future<Map<String, dynamic>> fetchNotes({String? keyword}) async {
    final url = keyword == null ? noteUrl : "$searchNotesUrl?keyword=$keyword";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": widget.token,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load notes");
    }
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Cari Catatan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            onChanged: (value) {
              searchKeyword = value;
            },
            decoration: const InputDecoration(
              hintText: "Masukkan judul atau deskripsi",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _notesFuture = fetchNotes(keyword: searchKeyword);
                  _isSearching = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Cari",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNoteDetails(String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            description,
            style: GoogleFonts.poppins(),
          ),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Tutup",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateOrUpdateNoteModal({Map<String, dynamic>? note}) {
    final isUpdate = note != null;
    final title = isUpdate ? note["title"] : '';
    final description = isUpdate ? note["description"] : '';

    titleController.text = title;
    descriptionController.text = description;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUpdate ? "Perbarui Catatan" : "Buat Catatan Baru",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CatatAjaTextFormField(
                controller: titleController,
                hintText: isUpdate ? '' : 'Judul',
                prefixIcon: const Icon(Icons.format_quote),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              CatatAjaTextFormField(
                controller: descriptionController,
                hintText: isUpdate ? '' : 'Deskripsi',
                prefixIcon: const Icon(Icons.subtitles),
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2.35,
                    child: CatatAjaButton(
                      onPressed: () {
                        titleController.clear();
                        descriptionController.clear();
                        Navigator.pop(context);
                      },
                      color: Theme.of(context).colorScheme.primary,
                      text: "Batal",
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width / 2.35,
                    child: CatatAjaButton(
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            descriptionController.text.isEmpty) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: "Gagal Membuat Catatan",
                            text: "Judul dan deskripsi harus diisi.",
                            confirmBtnColor:
                                Theme.of(context).colorScheme.primary,
                          );
                          return;
                        }

                        if (titleController.text.length > 100) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: "Gagal Membuat Catatan",
                            text: "Judul maksimal 100 karakter.",
                            confirmBtnColor:
                                Theme.of(context).colorScheme.primary,
                          );
                          return;
                        } else if (descriptionController.text.length > 255) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: "Gagal Membuat Catatan",
                            text: "Deskripsi maksimal 255 karakter.",
                            confirmBtnColor:
                                Theme.of(context).colorScheme.primary,
                          );
                          return;
                        }

                        if (isUpdate) {
                          if (titleController.text == note["title"] &&
                              descriptionController.text ==
                                  note["description"]) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              title: "Tidak Ada Perubahan",
                              text:
                                  "Tidak ada perubahan pada judul dan deskripsi.",
                              confirmBtnColor:
                                  Theme.of(context).colorScheme.primary,
                            );
                            return;
                          } else {
                            updateOrTogglePinNote(
                              note["id"],
                              title: titleController.text,
                              description: descriptionController.text,
                            );
                          }
                        } else {
                          createNote(
                            titleController.text,
                            descriptionController.text,
                          );
                        }

                        if (titleController.text != note?["title"] ||
                            descriptionController.text !=
                                note?["description"]) {
                          titleController.clear();
                          descriptionController.clear();
                        }
                        Navigator.pop(context);
                      },
                      color: Theme.of(context).colorScheme.primary,
                      text: "Simpan",
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> createNote(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse(noteUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": widget.token,
        },
        body: json.encode({
          "title": title,
          "description": description,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Berhasil Membuat Catatan",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }

        setState(() {
          _notesFuture = fetchNotes();
        });
      } else {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Gagal Membuat Catatan",
            text: "Terjadi kesalahan pada saat membuat catatan.",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Tidak dapat terhubung ke server.",
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
      }
    }
  }

  Future<void> updateOrTogglePinNote(
    int noteId, {
    String? title,
    String? description,
    String? pinStatus,
  }) async {
    try {
      final body = {
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (pinStatus != null) "pinned": pinStatus,
      };

      final response = await http.put(
        Uri.parse("$noteUrl/$noteId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": widget.token,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        if (pinStatus == null) {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: "Berhasil Memperbarui Catatan",
              confirmBtnColor: Theme.of(context).colorScheme.primary,
            );
          }
        }

        setState(() {
          _notesFuture = fetchNotes();
        });
      } else {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Gagal Memperbarui Catatan",
            text: "Terjadi kesalahan saat memperbarui catatan.",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Tidak dapat terhubung ke server.",
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
      }
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      final response = await http.delete(
        Uri.parse("$noteUrl/$noteId"),
        headers: {
          "Accept": "application/json",
          "Authorization": widget.token,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Berhasil Menghapus Catatan",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );

          FocusScope.of(context).unfocus();
        }

        setState(() {
          _notesFuture = fetchNotes();
        });
      } else {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Gagal Menghapus Catatan",
            text: "Terjadi kesalahan saat menghapus catatan.",
            confirmBtnColor: Theme.of(context).colorScheme.primary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Tidak dapat terhubung ke server.",
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
      }
    }
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = fetchNotes();
      _isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _notesFuture = fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const CatatAjaLogo(fontSize: 35),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshNotes,
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: showSearchDialog,
                ),
        ],
      ),
      drawer: CatatAjaDrawerNavigation(token: widget.token),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isSearching
                        ? "Tidak ada catatan yang sesuai dengan kata kunci Anda."
                        : "Anda belum memiliki catatan.\nAyo buat catatan pertama Anda!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final notes = snapshot.data!;
            final pinnedNotes = notes["pinned"] as List;
            final unpinnedNotes = notes["unpinned"] as List;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  if (pinnedNotes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin),
                          const SizedBox(width: 8),
                          Text(
                            "Dipasangi pin",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (pinnedNotes.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: pinnedNotes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showNoteDetails(
                              pinnedNotes[index]["title"],
                              pinnedNotes[index]["description"],
                            );
                          },
                          child: CatatAjaNoteCard(
                            note: pinnedNotes[index],
                            onPin: () {
                              updateOrTogglePinNote(
                                pinnedNotes[index]["id"],
                                title: pinnedNotes[index]["title"],
                                description: pinnedNotes[index]["description"],
                                pinStatus: "false",
                              );
                            },
                            onEdit: () {
                              _showCreateOrUpdateNoteModal(
                                note: pinnedNotes[index],
                              );
                            },
                            onDelete: () {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: "Hapus Catatan",
                                text:
                                    "Apakah Anda yakin ingin menghapus catatan ini?",
                                confirmBtnColor:
                                    Theme.of(context).colorScheme.primary,
                                confirmBtnText: "Hapus",
                                cancelBtnText: "Batal",
                                showCancelBtn: true,
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                  deleteNote(pinnedNotes[index]["id"]);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  if (unpinnedNotes.isNotEmpty && pinnedNotes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Lainnya",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (unpinnedNotes.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: unpinnedNotes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showNoteDetails(
                              unpinnedNotes[index]["title"],
                              unpinnedNotes[index]["description"],
                            );
                          },
                          child: CatatAjaNoteCard(
                            note: unpinnedNotes[index],
                            onPin: () {
                              updateOrTogglePinNote(
                                unpinnedNotes[index]["id"],
                                title: unpinnedNotes[index]["title"],
                                description: unpinnedNotes[index]
                                    ["description"],
                                pinStatus: "true",
                              );
                            },
                            onEdit: () {
                              _showCreateOrUpdateNoteModal(
                                note: unpinnedNotes[index],
                              );
                            },
                            onDelete: () {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: "Hapus Catatan",
                                text:
                                    "Apakah Anda yakin ingin menghapus catatan ini?",
                                confirmBtnColor:
                                    Theme.of(context).colorScheme.primary,
                                confirmBtnText: "Hapus",
                                cancelBtnText: "Batal",
                                showCancelBtn: true,
                                onConfirmBtnTap: () {
                                  Navigator.pop(context);
                                  deleteNote(unpinnedNotes[index]["id"]);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                "Tidak ada data yang tersedia",
                style: GoogleFonts.poppins(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrUpdateNoteModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
