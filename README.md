# Warp Cloner

![warp-cloner](https://socialify.git.ci/totoroterror/warp-cloner/image?font=Raleway&language=1&name=1&owner=1&pattern=Circuit%20Board&stargazers=1&theme=Light)

Simple Python script that can clone [Warp Plus](https://1.1.1.1/) keys.

With this script you will be able to clone many 12-24 PB keys.

---

## 🚀 Panduan Deploy & Otomatisasi (Railway & VPS)

### ☁️ 1. Deploy di Railway

Aplikasi ini sudah siap di-deploy ke **Railway** dengan dukungan Web Dashboard otomatis untuk melihat status dan hasil key secara real-time!

#### Langkah Deploy ke Railway:
1. Fork repository ini ke akun GitHub Anda.
2. Buka [Railway.app](https://railway.app/) dan buat **New Project**.
3. Pilih **Deploy from GitHub repo** dan hubungkan repository fork Anda.
4. Di bagian **Variables** pada service Railway Anda, Anda bisa menambahkan variabel lingkungan jika diperlukan (opsional):
   - `THREADS_COUNT`: jumlah worker thread (default: `1`)
   - `DELAY`: jeda waktu kloning dalam detik (default: `25`)
   - `BASE_KEYS`: JSON array dari base keys (misal: `["key1","key2"]`)
5. Railway akan secara otomatis membaca `Dockerfile` & `railway.json` serta mendeteksi variabel `PORT`.
6. Setelah deployment selesai, Anda dapat mengakses **Web Dashboard** dan endpoint `/keys` melalui URL domain publik dari Railway!

---

### 🖥️ 2. Deploy & Otomatisasi di VPS (Menggunakan `manage.sh`)

Untuk kemudahan penggunaan di VPS (Ubuntu, Debian, CentOS, dll), kami telah menyediakan script manajemen otomatis **`manage.sh`**.

#### Cara Penggunaan di VPS:
1. Clone repository ke VPS Anda:
   ```bash
   git clone https://github.com/totoroterror/warp-cloner.git
   cd warp-cloner
   ```
2. Berikan izin eksekusi pada script:
   ```bash
   chmod +x manage.sh
   ```
3. Jalankan menu interaktif:
   ```bash
   ./manage.sh
   ```

#### Fitur Script Otomatisasi (`./manage.sh`):
Menu interaktif akan tampil dengan pilihan:
- **1. Start**: Jalankan Warp Cloner via Docker Compose di background.
- **2. Stop**: Hentikan Warp Cloner.
- **3. Restart**: Restart service Warp Cloner.
- **4. Status**: Cek status container.
- **5. Logs**: Monitoring log real-time (`Ctrl+C` untuk keluar).
- **6. View Keys**: Lihat daftar key yang berhasil dibuat (`output.txt`).
- **7. Edit Config**: Edit file `.env` menggunakan editor teks.
- **8. Update**: Git pull otomatis & rebuild container ke versi terbaru.
- **9. Install Dependencies**: Otomatis install Docker & Docker Compose jika belum ada.

#### Perintah Langsung (CLI Shortcut):
Anda juga dapat menjalankan perintah tanpa masuk ke menu interaktif:
- `./manage.sh start` - Jalankan di background
- `./manage.sh stop` - Hentikan aplikasi
- `./manage.sh restart` - Restart aplikasi
- `./manage.sh logs` - Lihat log real-time
- `./manage.sh keys` - Lihat hasil key
- `./manage.sh update` - Update aplikasi

---

## 🛠️ Local Installation (Manual)

1. Clone this repository
2. Install [Python 3.11](https://www.python.org/downloads/) or higher
3. Install dependencies using `pip install -r requirements.txt`
4. Copy `.env.example` to `.env` and fill variables (see Configuration section)
5. Launch script using `python -u src/main.py`
6. Wait for results in console.

## ⚙️ Configuration

- `BASE_KEYS` (not required) - keys to clone divided as array in JSON format (ex: `["key1", "key2"]`), if none then default keys will be used (script may not work with default keys)
- `THREADS_COUNT` (default: `1`) - amount of threads.
- `DEVICE_MODELS` (not required) - custom device model names divided as array in JSON format (ex: `["Android", "Secret Device"]`)
- `SAVE_WIREGUARD_VARIABLES` (default: false) - should script get variables that are required to generate WireGuard config (peer ips, private / public key, endpoint)?
- `PROXY_FILE` (not required) - path to proxy file, if none then script will be launched in proxyless mode.
- `DELAY` (default: `25`) - seconds to sleep after key clone
- `OUTPUT_FILE` (default: `output.txt`) - file to append generated keys
- `OUTPUT_FORMAT` (default: `{key} | {referral_count}`) - output format (if `SAVE_WIREGUARD_VARIABLES` is set to `true`, additinal variables is available: `{private_key}`, `{peer_endpoint}`, `{peer_public_key}`, `{interface_addresses}`)
- `RETRY_COUNT` (default: 3) - how much times application will retry generation with same key
- `PORT` (not required) - port for Web Dashboard & Health check endpoint (automatically configured on Railway)

## 📌 Notes

### Proxy format

Proxy format for `PROXY_FILE` is `protocol://user:pass@ip:port`, example: `socks5://example.org:1892` / `http://totoro:warp@example.org`, one proxy per line.

### Getting your own 12-24 PB keys to fill BASE_KEYS

You can get your own key to start with using [@warpplus's bot](https://t.me/generatewarpplusbot) (limited to 1 key per 24 hours) or find some keys on forums.

### Properly closing application

To avoid getting error "Too many connected devices" in future, you should properly exit from the application by pressing `control` + `c` and wait for application to close (it will take ~30 seconds).

### Proxy selection

You can use almost any proxy (ipv4 / ipv6) as far as they don't block Warp API endpoint. I suggest you to use ipv6 proxy because they are way cheaper, *but keep in mind, that your network should support ipv6 in most cases to do this*.

## Contributing

I will support this project as far as I can, but issues and pull requests are always welcome!

## License

This project licensed under MIT License.

## Support me

You can support my further developments or support this project by buying me a coffee using link below or by starring this repo ♥

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/totoroterror)
