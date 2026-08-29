import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../services/image_upload_service.dart';
import '../widgets.dart';

class BannerFormScreen extends StatefulWidget {
  const BannerFormScreen({super.key});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final AdminService _admin = AdminService(ApiService());
  final _fk = GlobalKey<FormState>();
  final _imageC = TextEditingController();
  final _titleC = TextEditingController();
  final _subtitleC = TextEditingController();
  final _linkUrlC = TextEditingController();
  final _linkTextC = TextEditingController();
  final _sectionC = TextEditingController(text: 'hero');
  final _sortC = TextEditingController(text: '0');

  String? _editId;
  bool _loading = false, _saving = false, _active = true, _uploading = false;

  @override
  void initState() {
    super.initState();
    _imageC.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editId == null) {
      _editId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_editId != null) _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await _admin.getBanner(_editId!);
      if (mounted) {
        _imageC.text = b.imageUrl;
        _titleC.text = b.title ?? '';
        _subtitleC.text = b.subtitle ?? '';
        _linkUrlC.text = b.linkUrl ?? '';
        _linkTextC.text = b.linkText ?? '';
        _sectionC.text = b.section;
        _sortC.text = b.sortOrder.toString();
        _active = b.isActive;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _imageC.dispose();
    _titleC.dispose();
    _subtitleC.dispose();
    _linkUrlC.dispose();
    _linkTextC.dispose();
    _sectionC.dispose();
    _sortC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'image_url': _imageC.text.trim(),
      if (_titleC.text.trim().isNotEmpty) 'title': _titleC.text.trim(),
      if (_subtitleC.text.trim().isNotEmpty) 'subtitle': _subtitleC.text.trim(),
      if (_linkUrlC.text.trim().isNotEmpty) 'link_url': _linkUrlC.text.trim(),
      if (_linkTextC.text.trim().isNotEmpty) 'link_text': _linkTextC.text.trim(),
      'section': _sectionC.text.trim().isEmpty ? 'hero' : _sectionC.text.trim(),
      'sort_order': int.tryParse(_sortC.text.trim()) ?? 0,
      'is_active': _active,
    };
    try {
      if (_editId != null) {
        await _admin.updateBanner(_editId!, data);
      } else {
        await _admin.createBanner(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()),
          backgroundColor: AppColors.error,
        ));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // Pick, validate and upload an image, then put the returned URL into the
  // image field. Uploading and saving stay decoupled: the admin can still paste
  // an external URL instead, and the form only ever submits image_url.
  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    try {
      final url = await pickValidateAndUploadImage(admin: _admin, specs: ImageSpecs.banner);
      if (url != null && mounted) _imageC.text = url;
    } on ImageUploadException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading
          ? const BrandLoader(label: 'Loading')
          : Column(children: [
              BrandHeader(title: _editId != null ? 'Edit Banner' : 'New Banner'),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(key: _fk, child: Column(children: [
                  FormSection(title: 'Banner Image', children: [
                    const ImageSpecsBox(specs: ImageSpecs.banner),
                    const SizedBox(height: 12),
                    ImageUploadButton(uploading: _uploading, onPressed: _pickAndUpload),
                    const SizedBox(height: 12),
                    StyledInput(
                      controller: _imageC,
                      label: 'Image URL *',
                      hint: 'Upload above, or paste a URL',
                      validator: (v) => v?.trim().isEmpty == true ? 'Upload an image or provide a URL' : null,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  BannerCropPreview(imageUrl: _imageC.value.text.trim()),
                  const SizedBox(height: 16),
                  FormSection(title: 'Details (optional)', children: [
                    StyledInput(controller: _titleC, label: 'Title', hint: 'Shown for accessibility / future overlays'),
                    StyledInput(controller: _subtitleC, label: 'Subtitle', hint: 'Optional'),
                    StyledInput(controller: _linkUrlC, label: 'Link URL', hint: 'Where the banner points (optional)'),
                    StyledInput(controller: _linkTextC, label: 'Link Text', hint: 'e.g. Shop Now (optional)'),
                  ]),
                  const SizedBox(height: 16),
                  FormSection(title: 'Placement', children: [
                    StyledInput(controller: _sectionC, label: 'Section', hint: 'hero'),
                    StyledInput(controller: _sortC, label: 'Sort Order', hint: '0 = first', number: true),
                    ToggleRow(label: 'Active', value: _active, onChanged: (v) => setState(() => _active = v)),
                  ]),
                  const SizedBox(height: 32),
                  FashionButton(
                    label: _editId != null ? 'Update Banner' : 'Create Banner',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 40),
                ])),
              )),
            ]),
    );
  }
}
