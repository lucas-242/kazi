import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi_core/kazi_core.dart';

class KaziImagePicker extends StatefulWidget {
  const KaziImagePicker({
    super.key,
    required this.onChange,
  });
  final ValueChanged<Uint8List> onChange;

  @override
  State<KaziImagePicker> createState() => _KaziImagePickerState();
}

class _KaziImagePickerState extends State<KaziImagePicker> {
  final _picker = ImagePicker();
  Image? _image;

  Future<void> _onTap() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
    );

    if (pickedFile == null) return;

    _image = kIsWeb
        ? Image.network(pickedFile.path)
        : Image.file(File(pickedFile.path));

    setState(() {});

    final bytes = await pickedFile.readAsBytes();
    widget.onChange(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: _onTap,
      child: Column(
        spacing: KaziInsets.md,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(100),
                  image: _image != null
                      ? DecorationImage(image: _image!.image, fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? const Icon(Icons.photo_camera, size: 38)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: colors.brand.fill,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _image == null ? Icons.add : Icons.rotate_right,
                      color: colors.brand.onFill,
                    ),
                    onPressed: _onTap,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _image == null
                ? 'Clique para adicionar uma foto'
                : 'Clique para alterar a foto',
            style: KaziTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
