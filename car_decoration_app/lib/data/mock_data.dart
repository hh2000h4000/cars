import '../models/models.dart';

class MockData {
  static final List<Shop> shops = [
    Shop(
      id: 'sh1',
      name: 'لمسات الفخامة',
      mono: 'ل',
      area: 'العليا، الرياض',
      city: 'الرياض',
      address: 'حي العليا، طريق الملك فهد',
      description:
          'مركز متخصص في تزيين وحماية السيارات الفاخرة منذ ٢٠١٦. نقدّم خدمة منزلية متنقلة بأحدث المواد العالمية وفريق فني معتمد، مع ضمان موثّق على جميع الأعمال.',
      rating: 4.9,
      reviewCount: 218,
      completedJobs: 312,
      distance: '2.4 كم',
      tags: ['تظليل', 'حماية PPF', 'تلميع'],
      services: [
        const ShopService(name: 'تظليل حراري كامل', price: 1200, duration: '٢-٣ ساعات', description: 'أفلام 3M Crystalline'),
        const ShopService(name: 'أفلام حماية PPF', price: 2500, duration: '٤-٦ ساعات', description: 'XPEL Ultimate Plus'),
        const ShopService(name: 'تلميع نانو سيراميك', price: 800, duration: '٣ ساعات'),
        const ShopService(name: 'تنظيف وتعقيم شامل', price: 250, duration: 'ساعة'),
        const ShopService(name: 'إضاءة LED داخلية', price: 450, duration: 'ساعتان'),
      ],
      gallery: ['تلميع نانو', 'تظليل حراري', 'حماية PPF', 'إضاءة داخلية', 'تنظيف مقصورة', 'جلسة جلد'],
      verified: true,
      reviews: [
        const ShopReview(author: 'فيصل الشمري', mono: 'ف', rating: 5.0, comment: 'احترافية عالية وأسلوب راقٍ، نفّذوا التظليل في موقعي بإتقان تام.', date: 'قبل ٣ أيام'),
        const ShopReview(author: 'منى العنزي', mono: 'م', rating: 5.0, comment: 'النتيجة فاقت التوقعات، التزام بالموعد ونظافة كاملة بعد العمل.', date: 'قبل أسبوع'),
        const ShopReview(author: 'تركي الحربي', mono: 'ت', rating: 4.0, comment: 'خدمة ممتازة وجودة تستحق، تأخروا قليلاً عن الموعد فقط.', date: 'قبل أسبوعين'),
      ],
    ),
    Shop(
      id: 'sh5',
      name: 'ماسة كار',
      mono: 'م',
      area: 'الملقا، الرياض',
      city: 'الرياض',
      address: 'حي الملقا، طريق أنس بن مالك',
      description: 'خبرة ١٠ سنوات في تزيين السيارات الفاخرة. نستخدم أفضل المواد العالمية ونضمن جودة الأعمال.',
      rating: 4.9,
      reviewCount: 301,
      completedJobs: 410,
      distance: '1.8 كم',
      tags: ['تلميع نانو', 'تنظيف', 'إضاءة'],
      services: [
        const ShopService(name: 'تلميع نانو سيراميك', price: 900, duration: '٣ ساعات'),
        const ShopService(name: 'تنظيف داخلي وخارجي', price: 300, duration: 'ساعتان'),
        const ShopService(name: 'إضاءة LED', price: 500, duration: 'ساعتان'),
        const ShopService(name: 'حماية دهان', price: 1800, duration: '٤ ساعات'),
      ],
      gallery: ['تلميع سيراميك', 'تنظيف عميق', 'إضاءة أمبيانس', 'حماية دهان', 'تلميع عجلات', 'إضاءة خارجية'],
      verified: true,
      reviews: [
        const ShopReview(author: 'أحمد الدوسري', mono: 'أ', rating: 5.0, comment: 'أفضل تجربة تلميع جربتها. النتيجة رائعة.', date: 'قبل يومين'),
        const ShopReview(author: 'سارة القحطاني', mono: 'س', rating: 5.0, comment: 'فريق محترف ومنضبط. التزموا بالوقت تماماً.', date: 'قبل أسبوع'),
      ],
    ),
    Shop(
      id: 'sh2',
      name: 'بريق الخليج',
      mono: 'ب',
      area: 'النخيل، الرياض',
      city: 'الرياض',
      address: 'حي النخيل، شارع التحلية',
      description: 'متخصصون في التظليل والصوتيات. نقدم أحدث أنظمة الصوت وأفضل أفلام التظليل الحراري.',
      rating: 4.8,
      reviewCount: 176,
      completedJobs: 256,
      distance: '3.1 كم',
      tags: ['تظليل', 'صوتيات'],
      services: [
        const ShopService(name: 'تظليل حراري', price: 800, duration: 'ساعتان'),
        const ShopService(name: 'أنظمة صوتية', price: 2000, duration: '٣-٥ ساعات'),
        const ShopService(name: 'شاشات وكاميرات', price: 1500, duration: '٣ ساعات'),
      ],
      gallery: ['تظليل حراري', 'نظام صوتي', 'شاشة أمامية', 'كاميرا خلفية', 'سماعات', 'تظليل جانبي'],
      verified: true,
      reviews: [
        const ShopReview(author: 'خالد العمري', mono: 'خ', rating: 5.0, comment: 'أفضل نظام صوتي ركّبته. الصوت رهيب!', date: 'قبل ٥ أيام'),
      ],
    ),
    Shop(
      id: 'sh3',
      name: 'النخبة لكماليات السيارات',
      mono: 'ن',
      area: 'الملقا، الرياض',
      city: 'الرياض',
      address: 'حي الملقا، طريق الملك سلمان',
      description: 'متخصصون في الجلود الفاخرة وأنظمة الإضاءة المتطورة لجميع أنواع السيارات.',
      rating: 4.7,
      reviewCount: 132,
      completedJobs: 198,
      distance: '4.6 كم',
      tags: ['جلود', 'إضاءة'],
      services: [
        const ShopService(name: 'تلبيس جلد فاخر', price: 3500, duration: 'يوم كامل'),
        const ShopService(name: 'إضاءة أمبيانس', price: 600, duration: 'ساعتان'),
        const ShopService(name: 'إضاءة LED داخلية', price: 400, duration: 'ساعة'),
      ],
      gallery: ['جلد بني', 'جلد أسود', 'إضاءة أمبيانس', 'سقف نجمي', 'مقاعد جلد', 'إضاءة أرضية'],
      verified: true,
      reviews: [
        const ShopReview(author: 'نورة السبيعي', mono: 'ن', rating: 5.0, comment: 'تلبيس الجلد رائع جداً. جودة عالية وإتقان في التفاصيل.', date: 'قبل أسبوعين'),
      ],
    ),
    Shop(
      id: 'sh4',
      name: 'درع الحماية',
      mono: 'د',
      area: 'قرطبة، الرياض',
      city: 'الرياض',
      address: 'حي قرطبة، الطريق الدائري الشمالي',
      description: 'خبراء في أفلام حماية الدهان والتلميع الاحترافي. نستخدم أفضل المنتجات العالمية.',
      rating: 4.6,
      reviewCount: 98,
      completedJobs: 142,
      distance: '5.2 كم',
      tags: ['أفلام حماية', 'تلميع'],
      services: [
        const ShopService(name: 'أفلام حماية PPF', price: 2200, duration: '٤ ساعات'),
        const ShopService(name: 'تلميع سيراميك', price: 750, duration: '٣ ساعات'),
        const ShopService(name: 'إزالة خدوش', price: 350, duration: 'ساعة'),
      ],
      gallery: ['PPF كامل', 'تلميع احترافي', 'حماية مقدمة', 'إزالة خدوش', 'PPF جزئي', 'تلميع عجلات'],
      verified: true,
      reviews: [
        const ShopReview(author: 'سلطان العتيبي', mono: 'س', rating: 4.0, comment: 'عمل جيد وسعر مناسب. ينصح بهم.', date: 'قبل شهر'),
      ],
    ),
  ];

  static final List<Vehicle> vehicles = [
    const Vehicle(id: 'v1', brand: 'تويوتا', model: 'لاند كروزر', year: 2023, color: 'أبيض لؤلؤي', plateNumber: 'ر ب ح ٤٨٢١', mono: 'LC', isMain: true),
    const Vehicle(id: 'v2', brand: 'لكزس', model: 'LX 600', year: 2024, color: 'أسود', plateNumber: 'أ د ل ٩٠٣٢', mono: 'LX'),
    const Vehicle(id: 'v3', brand: 'مرسيدس', model: 'G-Class', year: 2022, color: 'رمادي معدني', mono: 'G'),
  ];

  static final List<ServiceRequest> requests = [
    const ServiceRequest(
      id: '1042',
      serviceType: 'تظليل كامل + فيلم حماية أمامي',
      vehicleBrand: 'تويوتا', vehicleModel: 'لاند كروزر', vehicleYear: 2023, vehicleColor: 'أبيض لؤلؤي',
      status: RequestStatus.offers,
      dateLabel: '٢٢ يونيو',
      quotationCount: 3,
      notes: 'أريد تظليل النوافذ الجانبية والخلفية بنسبة ٥٠٪ وتظليل خفيف للزجاج الأمامي. مع فيلم حماية شفاف للواجهة الأمامية.',
    ),
    const ServiceRequest(
      id: '1038',
      serviceType: 'تلميع نانو سيراميك',
      vehicleBrand: 'لكزس', vehicleModel: 'LX 600', vehicleYear: 2024, vehicleColor: 'أسود',
      status: RequestStatus.inProgress,
      dateLabel: '١٨ يونيو',
      selectedShopName: 'لمسات الفخامة',
    ),
    const ServiceRequest(
      id: '1051',
      serviceType: 'نظام إضاءة داخلي LED',
      vehicleBrand: 'مرسيدس', vehicleModel: 'G-Class', vehicleYear: 2022, vehicleColor: 'رمادي معدني',
      status: RequestStatus.pending,
      dateLabel: '٢٤ يونيو',
    ),
    const ServiceRequest(
      id: '0998',
      serviceType: 'تلميع خارجي شامل',
      vehicleBrand: 'تويوتا', vehicleModel: 'لاند كروزر', vehicleYear: 2023, vehicleColor: 'أبيض لؤلؤي',
      status: RequestStatus.disputed,
      dateLabel: '١٠ يونيو',
    ),
  ];

  static List<Quotation> get quotations => [
    Quotation(
      id: 'q1', shopId: 'sh1', shopName: 'لمسات الفخامة', shopMono: 'ل', shopRating: 4.9,
      price: 1850, visitFee: 'مجاناً', warranty: '٢٤ شهراً', executionTime: '٣ ساعات',
      serviceDetails: 'تظليل حراري كامل بنسبة ٥٠٪ للجوانب و٧٠٪ للزجاج الأمامي، مع تركيب فيلم حماية شفاف (PPF) على الواجهة الأمامية بالكامل. يشمل التنظيف والتجهيز قبل التركيب.',
      parts: ['فيلم تظليل حراري 3M Crystalline أصلي', 'فيلم حماية أمامي XPEL Ultimate Plus', 'مواد تنظيف احترافية'],
      isBestValue: true,
    ),
    Quotation(
      id: 'q2', shopId: 'sh5', shopName: 'ماسة كار', shopMono: 'م', shopRating: 4.9,
      price: 2100, visitFee: '50 ر.س', warranty: '٣٦ شهراً', executionTime: 'ساعتان',
      serviceDetails: 'تظليل حراري بأفلام XPEL Prime XR Plus مع حماية شاملة للواجهة الأمامية.',
      parts: ['XPEL Prime XR Plus - جودة عالية جداً', 'مواد تجهيز احترافية'],
    ),
    Quotation(
      id: 'q3', shopId: 'sh2', shopName: 'بريق الخليج', shopMono: 'ب', shopRating: 4.8,
      price: 1650, visitFee: 'مجاناً', warranty: '١٢ شهراً', executionTime: '٤ ساعات',
      serviceDetails: 'تظليل سيراميكي عالي الجودة مع حماية أساسية للواجهة الأمامية.',
      parts: ['فيلم تظليل سيراميك محلي عالي الجودة'],
    ),
  ];

  static final List<ChatMessage> initialMessages = [
    const ChatMessage(id: '1', isMe: false, text: 'أهلاً وسهلاً، معك فريق لمسات الفخامة. اطّلعنا على طلبك لتظليل اللاند كروزر.', time: '10:24'),
    const ChatMessage(id: '2', isMe: false, text: 'تفضّل بإرسال صورة للزجاج الأمامي إن أمكن لتحديد المقاس بدقة.', time: '10:24'),
    const ChatMessage(id: '3', isMe: true, text: 'تم، أرسلت الصور. كم يستغرق التنفيذ في موقعي؟', time: '10:31'),
    const ChatMessage(id: '4', isMe: true, text: 'الزجاج الأمامي', time: '10:31', hasImage: true),
    const ChatMessage(id: '5', isMe: false, text: 'ساعتان إلى ثلاث ساعات في موقعك. سنرسل لك عرض السعر الرسمي الآن.', time: '10:33'),
  ];

  static final List<ShopInboxItem> shopInbox = [
    const ShopInboxItem(requestId: '1042', customerName: 'عبدالله الحربي', mono: 'ع', serviceType: 'تظليل كامل + فيلم حماية أمامي', vehicleInfo: 'لاند كروزر 2023', distance: '2.4 كم', timeAgo: 'قبل ١٠ دقائق', area: 'العليا', urgency: 'high'),
    const ShopInboxItem(requestId: '1044', customerName: 'خالد المطيري', mono: 'خ', serviceType: 'تلميع نانو سيراميك', vehicleInfo: 'GMC يوكن 2023', distance: '6.1 كم', timeAgo: 'قبل ٢٥ دقيقة', area: 'النرجس'),
    const ShopInboxItem(requestId: '1039', customerName: 'ريم الزهراني', mono: 'ر', serviceType: 'تركيب إضاءة داخلية', vehicleInfo: 'رنج روفر 2022', distance: '3.8 كم', timeAgo: 'قبل ساعة', area: 'الياسمين'),
  ];

  static List<PendingShop> get pendingShops => [
    PendingShop(
      id: 'p1', name: 'مركز القمة للسيارات',
      ownerName: 'سعود القحطاني', phone: '+966 55 234 5678',
      crNumber: '1010453221', city: 'جدة',
      submittedAt: 'منذ ساعتين', hasCompleteDocs: true,
      services: ['تظليل', 'حماية PPF', 'تلميع'],
    ),
    PendingShop(
      id: 'p2', name: 'بصمة احتراف',
      ownerName: 'ماجد العتيبي', phone: '+966 50 987 6543',
      crNumber: '1010889076', city: 'الرياض',
      submittedAt: 'منذ ٥ ساعات', hasCompleteDocs: true,
      services: ['جلود', 'إضاءة', 'صوتيات'],
    ),
    PendingShop(
      id: 'p3', name: 'درع الذهب للسيارات',
      ownerName: 'فهد الدوسري', phone: '+966 56 111 2233',
      crNumber: '—', city: 'الدمام',
      submittedAt: 'أمس', hasCompleteDocs: false,
      services: ['تلميع', 'تنظيف'],
      status: AdminShopStatus.docsRequested,
    ),
  ];

  static final List<Dispute> disputes = [
    const Dispute(
      id: 'DP-203', reason: 'تغيّر السعر عند الوصول',
      description: 'اتفقنا على سعر محدد في العرض ولكن عند وصول الفريق تغيّر السعر بدون إشعار مسبق.',
      requestId: '#0998', customerName: 'عبدالله الحربي', shopName: 'بريق الخليج',
      submittedAt: 'قبل يومين', status: DisputeStatus.underReview, severity: DisputeSeverity.high,
    ),
    const Dispute(
      id: 'DP-198', reason: 'تأخر الوصول عن الموعد',
      description: 'تأخر الفريق أكثر من ٣ ساعات عن الموعد المحدد دون أي إشعار.',
      requestId: '#0971', customerName: 'نورة السبيعي', shopName: 'النخبة',
      submittedAt: 'قبل ٤ أيام', status: DisputeStatus.waitingShop, severity: DisputeSeverity.medium,
    ),
    const Dispute(
      id: 'DP-186', reason: 'اختلاف الخدمة المنفّذة',
      description: 'الخدمة المنفّذة كانت مختلفة عن ما تم الاتفاق عليه في العرض الرسمي.',
      requestId: '#0944', customerName: 'سلطان العتيبي', shopName: 'درع الحماية',
      submittedAt: 'قبل أسبوعين', status: DisputeStatus.resolved, severity: DisputeSeverity.low,
    ),
  ];

  static const List<String> complaintReasons = [
    'تغيّر السعر',
    'تأخر الوصول',
    'عدم الحضور',
    'جودة رديئة',
    'خدمة مختلفة',
    'سبب آخر',
  ];

  static const List<String> serviceCategories = [
    'تظليل', 'حماية PPF', 'تلميع', 'تنظيف',
    'إضاءة', 'صوتيات', 'جلود', 'ملصقات',
  ];
}
