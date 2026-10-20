# Flutter UI Fundamentals — Course Explorer

Aplikasi Course Explorer dibuat menggunakan Flutter untuk menampilkan daftar mata kuliah, detail mata kuliah, status penyelesaian, dan fitur favorit. Aplikasi juga menampilkan identitas mahasiswa serta mendukung navigasi yang adaptif.

## Struktur Folder dan Tanggung Jawab

* **`lib/models/`**
  Menyimpan model data, seperti `Course`, untuk merepresentasikan informasi mata kuliah.

* **`lib/providers/`**
  Mengelola state aplikasi, termasuk daftar mata kuliah, status loading, pesan error, dan daftar favorit.

* **`lib/repositories/`**
  Menjadi perantara antara Provider dan Service dalam pengambilan data.

* **`lib/services/`**
  Menangani sumber data, termasuk membaca file JSON dari assets dan mengubahnya menjadi objek yang dapat digunakan aplikasi.

* **`lib/screens/`**
  Menyimpan halaman aplikasi, seperti Home, Courses, Favorites, Profile, dan Detail Course.

* **`lib/widgets/`**
  Menyimpan widget yang dapat digunakan kembali, seperti `CourseCard` dan `StudentHeader`.

* **`lib/constants.dart`**
  Menyimpan konstanta yang digunakan bersama, seperti nama dan NIM mahasiswa.

* **`lib/course_state.dart`**
  Jika file ini masih digunakan, jelaskan tanggung jawab sebenarnya berdasarkan isi kodenya. Jika tidak digunakan, periksa dahulu sebelum menghapusnya.

* **`lib/main.dart`**
  Menjadi titik masuk aplikasi, mengatur konfigurasi `MaterialApp`, Provider, serta navigasi dan layout utama.

* **`assets/data/`**
  Menyimpan data JSON mahasiswa dan mata kuliah yang digunakan aplikasi.

## Arah Dependency

Arah dependency yang diterapkan untuk pengambilan data mata kuliah adalah:

`Screen/Widget → Provider → Repository → Service/Data Source`

Screen dan widget menampilkan data serta menerima interaksi pengguna. Provider mengelola state, Repository menjadi perantara pengambilan data, sedangkan Service menangani akses ke sumber data.

UI tidak membaca JSON secara langsung menggunakan `rootBundle` atau `jsonDecode`.

## Teknologi

* Flutter
* Dart
* Provider
* JSON assets

## Identitas Mahasiswa

* Nama: Kadek Ayu Aulia
* NIM: 2415051041
* Kelas: PTI 4C

Pengamatan REST Endpoint

API latihan yang digunakan: JSONPlaceholder.

Endpoint URL: https://jsonplaceholder.typicode.com/posts/1

HTTP Method: GET

Resource: Satu data post dengan ID 1

Format Response: JSON

Field JSON yang ditemukan

userId: ID pengguna yang membuat post.

id: ID post.

title: Judul post.

body: Isi post.

Hasil Pengamatan

Endpoint mengembalikan satu data post dalam format JSON. Data tersebut memiliki empat field, yaitu userId, id, title, dan body.

API ini digunakan sebagai API latihan untuk memahami konsep endpoint, request GET, response, dan JSON. Data yang dikembalikan merupakan data post, bukan data mata kuliah (course).

Catatan: Status code HTTP perlu diverifikasi melalui respons HTTP aktual, misalnya menggunakan Postman. JSON yang tampil di browser saja belum memastikan status code yang diterima.