import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../config/theme.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../services/image_upload_service.dart';
import '../widgets.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final AdminService _admin = AdminService(ApiService());
  final _fk = GlobalKey<FormState>();
  final _nc = TextEditingController();
  final _dc = TextEditingController();
  final _ic = TextEditingController();

  String? _editId;
  bool _loading = false, _saving = false, _active = true, _uploading = false;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _ic.addListener(() {
      final trimmed = _ic.text.trim();
      if (trimmed != _imageUrl) setState(() => _imageUrl = trimmed);
    });
  }

  String? _parentId;
  String? _gender;
  String _slug = '';
  List<AdminCategory> _allCats = [];
  bool _catsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editId == null) {
      _editId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_editId != null) _load();
    }
    if (!_catsLoaded) _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      final c = await _admin.getCategories();
      if (mounted) setState(() { _allCats = c; _catsLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _catsLoaded = true);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      AdminCategory? cat;
      try {
        cat = await _admin.getCategory(_editId!);
      } catch (_) {
        final c = await _admin.getCategories();
        cat = c.where((x) => x.id == _editId).firstOrNull;
      }
      if (mounted && cat != null) {
        _nc.text = cat.name;
        _dc.text = cat.description ?? '';
        _ic.text = cat.imageUrl ?? '';
        _slug = cat.slug;
        _parentId = cat.parentId;
        _gender = cat.gender;
        _active = cat.isActive;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  static const _specificGenders = ['men', 'women', 'kids'];

  /// The effective gender for a category given its parent, resolved the same
  /// way the backend does: an explicitly chosen real gender wins, otherwise we
  /// inherit it from the parent (by the parent's gender or its main-category
  /// name), otherwise the category's own name, otherwise unisex.
  String _genderFromParent(String? parentId) {
    if (parentId == null) return '';
    final parent = _allCats.where((c) => c.id == parentId).firstOrNull;
    if (parent == null) return '';
    final pg = parent.gender?.toLowerCase();
    if (pg != null && _specificGenders.contains(pg)) return pg;
    final pn = parent.name.trim().toLowerCase();
    if (_specificGenders.contains(pn)) return pn;
    return '';
  }

  String _resolveGender() {
    if (_gender != null && _specificGenders.contains(_gender!.toLowerCase())) {
      return _gender!.toLowerCase();
    }
    final fromParent = _genderFromParent(_parentId);
    if (fromParent.isNotEmpty) return fromParent;
    final name = _nc.text.trim().toLowerCase();
    if (_specificGenders.contains(name)) return name;
    return _gender ?? 'unisex';
  }

  @override void dispose() { _nc.dispose(); _dc.dispose(); _ic.dispose(); super.dispose(); }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  /// Pulls the API's `detail` message out of a request failure so the admin
  /// sees the real reason (e.g. "A category named 'jeans' already exists")
  /// instead of a raw DioException dump.
  String _errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] is String) return data['detail'] as String;
      if (data is String && data.isNotEmpty) return data;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Check your network.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No internet connection.';
      }
    }
    return e.toString();
  }

  // Pick, validate and upload an image, then put the returned URL into the
  // image field. The admin can still paste an external URL instead.
  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    try {
      final url = await pickValidateAndUploadImage(admin: _admin, specs: ImageSpecs.category);
      if (url != null && mounted) _ic.text = url;
    } on ImageUploadException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final resolvedGender = _resolveGender();
    try {
      if (_editId != null) {
        await _admin.updateCategory(_editId!, {
          'name': _nc.text.trim(),
          if (_slug.isNotEmpty) 'slug': _slug,
          if (_dc.text.trim().isNotEmpty) 'description': _dc.text.trim(),
          // Sent even when empty (as null) so clearing the image actually
          // removes it — and lets the backend delete the S3 object.
          'image_url': _ic.text.trim().isEmpty ? null : _ic.text.trim(),
          'is_active': _active,
          'gender': resolvedGender,
          if (_parentId != null) 'parent_id': _parentId,
        });
      } else {
        final categoryName = _nc.text.trim();
        final newCat = await _admin.createCategory({
          'name': categoryName,
          'slug': _slug.isNotEmpty
              ? _slug
              : categoryName.toLowerCase().replaceAll(' ', '-'),
          if (_dc.text.trim().isNotEmpty) 'description': _dc.text.trim(),
          if (_ic.text.trim().isNotEmpty) 'image_url': _ic.text.trim(),
          'gender': resolvedGender,
          if (_parentId != null) 'parent_id': _parentId,
        });
        final isMain = AdminCategory.mainCategoryNames.any(
          (n) => n.toLowerCase() == categoryName.toLowerCase(),
        );
        if (_parentId == null && isMain) {
          final gender = categoryName.toLowerCase();
          await _admin.createCategory({'name': 'All', 'slug': '$gender-all', 'gender': gender, 'parent_id': newCat.id});
          await _admin.createCategory({'name': categoryName, 'slug': '$gender-$gender', 'gender': gender, 'parent_id': newCat.id});
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_editId != null ? 'Category updated' : 'Category created'),
          backgroundColor: AppColors.success,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError(_errorMessage(e));
    }
    if (mounted) setState(() => _saving = false);
  }

  List<DropdownMenuItem<String>> get _parentItems {
    final parents = _allCats.where((c) => c.isParent && c.id != _editId).toList();
    return [
      DropdownMenuItem<String>(value: null, child: Text('None (Top-level)', style: TextStyle(color: AppColors.textMuted))),
      ...parents.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name, style: TextStyle(color: AppColors.textPrimary)))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading
        ? const BrandLoader(label: 'Loading')
        : Column(children: [
            BrandHeader(title: _editId != null ? 'Edit Category' : 'New Category'),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
              FormSection(title: 'Category Info', children: [
                StyledInput(controller: _nc, label: 'Category Name *', validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                StyledInput(controller: _dc, label: 'Description', maxLines: 3, hint: 'Optional'),
                const ImageSpecsBox(specs: ImageSpecs.category),
                const SizedBox(height: 12),
                ImageUploadButton(uploading: _uploading, onPressed: _pickAndUpload),
                const SizedBox(height: 12),
                StyledInput(controller: _ic, label: 'Image URL', hint: 'Upload above, or paste a URL'),
                if (_imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity, height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.bgAlt, AppColors.surfaceAlt], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            border: Border.all(color: AppColors.border, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                              imageUrl: _imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 140,
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral)),
                              errorWidget: (_, __, ___) => Center(child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 36)),
                            ),
                          ),
                        ),
                        Positioned(top: 6, right: 6,
                          child: GestureDetector(
                            onTap: () => _ic.clear(),
                              child: Container(
                                width: 28, height: 28,
                                decoration: AppColors.premiumGoldDeco(radius: 6),
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                StyledDropdown(
                  label: 'Parent Category',
                  value: _parentId,
                  items: _parentItems,
                  onChanged: (v) {
                    setState(() {
                      _parentId = v;
                      final inherited = _genderFromParent(v);
                      if (inherited.isNotEmpty) _gender = inherited;
                    });
                  },
                ),
                StyledDropdown(
                  label: 'Gender',
                  value: _gender,
                  items: AdminCategory.genderOptions.map((g) => DropdownMenuItem<String>(
                    value: g,
                    child: Text(g[0].toUpperCase() + g.substring(1), style: TextStyle(color: AppColors.textPrimary)),
                  )).toList(),
                  onChanged: (v) => setState(() => _gender = v),
                ),
                Row(children: [
                  if (_editId != null)
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text('Slug: ${_slug.isEmpty ? 'auto' : _slug}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    )),
                  ToggleRow(label: 'Active', value: _active, onChanged: (v) => setState(() => _active = v)),
                ]),
              ]),
              const SizedBox(height: 16),
              if (_parentId == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.surface, AppColors.surfaceAlt]),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('No parent = top-level category. Subcategories can be assigned below it.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11))),
                  ]),
                ),
              const SizedBox(height: 32),
              FashionButton(label: _editId != null ? 'Update Category' : 'Create Category', loading: _saving, onPressed: _saving ? null : _save),
              const SizedBox(height: 40),
            ])))),
          ]),
    );
  }
}
