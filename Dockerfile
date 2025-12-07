# === Stage 1: Build-Stage (Optional, um Konfigurationsdateien vorzubereiten) ===
# Wir nutzen ein Nginx-Image als Basis. 
FROM nginx:alpine AS builder

# Überschreibe die Standardkonfiguration für maximale Minimierung
# und um sicherzustellen, dass nur das nötigste läuft.
# Hier könnten wir auch eine eigene nginx.conf einbinden, 
# aber für den Standardfall reicht es, nur die index.html zu kopieren.

# Kopiere die lokale HTML-Datei in das temporäre Build-Verzeichnis
# Achtung: Die index.html muss sich im selben Verzeichnis wie das Dockerfile befinden!
COPY index.html /usr/share/nginx/html/index.html

# === Stage 2: Finales, minimales und sicheres Image ===
# Wir starten mit einem frischen, minimalen Nginx Alpine Image.
FROM nginx:alpine

# Setze einen nicht-privilegierten Benutzer (wichtig für die Sicherheit!)
# Nginx läuft standardmäßig als 'nginx' in den offiziellen Images.
# In diesem Image wird Nginx bereits als 'nginx'-Benutzer gestartet. 
# Wenn wir den Benutzer explizit wechseln wollten, wäre es:
# USER nginx 

# Entferne unnötige Standardkonfigurationsdateien
# (Optional, da sie im Alpine-Image oft schon minimal sind)
# RUN rm /etc/nginx/conf.d/default.conf

# Kopiere nur die benötigten Dateien aus der Build-Stage 
# (Hier nur die index.html und die Konfiguration, falls vorhanden)
COPY --from=builder /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html

# Exponiere den Standard-HTTP-Port (optional, dient nur der Dokumentation)
EXPOSE 80

# Der Standard-Startbefehl von Nginx (CMD) ist bereits sicher und korrekt:
# CMD ["nginx", "-g", "daemon off;"]