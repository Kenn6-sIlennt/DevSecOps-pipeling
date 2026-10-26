# Studi Kasus Pipeline IMP-DevSecOps (dengan Bukti dari GitHub)

Folder ini berisi skenario berhasil dan gagal yang dijalankan sebagai **branch dan Pull Request sungguhan**, sehingga hasilnya muncul di tab **Actions** dan halaman PR. Itulah yang kamu screenshot sebagai bukti.

| ID | Skenario | Branch | Hasil yang diharapkan |
| --- | --- | --- | --- |
| G1 | Kode rentan SQL Injection | `case/g1-sqli` | Semgrep merah, Pylint merah (7.50), Audit hijau, Deploy skipped |
| G2 | Kode aman tapi tidak rapi | `case/g2-pylint` | Pylint merah (8.67), Deploy skipped |
| G3 | Dependensi lama (`flask==2.0.1`) | `case/g3-dependency` | Dependency Audit merah (4 temuan), Deploy skipped |
| G4 | Lolos CI, aplikasi HTTP 500 saat runtime | `case/g4-runtime-crash` | CI hijau, Deploy merah di step health check |
| G5 | Merge diblokir ruleset | (dari PR G1/G3) | Tombol Merge terkunci, push langsung ke `main` ditolak |
| S1 | Remediasi G1 | `case/g1-sqli` (commit lanjutan) | Satu PR yang tadinya merah menjadi hijau semua, deploy jalan |
| S2 | Route baru, merge, auto-deploy | `case/s2-new-routes` | Semua hijau, merge, route baru aktif di VM |

## 0. Prasyarat (cek dulu)

1. **Runner aktif** di Ubuntu Server (`./run.sh` di folder `actions-runner`, status *Idle/hijau* di Settings → Actions → Runners).
2. **Hanya workflow IMP yang aktif.** Nonaktifkan `DevSecOps CI/CD Pipeline` yang lama: Actions → pilih workflow tersebut → tombol `...` → **Disable workflow**. Kalau tidak, dua workflow akan mendeploy container `web-flask` di port 5000 bersamaan dan saling menimpa.
3. **`main` berisi versi aman** (`app.py` hasil remediasi dan `templates/index.html`).
4. **Branch ruleset aktif** sesuai modul (wajib PR, wajib status check *Semgrep SAST Scan* dan *Pylint Code Quality Gate*).
5. `git` terpasang dan sudah login. `gh` (GitHub CLI) opsional: dengan `gh`, PR dibuat otomatis. Tanpa `gh`, script mencetak link untuk membuat PR.

## 1. Memasukkan folder ini ke repo

Karena ruleset melarang push langsung ke `main`, masukkan folder ini lewat PR:

```bash
git checkout main && git pull
git checkout -b chore/studi-kasus
# salin folder studi-kasus/ ke root repo, lalu:
git add studi-kasus
git commit -m "docs: tambah studi kasus pipeline"
git push -u origin chore/studi-kasus
# buat PR, tunggu check hijau, merge
git checkout main && git pull
```

Kode skenario sengaja disimpan dengan akhiran `.scenario` (misalnya `app.py.scenario`) supaya **Semgrep tidak memindai kode rentan yang tersimpan di repo** dan membuat `main` merah. Script akan menyalin dan menghapus akhiran itu saat skenario dijalankan.

## 2. Menjalankan skenario

Jalankan dari root repo, satu per satu, dan tunggu pipeline selesai sebelum lanjut. Working tree harus bersih.

```bash
bash studi-kasus/run.sh g1   # lalu amati dan screenshot (lihat tabel bukti)
bash studi-kasus/run.sh s1   # perbaiki G1 di PR yang sama
bash studi-kasus/run.sh g2
bash studi-kasus/run.sh g3
bash studi-kasus/run.sh g4
bash studi-kasus/run.sh s2
```

Tiap perintah: pindah ke `main` terbaru, membuat branch skenario, menyalin file skenario, commit, push, lalu membuat PR (atau mencetak link PR).

Pipeline berjalan karena event `pull_request` ke `main`. Kamu juga bisa menjalankannya manual: Actions → pilih workflow → **Run workflow** → pilih branch.

## 3. Bukti yang diambil per skenario

Simpan screenshot di folder `bukti/` dengan nama berikut, lalu isi `BUKTI.md`.

**G1 (kode rentan)**
- `G1-01-actions-merah.png`: halaman run di tab Actions (Semgrep merah, Pylint merah, Audit hijau, Deploy abu-abu *skipped*).
- `G1-02-log-semgrep.png`: log step *Run Semgrep SAST* berisi temuan SQL Injection.
- `G1-03-log-pylint.png`: log Pylint dengan skor 7.50/10.
- `G1-04-pr-diblokir.png`: halaman PR, merge terkunci (ini juga bukti G5).
- Opsional: bukti kode rentan benar-benar bisa diserang. Di VM tidak perlu, karena deploy tidak berjalan; itu justru poinnya.

**S1 (remediasi, di PR yang sama dengan G1)**
- `S1-01-actions-hijau.png`: run terbaru semua hijau, termasuk *Build, Deploy & Health Check on VM*.
- `S1-02-log-pylint.png`: skor 10.00/10.
- `S1-03-vm-docker-ps.png`: di VM jalankan `sudo docker ps` (status `Up`, nanti `healthy` setelah ±30 detik).
- `S1-04-browser.png`: `http://<IP_VM>:5000/` menampilkan form login.

**G2 (tidak rapi)**
- `G2-01-actions.png`: Pylint merah, Semgrep hijau, Deploy skipped.
- `G2-02-log-pylint.png`: skor 8.67/10 dengan daftar pesan C0114, C0116, C0411.

**G3 (dependensi rentan)**
- `G3-01-actions.png`: hanya *Python Dependency Security Audit* yang merah.
- `G3-02-log-pip-audit.png`: tabel kerentanan (nama paket, versi, ID, versi perbaikan).
- `G3-03-pr-merge-status.png`: status tombol Merge. Kalau *Python Dependency Security Audit* belum ada di required checks, tombol Merge **masih bisa aktif** walau check merah. Itu temuan nyata. Tambahkan job tersebut ke ruleset (Settings → Rules → ruleset → Require status checks → Add checks), buka ulang PR atau push ulang, lalu screenshot lagi (`G3-04-pr-diblokir.png`).

**G4 (crash di runtime)**
- `G4-01-actions.png`: tiga job CI hijau, deploy merah.
- `G4-02-log-health.png`: log step *Container Health & Optimization Check* (curl gagal, pesan percobaan 1/5 sampai 5/5).
- `G4-03-vm-docker.png`: di VM `sudo docker ps` (container tetap `Up`, jadi pengecekan `Running` saja tidak cukup) dan `curl -i http://localhost:5000/` yang menunjukkan `HTTP/1.1 500`.
- Penting: pada skenario ini versi lama sudah dihapus (`docker rm -f`) sebelum health check, dan versi rusak tetap berjalan. Pulihkan dengan menjalankan workflow manual di branch `main` (Actions → Run workflow → `main`).

**G5 (ruleset)**
- `G5-01-push-ditolak.png`: coba push langsung ke `main` dan screenshot pesannya:
  ```bash
  git checkout main && git pull
  echo "# uji" >> README.md && git commit -am "uji push langsung"
  git push origin main        # diharapkan ditolak
  git reset --hard origin/main  # bersihkan commit uji
  ```
- Screenshot halaman PR G1 (`G1-04-pr-diblokir.png`) dipakai juga sebagai bukti G5.

**S2 (route baru, merge, auto-deploy)**
- `S2-01-pr-hijau.png`: PR dengan semua check hijau dan tombol Merge aktif.
- `S2-02-actions-setelah-merge.png`: run di `main` setelah merge, deploy hijau.
- `S2-03-browser-health.png`: `http://<IP_VM>:5000/health` menampilkan `{"status":"ok"}`; screenshot juga `/about`.
- `S2-04-vm-docker-ps.png`: `sudo docker ps` di VM.

## 4. Merapikan setelah selesai

- G1, G2, G3, G4: **jangan di-merge**. Tutup PR (*Close pull request*) dan hapus branch.
- S2: di-merge ke `main` (itu bagian skenarionya).
- Pastikan VM kembali ke versi baik: jalankan workflow manual di `main` setelah G4.

## 5. Opsional: unduh log sebagai bukti teks

```bash
gh auth login
bash studi-kasus/kumpulkan-bukti.sh
```

Log per run tersimpan di `studi-kasus/bukti/logs/`. Script ini belum pernah saya jalankan terhadap repo GitHub nyata; kalau `gh` kamu versi lain dan ada flag yang tidak cocok, abaikan saja dan pakai screenshot.

## 6. Yang sudah dan belum diuji

Sudah diuji sebelum dibuat paket ini:
- Skor Pylint tiap skenario: G1 7.50, G2 8.67, G4/S1/S2 10.00.
- `flask==2.0.1` membuat `pip-audit --requirement` gagal dengan resolusi penuh, seperti di workflow (4 temuan; ID `PYSEC-2023-62` dan `PYSEC-2026-2151`). Hasil audit bisa berubah seiring pembaruan database kerentanan.
- G4: `GET /` mengembalikan HTTP 500; S2: `/health` dan `/about` mengembalikan HTTP 200.
- `run.sh` diuji di repo lokal dengan remote tiruan: pembuatan branch, G1 lalu S1 di branch yang sama, dan penolakan saat working tree kotor.

Belum bisa diuji di sini, jadi nilai aslinya adalah hasil di GitHub kamu:
- Output Semgrep. G1 diharapkan merah; skenario lain diharapkan hijau. Kalau Semgrep menandai hal lain, catat sebagai temuan tambahan.
- Perilaku runner, Docker, dan health check di VM.
- Perilaku ruleset di GitHub.
