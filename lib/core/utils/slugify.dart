// lib/core/utils/slugify.dart

/// Metinleri güvenli MQTT topic slug formatına çeviren yardımcı fonksiyon.
/// Türkçe karakterleri dönüştürür, boşlukları tireye çevirir ve özel karakterleri temizler.
String slugify(String text) {
  if (text.isEmpty) return '';

  // 1. Tüm harfleri küçült ve baştaki/sondaki boşlukları al
  String slug = text.toLowerCase().trim();

  // 2. Türkçe karakterleri İngilizce karşılıklarına dönüştür
  const Map<String, String> turkishCharacters = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
  };

  turkishCharacters.forEach((key, value) {
    slug = slug.replaceAll(key, value);
  });

  // 3. İstenmeyen karakterleri temizle ve formatla
  slug = slug
      .replaceAll(RegExp(r'\s+'), '-') // Boşlukları tireye (-) çevir
      .replaceAll(RegExp(r'[^a-z0-9\-]'),
          '') // Harf, rakam ve tire dışındaki özel karakterleri sil
      .replaceAll(RegExp(r'-+'),
          '-'); // Yan yana gelmiş birden fazla tireyi tek tire yap

  // 4. Baştaki ve sondaki olası fazla tireleri temizle
  return slug.replaceAll(RegExp(r'^-+|-+$'), '');
}

/* --- Test Örnekleri ---

void main() {
  print(slugify("Salon Lambası")); 
  // Çıktı: "salon-lambasi"
  
  print(slugify("Yatak Odası Nem")); 
  // Çıktı: "yatak-odasi-nem"
  
  print(slugify("Mutfak Işık 1")); 
  // Çıktı: "mutfak-isik-1"
  
  // Ekstra test senaryoları:
  print(slugify("  Garaj   Kapısı!  ")); 
  // Çıktı: "garaj-kapisi"
  
  print(slugify("Çalışma Odası @ SENSÖR")); 
  // Çıktı: "calisma-odasi-sensor"
}
*/
