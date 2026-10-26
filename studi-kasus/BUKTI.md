# Bukti Studi Kasus Pipeline IMP-DevSecOps

Isi tabel setelah menjalankan skenario. Letakkan screenshot di folder `bukti/` dengan nama seperti di `README.md`.

| ID | Skenario | Link PR | Link run Actions | Semgrep | Pylint | pip-audit | Deploy | Sesuai harapan? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| G1 | Kode rentan SQLi | | | | | | | |
| S1 | Remediasi G1 | | | | | | | |
| G2 | Kode tidak rapi | | | | | | | |
| G3 | Dependensi rentan | | | | | | | |
| G4 | Crash runtime | | | | | | | |
| G5 | Ruleset memblokir | | | - | - | - | - | |
| S2 | Route baru + auto-deploy | | | | | | | |

Isi kolom hasil dengan: hijau, merah, atau skipped.

## Checklist screenshot

- [ ] G1-01-actions-merah.png
- [ ] G1-02-log-semgrep.png
- [ ] G1-03-log-pylint.png
- [ ] G1-04-pr-diblokir.png
- [ ] S1-01-actions-hijau.png
- [ ] S1-02-log-pylint.png
- [ ] S1-03-vm-docker-ps.png
- [ ] S1-04-browser.png
- [ ] G2-01-actions.png
- [ ] G2-02-log-pylint.png
- [ ] G3-01-actions.png
- [ ] G3-02-log-pip-audit.png
- [ ] G3-03-pr-merge-status.png
- [ ] G3-04-pr-diblokir.png
- [ ] G4-01-actions.png
- [ ] G4-02-log-health.png
- [ ] G4-03-vm-docker.png
- [ ] G5-01-push-ditolak.png
- [ ] S2-01-pr-hijau.png
- [ ] S2-02-actions-setelah-merge.png
- [ ] S2-03-browser-health.png
- [ ] S2-04-vm-docker-ps.png

## Temuan selama pengujian

Catat di sini hal di luar dugaan (misalnya temuan Semgrep tambahan, atau tombol Merge yang masih aktif walau audit merah).

-
