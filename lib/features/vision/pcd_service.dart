import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';

class PCDService {
  
  // ==========================================
  // HELPER: Mengambil Gambar Asli
  // ==========================================
  static Uint8List getOriginalBytes(String imagePath) {
    // Langsung baca file dari memori HP menjadi kumpulan byte
    return File(imagePath).readAsBytesSync();
  }

  // ==========================================
  // FILTER 1: GRAYSCALE (Bab 5)
  // ==========================================
  static Uint8List applyGrayscale(String imagePath) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image yang bisa dimanipulasi
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes; // Fallback jika gagal

    // 3. Eksekusi filter Grayscale murni
    img.grayscale(image);

    // 4. Encode kembali menjadi format JPG (Bytes) untuk UI
    return img.encodeJpg(image, quality: 90);
  }

  // ==========================================
  // FILTER 2: BRIGHTNESS & CONTRAST
  // ==========================================
  static Uint8List applyBrightnessContrast(String imagePath, {num brightness = 1.2, num contrast = 1.5}) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 3. Eksekusi filter (Simpan ke variabel baru agar aman)
    // Nilai standar adalah 1.0. 
    // Jika > 1.0 berarti makin terang/kontras. Jika < 1.0 berarti makin gelap/pudar.
    img.Image processedImage = img.adjustColor(image, brightness: brightness, contrast: contrast);

    // 4. Encode kembali menjadi format JPG
    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 3: IMAGE INVERSION (CITRA NEGATIF)
  // ==========================================
  static Uint8List applyInversion(String imagePath) {
    // 1. Baca byte gambar asli
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 3. Eksekusi filter Invert (Pembalikan warna)
    img.invert(image);

    // 4. Encode kembali menjadi format JPG untuk ditampilkan di layar
    return img.encodeJpg(image, quality: 90);
  }

  // ==========================================
  // FILTER 4: HISTOGRAM EQUALIZATION
  // ==========================================
  static Uint8List applyHistogramEqualization(String imagePath) {
    final bytes = File(imagePath).readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 1. Ubah ke Grayscale terlebih dahulu (Standar Equalization)
    img.grayscale(image);

    // 2. Hitung Histogram (Frekuensi kemunculan tiap intensitas 0-255)
    List<int> histogram = List.filled(256, 0);
    for (var p in image) {
      // Kita cukup membaca channel Red (r) karena setelah grayscale nilai R=G=B
      histogram[p.r.toInt()]++; 
    }

    // 3. Hitung CDF (Cumulative Distribution Function)
    List<int> cdf = List.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // 4. Normalisasi CDF ke rentang warna 0-255 menggunakan rumus matematis
    int totalPixels = image.width * image.height;
    int cdfMin = cdf.firstWhere((val) => val > 0, orElse: () => 0);
    
    List<int> hValues = List.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      double h = ((cdf[i] - cdfMin) / (totalPixels - cdfMin)) * 255.0;
      hValues[i] = h.clamp(0, 255).round();
    }

    // 5. Mapping (Terapkan intensitas baru ke seluruh piksel gambar)
    for (var p in image) {
      num newLuminance = hValues[p.r.toInt()];
      p.r = newLuminance;
      p.g = newLuminance;
      p.b = newLuminance;
    }

    // Kembalikan gambar yang sudah diratakan kontrasnya ke bentuk JPG
    return img.encodeJpg(image, quality: 90);
  }

  // ==========================================
  // FILTER 5: LOWPASS FILTER (SMOOTHING / BLUR)
  // ==========================================
  static Uint8List applyMeanFilter(String imagePath, {int radius = 3}) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 3. Eksekusi Lowpass Filter menggunakan Gaussian Blur
    // Semakin tinggi nilai radius, gambarnya akan semakin halus/buram.
    img.Image processedImage = img.gaussianBlur(image, radius: radius);

    // 4. Encode kembali menjadi format JPG
    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 5: GAUSSIAN FILTER (LOWPASS / SMOOTHING)
  // ==========================================
  static Uint8List applyGaussianFilter(String imagePath, {int radius = 3}) {
    final bytes = File(imagePath).readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Eksekusi Gaussian Blur murni
    img.Image processedImage = img.gaussianBlur(image, radius: radius);

    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 6: SOBEL FILTER (HIGHPASS / EDGE DETECTION)
  // ==========================================
  static Uint8List applySobelFilter(String imagePath) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 3. Ubah ke Grayscale dulu agar deteksi tepi lebih fokus
    // (Langkah ini opsional, tapi standar industri PCD melakukannya)
    img.Image grayImage = img.grayscale(image);

    // 4. Eksekusi Sobel Edge Detection (Highpass Filter)
    img.Image processedImage = img.sobel(grayImage);

    // 5. Encode kembali menjadi format JPG
    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 7: MEDIAN FILTER (NON-LINEAR / NOISE REDUCTION)
  // ==========================================
  static Uint8List applyMedianFilter(String imagePath) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return bytes;

    // 2. Buat kanvas kosong/duplikat untuk menampung hasil
    img.Image processedImage = img.Image.from(original);

    int width = original.width;
    int height = original.height;

    // 3. Eksekusi Matriks 3x3 Manual (Abaikan batas pinggir 1 piksel agar tidak error)
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        
        // Siapkan keranjang untuk 9 piksel tetangga
        List<num> rValues = [];
        List<num> gValues = [];
        List<num> bValues = [];

        // Sapu area 3x3 di sekitar piksel saat ini
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = original.getPixel(x + dx, y + dy);
            rValues.add(pixel.r);
            gValues.add(pixel.g);
            bValues.add(pixel.b);
          }
        }

        // Urutkan keranjang dari yang terkecil ke terbesar (Sorting)
        rValues.sort();
        gValues.sort();
        bValues.sort();

        // Ambil nilai tengah (Median) yaitu index ke-4 dari 9 data (0,1,2,3,[4],5,6,7,8)
        final p = processedImage.getPixel(x, y);
        p.r = rValues[4];
        p.g = gValues[4];
        p.b = bValues[4];
      }
    }

    // 4. Encode kembali menjadi format JPG
    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 8: KOREKSI GAMMA (POWER-LAW)
  // ==========================================
  static Uint8List applyGammaCorrection(String imagePath, {num gamma = 0.5}) {
    // 1. Baca byte gambar
    final bytes = File(imagePath).readAsBytesSync();
    
    // 2. Decode ke format Image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 3. Eksekusi Koreksi Gamma
    // Nilai standar adalah 1.0. 
    // < 1.0 = Menerangkan area gelap. 
    // > 1.0 = Menggelapkan gambar.
    img.Image processedImage = img.adjustColor(image, gamma: gamma);

    // 4. Encode kembali menjadi format JPG
    return img.encodeJpg(processedImage, quality: 90);
  }

  // ==========================================
  // FILTER 10: FOURIER MAGNITUDE SPECTRUM
  // ==========================================
  static Uint8List applyFourierSpectrum(String imagePath) {
    final bytes = File(imagePath).readAsBytesSync();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return bytes;

    // 1. Resize ke ukuran kecil (64x64)
    // DFT Manual sangat berat (16 Juta kalkulasi untuk 64x64). 
    // Jika terlalu besar, HP bisa hang. 64x64 adalah ukuran paling optimal.
    int size = 64;
    img.Image small = img.copyResize(original, width: size, height: size);
    img.grayscale(small);

    // Siapkan array 2D untuk membaca nilai piksel asli
    List<List<double>> f = List.generate(size, (y) => 
        List.generate(size, (x) => small.getPixel(x, y).r.toDouble()));

    // Siapkan array untuk menampung Bilangan Kompleks (Real & Imaginary)
    List<List<double>> real = List.generate(size, (_) => List.filled(size, 0.0));
    List<List<double>> imag = List.generate(size, (_) => List.filled(size, 0.0));

    // 2. Kalkulasi 2D Discrete Fourier Transform (Matematika Murni)
    for (int u = 0; u < size; u++) {
      for (int v = 0; v < size; v++) {
        double sumR = 0.0;
        double sumI = 0.0;
        for (int x = 0; x < size; x++) {
          for (int y = 0; y < size; y++) {
            // Rumus Sudut Euler
            double angle = -2.0 * pi * ((u * x / size) + (v * y / size));
            sumR += f[y][x] * cos(angle);
            sumI += f[y][x] * sin(angle);
          }
        }
        real[v][u] = sumR;
        imag[v][u] = sumI;
      }
    }

    // 3. Hitung Magnitude dan Skala Logaritmik
    double maxLog = 0.0;
    List<List<double>> mag = List.generate(size, (_) => List.filled(size, 0.0));
    for (int u = 0; u < size; u++) {
      for (int v = 0; v < size; v++) {
        // Magnitude = Akar(Real^2 + Imajiner^2)
        double magnitude = sqrt(real[v][u] * real[v][u] + imag[v][u] * imag[v][u]);
        
        // Log scale agar cahaya yang redup bisa terlihat
        mag[v][u] = log(1.0 + magnitude);
        if (mag[v][u] > maxLog) maxLog = mag[v][u];
      }
    }

    // 4. Gambar Spektrum, Normalisasi (0-255), & Geser ke Tengah (Center Shift)
    img.Image spectrum = img.Image(width: size, height: size);
    int half = size ~/ 2;

    for (int u = 0; u < size; u++) {
      for (int v = 0; v < size; v++) {
        int colorVal = ((mag[v][u] / maxLog) * 255.0).clamp(0, 255).toInt();
        
        // Geser frekuensi 0 (cahaya paling terang) dari ujung ke tengah gambar
        int shiftX = (u + half) % size;
        int shiftY = (v + half) % size;

        spectrum.setPixelRgb(shiftX, shiftY, colorVal, colorVal, colorVal);
      }
    }

    // 5. Besarkan lagi gambarnya agar terlihat jelas di layar HP (misal 300x300)
    img.Image output = img.copyResize(spectrum, width: 300, height: 300, interpolation: img.Interpolation.nearest);

    return img.encodeJpg(output, quality: 90);
  }

}