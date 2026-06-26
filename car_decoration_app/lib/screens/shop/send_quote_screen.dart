import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/shop_request.dart';
import '../../services/quotation_service.dart';

class SendQuoteScreen extends StatefulWidget {
  final ShopRequest request;
  const SendQuoteScreen({super.key, required this.request});

  @override
  State<SendQuoteScreen> createState() => _SendQuoteScreenState();
}

class _SendQuoteScreenState extends State<SendQuoteScreen> {
  final _priceController = TextEditingController();
  final _visitFeeController = TextEditingController(text: '0');
  final _durationController = TextEditingController();
  final _detailsController = TextEditingController();
  String _warranty = '';
  final List<String> _parts = [];
  final _partController = TextEditingController();
  bool _submitting = false;

  static const _warrantyOptions = ['بدون ضمان', '٦ أشهر', 'سنة', 'سنتان'];

  @override
  void dispose() {
    _priceController.dispose();
    _visitFeeController.dispose();
    _durationController.dispose();
    _detailsController.dispose();
    _partController.dispose();
    super.dispose();
  }

  void _addPart() {
    final text = _partController.text.trim();
    if (text.isEmpty) return;
    setState(() { _parts.add(text); _partController.clear(); });
  }

  void _removePart(int index) => setState(() => _parts.removeAt(index));

  Future<void> _submit() async {
    final priceStr = _priceController.text.trim();
    final duration = _durationController.text.trim();
    final details = _detailsController.text.trim();

    if (priceStr.isEmpty) {
      _showError('يرجى إدخال السعر الإجمالي');
      return;
    }
    if (duration.isEmpty) {
      _showError('يرجى إدخال مدة التنفيذ');
      return;
    }
    if (details.isEmpty) {
      _showError('يرجى إدخال تفاصيل الخدمة');
      return;
    }

    final price = double.tryParse(priceStr.replaceAll(',', ''));
    if (price == null || price <= 0) {
      _showError('السعر غير صحيح');
      return;
    }

    final visitFee = double.tryParse(_visitFeeController.text.trim()) ?? 0;

    setState(() => _submitting = true);
    try {
      await QuotationService.sendQuote(
        requestId: widget.request.id,
        finalPrice: price,
        duration: duration,
        serviceDetails: details,
        parts: _parts.isEmpty ? 'غير محدد' : _parts.join('، '),
        visitFee: visitFee,
        warranty: _warranty.isEmpty || _warranty == 'بدون ضمان' ? null : _warranty,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إرسال العرض بنجاح — في انتظار رد العميل',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showError('فشل إرسال العرض. حاول مجدداً.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Text('إرسال عرض سعر',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Request summary
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: AppColors.goldBg,
                  border: Border.all(color: AppColors.goldLight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: AppColors.goldText, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.customerName,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          Text(r.vehicleInfo,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              _Label('السعر الإجمالي (ريال)'),
              _InputBox(controller: _priceController, hint: 'مثال: 1850', large: true, keyboardType: TextInputType.number),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('رسوم الزيارة'),
                        _InputBox(controller: _visitFeeController, hint: '0', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('مدة التنفيذ'),
                        _InputBox(controller: _durationController, hint: 'مثال: ٣-٤ ساعات'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _Label('مدة الضمان'),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _warrantyOptions.map((w) {
                    final sel = _warranty == w;
                    return GestureDetector(
                      onTap: () => setState(() => _warranty = w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.goldBg : Colors.white,
                          border: Border.all(color: sel ? AppColors.goldLight : AppColors.border),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(w,
                          style: TextStyle(
                            fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: sel ? AppColors.goldText : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              _Label('تفاصيل الخدمة'),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _detailsController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.6),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'صف الخدمة التي ستقدمها...',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              _Label('المواد والقطع المستخدمة'),
              ..._parts.asMap().entries.map((e) => _PartRow(
                text: e.value,
                onRemove: () => _removePart(e.key),
              )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _partController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'أضف مادة...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                        ),
                        onSubmitted: (_) => _addPart(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _addPart,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        border: Border.all(color: AppColors.goldLight),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.add, color: AppColors.goldText, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              DarkButton(
                label: _submitting ? 'جاري الإرسال...' : 'إرسال العرض',
                onTap: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text,
      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool large;
  final TextInputType keyboardType;
  const _InputBox({required this.controller, required this.hint, this.large = false, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => Container(
    height: large ? 58 : 48,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: large ? 20 : 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
      ),
    ),
  );
}

class _PartRow extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;
  const _PartRow({required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(text,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.remove_circle_outline, color: AppColors.red, size: 16),
        ),
      ],
    ),
  );
}
