// service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

/// Holds the picked image data (preview + Cloudinary URL)
class PickedImage {
  final Uint8List bytes;   // For preview with Image.memory()
  final String url;        // Cloudinary URL to save in Firestore

  PickedImage({required this.bytes, required this.url});
}

class CloudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  // MAKE SURE this preset is UNSIGNED in Cloudinary console!
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dpistlbgu',              // ← Your real Cloud Name
    'flutter_notes_preset',   // ← Your unsigned preset name
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  /// Pick image + upload to Cloudinary – works on Web, Android & iOS
  Future<PickedImage?> pickImageForAddItem() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 88,
      );

      if (pickedFile == null) return null;

      // This line works on Web too!
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Correct way to upload bytes in cloudinary_public ^0.23.x
      final CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: 'note_${DateTime.now().millisecondsSinceEpoch}',
          resourceType: CloudinaryResourceType.Image,
          // folder: 'notes_app',        // optional
          // fileName: 'note.jpg',       // optional
        ),
      );

      return PickedImage(
        bytes: imageBytes,
        url: response.secureUrl!,
      );
    } catch (e, s) {
      print('Image upload error: $e');
      print(s);
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Firestore CRUD (unchanged)
  // ──────────────────────────────────────────────────────────────
  Future<void> addItemWithImage(String name, int quantity, String? imageUrl) async {
    await items.add({
      'name': name.trim(),
      'quantity': quantity,
      'image_url': imageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateItem(String id, String name, int quantity) async {
    await items.doc(id).update({
      'name': name.trim(),
      'quantity': quantity,
    });
  }

  Future<void> deleteItem(String id) async {
    await items.doc(id).delete();
  }
}