import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/home/domain/enums/meal_type.dart';

class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context));

  String get _code => locale.languageCode.toLowerCase();

  String get adminRestaurantTitle => switch (_code) {
    'en' => 'Restaurant administration',
    'ar' => 'إدارة المطعم',
    _ => 'Administration du restaurant',
  };

  String get adminRestaurantSubtitle => switch (_code) {
    'en' => 'Manage meals, access, and reports from one unified space.',
    'ar' => 'إدارة الوجبات والوصول والتقارير من مساحة موحدة.',
    _ =>
      'Pilotez les repas, les accès et les rapports depuis un espace unifié.',
  };

  String get adminLoginTitle => switch (_code) {
    'en' => 'Administration login',
    'ar' => 'تسجيل دخول الإدارة',
    _ => 'Connexion Administration',
  };

  String get adminLoginSubtitle => switch (_code) {
    'en' => 'Sign in to access the administration panel.',
    'ar' => 'سجّل الدخول للوصول إلى لوحة الإدارة.',
    _ => 'Connectez-vous pour accéder au panneau d\'administration.',
  };

  String get backToKiosk => switch (_code) {
    'en' => 'Back to kiosk home',
    'ar' => 'العودة إلى شاشة الكشك',
    _ => 'Retour à l\'accueil kiosque',
  };

  String get emailAddress => switch (_code) {
    'en' => 'Email address',
    'ar' => 'عنوان البريد الإلكتروني',
    _ => 'Adresse email',
  };

  String get password => switch (_code) {
    'en' => 'Password',
    'ar' => 'كلمة المرور',
    _ => 'Mot de passe',
  };

  String get showPassword => switch (_code) {
    'en' => 'Show password',
    'ar' => 'إظهار كلمة المرور',
    _ => 'Afficher le mot de passe',
  };

  String get hidePassword => switch (_code) {
    'en' => 'Hide password',
    'ar' => 'إخفاء كلمة المرور',
    _ => 'Masquer le mot de passe',
  };

  String get emailRequired => switch (_code) {
    'en' => 'Email is required',
    'ar' => 'البريد الإلكتروني مطلوب',
    _ => 'L\'email est requis',
  };

  String get invalidEmail => switch (_code) {
    'en' => 'Invalid email format',
    'ar' => 'تنسيق البريد الإلكتروني غير صالح',
    _ => 'Format d\'email invalide',
  };

  String get passwordRequired => switch (_code) {
    'en' => 'Password is required',
    'ar' => 'كلمة المرور مطلوبة',
    _ => 'Le mot de passe est requis',
  };

  String get min8Characters => switch (_code) {
    'en' => 'Minimum 8 characters',
    'ar' => '8 أحرف على الأقل',
    _ => 'Minimum 8 caractères',
  };

  String get administration => switch (_code) {
    'en' => 'Administration',
    'ar' => 'الإدارة',
    _ => 'Administration',
  };

  String get dashboard => switch (_code) {
    'en' => 'Dashboard',
    'ar' => 'لوحة التحكم',
    _ => 'Tableau de bord',
  };

  String get management => switch (_code) {
    'en' => 'MANAGEMENT',
    'ar' => 'الإدارة',
    _ => 'GESTION',
  };

  String get logout => switch (_code) {
    'en' => 'Sign out',
    'ar' => 'تسجيل الخروج',
    _ => 'Déconnexion',
  };

  String get administrator => switch (_code) {
    'en' => 'Administrator',
    'ar' => 'المسؤول',
    _ => 'Administrateur',
  };

  String adminSectionLabel(String section) => switch (_code) {
    'en' => switch (section) {
      'employees' => 'Employees',
      'interns' => 'Interns',
      'visitors' => 'Visitors',
      'qrCodes' => 'QR codes',
      'faceEnrollment' => 'Faces',
      'mealHistory' => 'Meals',
      'receipts' => 'Receipts',
      'statistics' => 'Statistics',
      'reports' => 'Reports',
      'users' => 'Users',
      'settings' => 'Settings',
      'audit' => 'Audit log',
      _ => section,
    },
    'ar' => switch (section) {
      'employees' => 'الموظفون',
      'interns' => 'المتدربون',
      'visitors' => 'الزوار',
      'qrCodes' => 'رموز QR',
      'faceEnrollment' => 'الوجوه',
      'mealHistory' => 'الوجبات',
      'receipts' => 'الإيصالات',
      'statistics' => 'الإحصاءات',
      'reports' => 'التقارير',
      'users' => 'المستخدمون',
      'settings' => 'الإعدادات',
      'audit' => 'سجل التدقيق',
      _ => section,
    },
    _ => switch (section) {
      'employees' => 'Employés',
      'interns' => 'Stagiaires',
      'visitors' => 'Visiteurs',
      'qrCodes' => 'QR Codes',
      'faceEnrollment' => 'Visages',
      'mealHistory' => 'Repas',
      'receipts' => 'Reçus',
      'statistics' => 'Statistiques',
      'reports' => 'Rapports',
      'users' => 'Utilisateurs',
      'settings' => 'Paramètres',
      'audit' => 'Audit',
      _ => section,
    },
  };

  String get splashTagline => switch (_code) {
    'en' => 'Corporate dining · simple, fast, secure',
    'ar' => 'مطعم الشركة · بسيط وسريع وآمن',
    _ => 'Restaurant d’entreprise · simple, rapide, sécurisé',
  };

  String get placeFace => switch (_code) {
    'en' => 'Place your face inside the frame',
    'ar' => 'ضع وجهك داخل الإطار',
    _ => 'Placez votre visage dans le cadre',
  };

  String get cameraAccessError => switch (_code) {
    'en' => 'Unable to open the camera. Check camera permission.',
    'ar' => 'تعذر فتح الكاميرا. تحقق من إذن الكاميرا.',
    _ => 'Impossible d’ouvrir la caméra. Vérifiez son autorisation.',
  };

  String get cameraAccessErrorShort => switch (_code) {
    'en' => 'Camera access error',
    'ar' => 'خطأ في الوصول إلى الكاميرا',
    _ => 'Erreur d’accès à la caméra',
  };

  String get switchingCamera => switch (_code) {
    'en' => 'Switching camera…',
    'ar' => 'جارٍ تبديل الكاميرا…',
    _ => 'Changement de caméra…',
  };

  String get noFaceDetected => switch (_code) {
    'en' => 'No face detected',
    'ar' => 'لم يتم اكتشاف وجه',
    _ => 'Aucun visage détecté',
  };

  String get multipleFacesDetected => switch (_code) {
    'en' => 'More than one face detected',
    'ar' => 'تم اكتشاف أكثر من وجه',
    _ => 'Plus d’un visage détecté',
  };

  String get holdPosition => switch (_code) {
    'en' => 'Perfect, hold that position…',
    'ar' => 'ممتاز، حافظ على وضعك…',
    _ => 'Parfait, maintenez…',
  };

  String get centerFace => switch (_code) {
    'en' => 'Center your face',
    'ar' => 'ضع وجهك في المنتصف',
    _ => 'Centrez votre visage',
  };

  String get doNotMove => switch (_code) {
    'en' => 'Do not move…',
    'ar' => 'لا تتحرك…',
    _ => 'Ne bougez plus…',
  };

  String get identifying => switch (_code) {
    'en' => 'Identifying…',
    'ar' => 'جارٍ التحقق من الهوية…',
    _ => 'Identification en cours…',
  };

  String get qrDetected => switch (_code) {
    'en' => 'QR code detected!',
    'ar' => 'تم اكتشاف رمز QR!',
    _ => 'QR Code détecté !',
  };

  String get validatingQr => switch (_code) {
    'en' => 'Validating QR code…',
    'ar' => 'جارٍ التحقق من رمز QR…',
    _ => 'Validation du QR code…',
  };

  String get timeoutTitle => switch (_code) {
    'en' => 'Time expired',
    'ar' => 'انتهت المهلة',
    _ => 'Délai écoulé',
  };

  String get timeoutMessage => switch (_code) {
    'en' => 'No person or QR code was detected.',
    'ar' => 'لم يتم اكتشاف أي شخص أو رمز QR.',
    _ => 'Aucune personne ou QR Code détecté.',
  };

  String get back => switch (_code) {
    'en' => 'Back',
    'ar' => 'رجوع',
    _ => 'Retour',
  };

  String get backHome => switch (_code) {
    'en' => 'Back to home',
    'ar' => 'العودة إلى الرئيسية',
    _ => 'Retour à l’accueil',
  };

  String get errorTitle => switch (_code) {
    'en' => 'Error',
    'ar' => 'خطأ',
    _ => 'Erreur',
  };

  String get mealAlreadyRegisteredTitle => switch (_code) {
    'en' => 'Meal already registered',
    'ar' => 'تم تسجيل الوجبة بالفعل',
    _ => 'Repas déjà enregistré',
  };

  String get mealAlreadyRegisteredMessage => switch (_code) {
    'en' => 'Your meal has already been registered today.',
    'ar' => 'تم تسجيل وجبتك لهذا اليوم بالفعل.',
    _ => 'Votre repas a déjà été enregistré aujourd’hui.',
  };

  String get retryIdentification => retry;

  String get cameraPreviewSemantics => switch (_code) {
    'en' => 'Camera preview for identification',
    'ar' => 'معاينة الكاميرا للتحقق من الهوية',
    _ => 'Aperçu de la caméra pour identification',
  };

  String get cancelAction => cancel;

  String get switchCamera => switch (_code) {
    'en' => 'Switch front/rear camera',
    'ar' => 'تبديل الكاميرا الأمامية والخلفية',
    _ => 'Basculer caméra avant/arrière',
  };

  String get keepFaceWellLit => switch (_code) {
    'en' => 'Keep your face well lit',
    'ar' => 'تأكد من إضاءة وجهك جيدًا',
    _ => 'Gardez votre visage bien éclairé',
  };

  String get presentQrCode => switch (_code) {
    'en' => 'Present your QR code',
    'ar' => 'قدّم رمز QR الخاص بك',
    _ => 'Présentez votre QR Code',
  };

  String get invalidIdentificationProof => switch (_code) {
    'en' => 'The identification proof is invalid.',
    'ar' => 'إثبات الهوية غير صالح.',
    _ => 'La preuve d’identification est invalide.',
  };

  String get identificationFailure => switch (_code) {
    'en' => 'Identification failed. Please try again.',
    'ar' => 'فشل التحقق من الهوية. يرجى المحاولة مرة أخرى.',
    _ => 'Erreur lors de l’identification. Veuillez réessayer.',
  };

  String get faceNotRegistered => switch (_code) {
    'en' => 'Face not recognized or not registered.',
    'ar' => 'الوجه غير معروف أو غير مسجل.',
    _ => 'Visage non reconnu ou non enregistré.',
  };

  String get qrNotRegistered => switch (_code) {
    'en' => 'This QR code is invalid or not registered.',
    'ar' => 'رمز QR غير صالح أو غير مسجل.',
    _ => 'Ce QR Code est invalide ou non enregistré.',
  };

  String faceNotRecognized(int attempts) => switch (_code) {
    'en' =>
      'Face not recognized after $attempts attempts. Please contact reception.',
    'ar' =>
      'لم يتم التعرّف على الوجه بعد $attempts محاولات. يرجى التواصل مع الاستقبال.',
    _ =>
      'Visage non reconnu après $attempts tentatives. Veuillez contacter l’accueil.',
  };

  String get noIdentificationMethod => switch (_code) {
    'en' => 'No identification method is enabled.',
    'ar' => 'لا توجد طريقة مفعّلة للتحقق من الهوية.',
    _ => 'Aucune méthode d’identification activée.',
  };

  String get login => switch (_code) {
    'en' => 'Sign in',
    'ar' => 'تسجيل الدخول',
    _ => 'Se connecter',
  };

  String get identifyYourself => switch (_code) {
    'en' => 'Identify yourself',
    'ar' => 'عرّف بنفسك',
    _ => 'Identifiez-vous',
  };

  String get faceOrQrPrompt => switch (_code) {
    'en' => 'Present your face or QR code',
    'ar' => 'قدّم وجهك أو رمز QR الخاص بك',
    _ => 'Présentez votre visage ou votre QR code',
  };

  String get chooseMealAfterIdentification => switch (_code) {
    'en' => 'Identification confirmed · choose your meal',
    'ar' => 'تم التحقق من الهوية · اختر وجبتك',
    _ => 'Identification confirmée · choisissez votre repas',
  };

  String get startIdentification => switch (_code) {
    'en' => 'Start identification',
    'ar' => 'بدء التحقق',
    _ => 'Démarrer l\'identification',
  };

  String get faceLabel => switch (_code) {
    'en' => 'Face',
    'ar' => 'الوجه',
    _ => 'Visage',
  };

  String get qrLabel => switch (_code) {
    'en' => 'QR code',
    'ar' => 'رمز QR',
    _ => 'QR code',
  };

  String offlineQueueSubtitle(int count) => switch (_code) {
    'en' => '$count meal(s) waiting offline',
    'ar' => '$count وجبة/وجبات في وضع عدم الاتصال',
    _ => '$count repas en attente hors ligne',
  };

  String get offlineQueuedNotice => switch (_code) {
    'en' => 'Connection lost. Meal queued offline.',
    'ar' => 'انقطع الاتصال. تمت إضافة الوجبة إلى قائمة الانتظار دون اتصال.',
    _ => 'Connexion perdue. Repas mis en file d\'attente.',
  };

  String get offlineQueuedSuccess => switch (_code) {
    'en' => 'We will sync it automatically when the connection returns.',
    'ar' => 'سنقوم بمزامنتها تلقائيًا عند عودة الاتصال.',
    _ =>
      'Nous l\'enregistrerons automatiquement dès que la connexion reviendra.',
  };

  String queuedMealMessage(String mealLabel) => switch (_code) {
    'en' => 'Meal "$mealLabel" queued offline.',
    'ar' => 'تمت إضافة الوجبة "$mealLabel" إلى قائمة الانتظار دون اتصال.',
    _ => 'Repas "$mealLabel" mis en file d\'attente hors ligne.',
  };

  String registeredMealMessage(String mealLabel) => switch (_code) {
    'en' => 'Meal "$mealLabel" registered!',
    'ar' => 'تم تسجيل الوجبة "$mealLabel"!',
    _ => 'Repas "$mealLabel" enregistré !',
  };

  String get registeredMealFallback => switch (_code) {
    'en' => 'Meal registered successfully!',
    'ar' => 'تم تسجيل الوجبة بنجاح!',
    _ => 'Repas enregistré avec succès !',
  };

  String get identifyVia => switch (_code) {
    'en' => 'Identified via',
    'ar' => 'تم التعرّف عبر',
    _ => 'Identifié via',
  };

  String get qrCode => switch (_code) {
    'en' => 'QR Code',
    'ar' => 'رمز QR',
    _ => 'QR Code',
  };

  String get faceRecognition => switch (_code) {
    'en' => 'Face recognition',
    'ar' => 'التعرّف على الوجه',
    _ => 'Reconnaissance faciale',
  };

  String get offlineQueueMethod => switch (_code) {
    'en' => 'Offline queue',
    'ar' => 'قائمة الانتظار دون اتصال',
    _ => 'Mise en file hors ligne',
  };

  String get settingsTitle => switch (_code) {
    'en' => 'Settings',
    'ar' => 'الإعدادات',
    _ => 'Paramètres',
  };

  String get save => switch (_code) {
    'en' => 'Save',
    'ar' => 'حفظ',
    _ => 'Enregistrer',
  };

  String get saving => switch (_code) {
    'en' => 'Saving…',
    'ar' => 'جارٍ الحفظ…',
    _ => 'Enregistrement…',
  };

  String get retry => switch (_code) {
    'en' => 'Retry',
    'ar' => 'إعادة المحاولة',
    _ => 'Réessayer',
  };

  String get noSettingsAvailable => switch (_code) {
    'en' => 'No settings available.',
    'ar' => 'لا توجد إعدادات متاحة.',
    _ => 'Aucun paramètre disponible.',
  };

  String get unsavedChanges => switch (_code) {
    'en' => 'Unsaved changes',
    'ar' => 'تغييرات غير محفوظة',
    _ => 'Modifications non enregistrées',
  };

  String get settingsSaved => switch (_code) {
    'en' => 'Settings saved successfully.',
    'ar' => 'تم حفظ الإعدادات بنجاح.',
    _ => 'Paramètres enregistrés avec succès.',
  };

  String get settingsReset => switch (_code) {
    'en' => 'Settings restored successfully.',
    'ar' => 'تمت استعادة الإعدادات بنجاح.',
    _ => 'Paramètres réinitialisés avec succès.',
  };

  String get modified => switch (_code) {
    'en' => 'Changed',
    'ar' => 'معدّل',
    _ => 'Modifié',
  };

  String get load => switch (_code) {
    'en' => 'Load',
    'ar' => 'تحميل',
    _ => 'Charger',
  };

  String get version => switch (_code) {
    'en' => 'Version',
    'ar' => 'الإصدار',
    _ => 'Version',
  };

  String get application => switch (_code) {
    'en' => 'Application',
    'ar' => 'التطبيق',
    _ => 'Application',
  };

  String get backend => switch (_code) {
    'en' => 'Backend',
    'ar' => 'الخادم',
    _ => 'Backend',
  };

  String get environment => switch (_code) {
    'en' => 'Environment',
    'ar' => 'البيئة',
    _ => 'Environnement',
  };

  String get database => switch (_code) {
    'en' => 'Database',
    'ar' => 'قاعدة البيانات',
    _ => 'Base de données',
  };

  String get connected => switch (_code) {
    'en' => 'Connected',
    'ar' => 'متصل',
    _ => 'Connecté',
  };

  String get disconnected => switch (_code) {
    'en' => 'Disconnected',
    'ar' => 'غير متصل',
    _ => 'Déconnecté',
  };

  String get tables => switch (_code) {
    'en' => 'Tables',
    'ar' => 'الجداول',
    _ => 'Tables',
  };

  String get records => switch (_code) {
    'en' => 'Records',
    'ar' => 'السجلات',
    _ => 'Enregistrements',
  };

  String get resetSettings => switch (_code) {
    'en' => 'Reset settings',
    'ar' => 'إعادة ضبط الإعدادات',
    _ => 'Réinitialiser les paramètres',
  };

  String get restoreDefaults => switch (_code) {
    'en' => 'Restore default values',
    'ar' => 'استعادة القيم الافتراضية',
    _ => 'Rétablir les valeurs par défaut',
  };

  String get reset => switch (_code) {
    'en' => 'Reset',
    'ar' => 'إعادة ضبط',
    _ => 'Réinitialiser',
  };

  String get resetConfirmation => switch (_code) {
    'en' => 'All settings will be restored to their default values.',
    'ar' => 'ستتم استعادة جميع الإعدادات إلى قيمها الافتراضية.',
    _ => 'Tous les paramètres seront rétablis à leurs valeurs par défaut.',
  };

  String get clearCache => switch (_code) {
    'en' => 'Clear cache',
    'ar' => 'مسح ذاكرة التخزين المؤقت',
    _ => 'Vider le cache',
  };

  String get clearTemporaryFiles => switch (_code) {
    'en' => 'Delete temporary files',
    'ar' => 'حذف الملفات المؤقتة',
    _ => 'Supprimer les fichiers temporaires',
  };

  String get cacheCleared => switch (_code) {
    'en' => 'Cache cleared successfully.',
    'ar' => 'تم مسح ذاكرة التخزين المؤقت بنجاح.',
    _ => 'Cache vidé avec succès.',
  };

  String settingsGroupLabel(String category, String fallback) =>
      switch (_code) {
        'en' => switch (category) {
          'restaurant' => 'Restaurant',
          'recognition' => 'Recognition',
          'qr_codes' => 'QR codes',
          'application' => 'Application',
          'security' => 'Security',
          'maintenance' => 'Maintenance',
          _ => fallback,
        },
        'ar' => switch (category) {
          'restaurant' => 'المطعم',
          'recognition' => 'التعرّف',
          'qr_codes' => 'رموز QR',
          'application' => 'التطبيق',
          'security' => 'الأمان',
          'maintenance' => 'الصيانة',
          _ => fallback,
        },
        _ => fallback,
      };

  String settingLabel(String key, String fallback) {
    const en = <String, String>{
      'opening_hour': 'Opening time',
      'closing_hour': 'Closing time',
      'working_days': 'Opening days',
      'time_zone': 'Time zone',
      'auto_return_delay': 'Home return delay (s)',
      'face_similarity_threshold': 'Similarity threshold',
      'face_detection_timeout': 'Detection timeout (s)',
      'max_recognition_attempts': 'Maximum attempts',
      'camera_quality': 'Camera quality',
      'face_recognition_enabled': 'Face recognition',
      'qr_validation_enabled': 'QR code identification',
      'qr_default_expiration': 'Default expiration (days)',
      'qr_auto_revoke_expired': 'Automatically revoke expired codes',
      'qr_image_size': 'QR image size (px)',
      'qr_error_correction': 'Error correction',
      'language': 'Language',
      'theme': 'Theme',
      'company_name': 'Company name',
      'company_logo': 'Logo',
      'welcome_message': 'Welcome message',
      'success_message': 'Success message',
      'session_timeout': 'Session timeout (min)',
      'password_policy': 'Password policy',
      'force_logout': 'Force sign out',
    };
    const ar = <String, String>{
      'opening_hour': 'وقت الفتح',
      'closing_hour': 'وقت الإغلاق',
      'working_days': 'أيام العمل',
      'time_zone': 'المنطقة الزمنية',
      'auto_return_delay': 'مهلة العودة للرئيسية (ث)',
      'face_similarity_threshold': 'حد التشابه',
      'face_detection_timeout': 'مهلة اكتشاف الوجه (ث)',
      'max_recognition_attempts': 'الحد الأقصى للمحاولات',
      'camera_quality': 'جودة الكاميرا',
      'face_recognition_enabled': 'التعرّف على الوجه',
      'qr_validation_enabled': 'التحقق باستخدام رمز QR',
      'qr_default_expiration': 'مدة الصلاحية الافتراضية (أيام)',
      'qr_auto_revoke_expired': 'إلغاء الرموز المنتهية تلقائيًا',
      'qr_image_size': 'حجم صورة QR (بكسل)',
      'qr_error_correction': 'تصحيح الأخطاء',
      'language': 'اللغة',
      'theme': 'المظهر',
      'company_name': 'اسم الشركة',
      'company_logo': 'الشعار',
      'welcome_message': 'رسالة الترحيب',
      'success_message': 'رسالة النجاح',
      'session_timeout': 'انتهاء الجلسة (دقيقة)',
      'password_policy': 'سياسة كلمة المرور',
      'force_logout': 'فرض تسجيل الخروج',
    };
    return switch (_code) {
      'en' => en[key] ?? fallback,
      'ar' => ar[key] ?? fallback,
      _ => fallback,
    };
  }

  String settingDescription(String key, String fallback) => switch (_code) {
    'en' => switch (key) {
      'working_days' => 'Week days (1=Mon…7=Sun)',
      'face_similarity_threshold' => 'Between 0.0 and 1.0',
      'qr_default_expiration' => '0 = end of day',
      'company_logo' => 'Logo URL or base64 value',
      _ => fallback,
    },
    'ar' => switch (key) {
      'working_days' => 'أيام الأسبوع (1=الاثنين…7=الأحد)',
      'face_similarity_threshold' => 'بين 0.0 و1.0',
      'qr_default_expiration' => '0 = نهاية اليوم',
      'company_logo' => 'رابط الشعار أو قيمة base64',
      _ => fallback,
    },
    _ => fallback,
  };

  String settingOption(String value) => switch (_code) {
    'en' => switch (value) {
      'fr' => 'French',
      'en' => 'English',
      'ar' => 'Arabic',
      'light' => 'Light',
      'dark' => 'Dark',
      'system' => 'System',
      'low' || 'L' => 'Low',
      'medium' || 'M' => 'Medium',
      'high' || 'Q' => 'High',
      'H' => 'Maximum',
      'default' => 'Default',
      'strict' => 'Strict',
      'very_strict' => 'Very strict',
      '1' => 'Monday',
      '2' => 'Tuesday',
      '3' => 'Wednesday',
      '4' => 'Thursday',
      '5' => 'Friday',
      '6' => 'Saturday',
      '7' => 'Sunday',
      _ => value,
    },
    'ar' => switch (value) {
      'fr' => 'الفرنسية',
      'en' => 'الإنجليزية',
      'ar' => 'العربية',
      'light' => 'فاتح',
      'dark' => 'داكن',
      'system' => 'النظام',
      'low' || 'L' => 'منخفضة',
      'medium' || 'M' => 'متوسطة',
      'high' || 'Q' => 'عالية',
      'H' => 'قصوى',
      'default' => 'افتراضية',
      'strict' => 'صارمة',
      'very_strict' => 'صارمة جدًا',
      '1' => 'الاثنين',
      '2' => 'الثلاثاء',
      '3' => 'الأربعاء',
      '4' => 'الخميس',
      '5' => 'الجمعة',
      '6' => 'السبت',
      '7' => 'الأحد',
      _ => value,
    },
    _ => switch (value) {
      'fr' => 'Français',
      'en' => 'Anglais',
      'ar' => 'Arabe',
      'light' => 'Clair',
      'dark' => 'Sombre',
      'system' => 'Système',
      'low' || 'L' => 'Basse',
      'medium' || 'M' => 'Moyenne',
      'high' || 'Q' => 'Haute',
      'H' => 'Maximale',
      'default' => 'Par défaut',
      'strict' => 'Stricte',
      'very_strict' => 'Très stricte',
      '1' => 'Lundi',
      '2' => 'Mardi',
      '3' => 'Mercredi',
      '4' => 'Jeudi',
      '5' => 'Vendredi',
      '6' => 'Samedi',
      '7' => 'Dimanche',
      _ => value,
    },
  };

  String localizedWelcomeMessage(String raw) {
    if (_code == 'en' && raw.startsWith('Bienvenue')) return 'Welcome';
    if (_code == 'ar' && raw.startsWith('Bienvenue')) return 'مرحبًا';
    return raw;
  }

  String localizedSuccessMessage(String raw) {
    if (_code == 'en' && raw.startsWith('Repas enregistré')) {
      return 'Enjoy your meal!';
    }
    if (_code == 'ar' && raw.startsWith('Repas enregistré')) {
      return 'بالهناء والشفاء!';
    }
    return raw;
  }

  String identificationMethod(String method) => switch (method.toLowerCase()) {
    'qr' => qrCode,
    'face' => faceRecognition,
    'offline_queue' => offlineQueueMethod,
    _ => method,
  };

  String get loadingCategories => switch (_code) {
    'en' => 'Loading meal categories…',
    'ar' => 'جارٍ تحميل فئات الوجبات…',
    _ => 'Chargement des catégories de repas…',
  };

  String get unavailableCategory => switch (_code) {
    'en' => 'This category is unavailable.',
    'ar' => 'هذه الفئة غير متاحة.',
    _ => 'Cette catégorie est indisponible.',
  };

  String get identificationExpired => switch (_code) {
    'en' => 'Identification expired. Please identify again.',
    'ar' => 'انتهت صلاحية التحقق. يرجى إعادة التحقق.',
    _ => 'Identification expirée. Veuillez vous identifier à nouveau.',
  };

  String get confirm => switch (_code) {
    'en' => 'Confirm',
    'ar' => 'تأكيد',
    _ => 'Confirmer',
  };

  String get cancel => switch (_code) {
    'en' => 'Cancel',
    'ar' => 'إلغاء',
    _ => 'Annuler',
  };

  String confirmMeal(String mealLabel) => switch (_code) {
    'en' => 'Confirm ${mealLabel.toLowerCase()}?',
    'ar' => 'تأكيد ${mealLabel.toLowerCase()}؟',
    _ => 'Confirmer ${mealLabel.toLowerCase()} ?',
  };

  String get confirmMealWarning => switch (_code) {
    'en' =>
      'Check your choice carefully. Only one meal can be registered today.',
    'ar' => 'تحقق من اختيارك بعناية. لا يمكن تسجيل سوى وجبة واحدة اليوم.',
    _ =>
      'Vérifiez votre choix. Un seul repas peut être enregistré aujourd\'hui.',
  };

  String mealLabel(MealType type) => switch (_code) {
    'en' => switch (type) {
      MealType.plat => 'Main dish',
      MealType.pizza => 'Pizza',
      MealType.sandwich => 'Sandwich',
    },
    'ar' => switch (type) {
      MealType.plat => 'طبق رئيسي',
      MealType.pizza => 'بيتزا',
      MealType.sandwich => 'ساندويش',
    },
    _ => switch (type) {
      MealType.plat => 'Plat',
      MealType.pizza => 'Pizza',
      MealType.sandwich => 'Sandwich',
    },
  };

  String mealSubtitle(MealType type) => switch (_code) {
    'en' => switch (type) {
      MealType.plat => 'Traditional meal',
      MealType.pizza => 'Fresh pizza',
      MealType.sandwich => 'Sandwich',
    },
    'ar' => switch (type) {
      MealType.plat => 'وجبة تقليدية',
      MealType.pizza => 'بيتزا طازجة',
      MealType.sandwich => 'ساندويش',
    },
    _ => switch (type) {
      MealType.plat => 'Repas traditionnel',
      MealType.pizza => 'Pizza fraîche',
      MealType.sandwich => 'Sandwich',
    },
  };

  String greeting(DateTime now) {
    if (_code == 'ar') {
      if (now.hour < 12) return 'صباح الخير';
      if (now.hour < 18) return 'مساء الخير';
      return 'مساء الخير';
    }
    if (_code == 'en') {
      if (now.hour < 12) return 'Good morning';
      if (now.hour < 18) return 'Good afternoon';
      return 'Good evening';
    }
    if (now.hour < 12) return 'Bonjour';
    if (now.hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String formattedDate(DateTime now) {
    final localeName = switch (_code) {
      'en' => 'en_US',
      'ar' => 'ar_SA',
      _ => 'fr_FR',
    };
    return DateFormat('EEEE d MMMM y', localeName).format(now);
  }
}
