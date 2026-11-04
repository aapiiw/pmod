# Watchdog + Agent - Cara Pakai

## Alur

```
MuMu-1.bat / MuMu-2.bat  (atau watchdog yang start)
        |
        v
   Bot jalan (autostart 10 detik dari setting bot)
        |
        v
   WATCHDOG (cek tiap 1 menit, per instance)
        |-- dialog "AutoIt Error"      -> catat teks error, kill bot, start lagi
        |-- log diam 5 menit (hang)    -> kill bot, start lagi
        |-- bot tidak ada (mati)       -> start lagi
        |-- restart-1/2.flag (agent)   -> kill bot, start lagi (pakai kode baru)
        |-- tombol Stop / tutup bot    -> dibiarkan (dianggap sengaja)
        |-- pause.flag / pause-1/2.flag-> dibiarkan
        |
        |   Start lagi = profil dari log terakhir (akun terakhir bot jalan)
        |   Maks 4 start per jam per instance; lebih = "RESTART LOOP", tunggu
        |   sampai start tertua lewat 1 jam lalu coba lagi (bot tidak mati selamanya)
        v
   AGENT (Claude Code, /loop tiap 60 menit)
        |-- baca dev/watchdog/run/watchdog.log + ringkasan log bot
        |-- error yang bikin bot tidak bisa jalan -> perbaiki langsung,
        |   Au3Check 0 error, tulis restart-1/2.flag -> watchdog restart bot
        |-- optimasi / ubah logika / perubahan besar -> usulan, tunggu konfirmasi
        |-- catat 1 baris "Agent pass" di DEVLOG.md, tidak pernah commit
```

## Sekali saja (setup)

1. Jalankan `dev\watchdog\InstallWatchdogTask.bat` (di folder bot, path bebas) -> setujui 1x prompt admin.
   Folder bot dipindah? Jalankan file ini sekali lagi dari lokasi baru (task-nya menyimpan path script).
   Membuat task "MyBotWatchdog" (hak admin, tanpa prompt lagi).

## Tiap kali mau jalan

1. Jalankan `StartWatchdog.bat` (folder ini). Jendela PowerShell watchdog muncul - jangan ditutup.
   Bot yang belum jalan langsung di-start (tidak perlu MuMu-1.bat / MuMu-2.bat), juga kalau terakhir ditutup manual:
   bot 1 dengan `zone`, tunggu sampai main screen (maks 4 menit), baru bot 2 dengan `qath`.
   Restart karena error setelahnya = profil terakhir yang jalan.
   Lebih cepat (~30-40 dtk per bot): buka MuMu 1 dan 2 dulu, tunggu sampai home screen Android, baru StartWatchdog.
   MuMu yang masih loading -> ADB "device offline" -> bot reboot MuMu (lebih lama).
2. Agent (opsional): di VS Code, Claude Code, ketik:
   `/loop 30m follow dev/watchdog/AGENT.md`
   VS Code harus tetap terbuka. Agent berhenti kalau VS Code ditutup; watchdog tetap jalan.

## Berhenti / jeda

| Mau apa | Caranya |
|---|---|
| Matikan watchdog saja (bot tetap jalan) | `StopWatchdog.bat` |
| Watchdog abaikan kedua bot | buat file `pause.flag` di folder ini |
| Abaikan 1 instance | buat file `pause-1.flag` atau `pause-2.flag` |
| Lanjut lagi | hapus file pause-nya |
| Restart bot (mis. setelah ubah kode) | buat file `restart-1.flag` / `restart-2.flag` (isi bebas = alasan) |
| Matikan bot sengaja | tombol Stop atau tutup jendela bot (watchdog tidak start ulang) |
| Hentikan agent (loop) | ketik ke Claude: `hentikan loop` (Claude menghapus jadwalnya dengan CronDelete), atau tutup sesi / VS Code. Loop juga berhenti sendiri setelah 7 hari. Mengirim pesan biasa TIDAK menghentikan loop |
| Cek loop masih ada | ketik ke Claude: `loop apa saja yang jalan?` (CronList) |

## Tempat lihat hasil

- `run\watchdog.log` : semua restart, alasan, teks AUTOIT ERROR, RESTART LOOP
- `run\bot1_*.log` / `run\bot2_*.log` : error AutoIt dari bot yang di-start watchdog (kosong = tidak ada error)
- `DEVLOG.md` (folder bot) : baris "Agent pass" = hasil tiap putaran agent

## Instance

- 1 (MuMu-1): zone, qurlk, qruel, quirk, qarelith, qassa
- 2 (MuMu-2): qath, quartz, quazzy, qiralle, quiver, macia

Kalau profil ditambah / dipindah instance, ubah daftar `$Inst` di `BotWatchdog.ps1`.
