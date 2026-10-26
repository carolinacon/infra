# Streaming PC Ansible provisioning

This adds an Ansible play for the Ubuntu 24.04/Vultr streaming workstation described in the manual setup. It follows the repository's existing style: common `pre-tasks.yaml`, `hardening.yaml`, and handlers are reused, with workstation-specific tasks in `tasks/streaming-pc.yaml`.

## Files

- `playbook.yaml` — addition to be standalone play targeting inventory host `livestream`.
- `ansible/tasks/streaming-pc.yaml` — packages, XRDP/KDE workaround, firewall, Flathub/OBS, `streamer` user, and `uv`.
- `ansible/handlers/streaming-pc-handlers.yaml` — restarts XRDP when its startup script or group membership changes.

## Apply and run

If you only want to provision this host, run the standalone playbook from the `ansible` directory (so its existing relative task paths resolve as in the current repo):

```sh
cd ansible
ansible-playbook -i <your-inventory> playbook-streaming-pc.yaml --syntax-check
ansible-playbook -i <your-inventory> playbook-streaming-pc.yaml --limit livestream
```

The main repository playbook imports this play too. To target only this host from the main playbook, use `--limit livestream`.

The existing repo's `requirements.yaml` already declares `community.general`, which provides `community.general.ufw`, `community.general.flatpak_remote`, and `community.general.flatpak`. Install the repository's requirements as usual if they are not already installed.

## `streamer` password

The new account needs a usable password because GUI privilege prompts and `sudo` may request it. The task will preserve the password for an existing `streamer` account; for a newly created account it requires `streamer_password_hash` to be defined.

Generate a SHA-512 hash on the Ansible controller (for example with `mkpasswd --method=sha-512`) and place it in a local Ansible Vault-encrypted vars file, not in Git. Example plaintext vars file before encrypting it:

```yaml
streamer_password_hash: '$6$...your-generated-hash...'
```

Encrypt that file with `ansible-vault encrypt <file>` and pass it when running the playbook, e.g. `ansible-playbook -i <your-inventory> playbook-streaming-pc.yaml --limit livestream --ask-vault-pass -e @/path/to/streaming-vault.yml`.

## RDP firewall

By default the play reproduces the manual `ufw allow 3389` rule, which exposes the RDP port to all source addresses at the host firewall. Prefer narrowing it to your fixed public IP or VPN network by passing a CIDR, for example:

```sh
ansible-playbook -i <your-inventory> playbook-streaming-pc.yaml --limit livestream -e streaming_rdp_allowed_from=203.0.113.10/32
```

Also review Vultr's separate firewall rules. Changing UFW rules remotely can lock you out, especially because the repository's shared `hardening.yaml` adjusts SSH rules; validate the intended SSH/VPN access path before applying.

## Notes

- The play runs an APT distribution upgrade, matching `apt full-upgrade`; it does not automatically reboot the VPS.
- It preserves `/etc/xrdp/startwm.sh` as `/etc/xrdp/startwm.sh.orig` if that backup does not already exist, then manages the Plasma/XRDP workaround block immediately before the Xsession launch.
- It downloads and installs Chrome from the official Google `.deb` URL, and installs the listed OBS Flatpaks system-wide. The Chrome `.deb` is staged only if missing; replace the cached file to intentionally refresh it. Flatpak apps may update independently of Ansible after installation.
- It installs `uv`/`uvx` under `/usr/local/bin`. `uvx glances` is an interactive terminal program, so Ansible intentionally does not launch it during provisioning; run `uvx glances` in Konsole when you want the live system monitor.
- This is designed for the same Ubuntu 24.04 package names as the manual commands; review package availability before reusing it on other Ubuntu releases.


---

## Manual commands

```
```diff
apt update && apt full-upgrade -y && apt install kubuntu-desktop xrdp xorgxrdp chromium-browser firefox nvtop konsole plasma-discover{,-backend-{snap,flatpak}} flatpak qpwgraph libfuse2t64 pavucontrol -y
sudo ufw allow 3389
sudo adduser xrdp ssl-cert
curl -fsSLOJ 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
apt install ./google-chrome-stable_current_amd64.deb
# https://chatgpt.com/share/6adf6fbd-43fc-83ea-aabb-542192e6345b
cp /etc/xrdp/startwm.sh{,.orig}
diff -C 3 /etc/xrdp/startwm.sh*
*** /etc/xrdp/startwm.sh        2026-10-26 12:15:27.514693630 +0000
--- /etc/xrdp/startwm.sh.orig   2026-10-26 12:14:52.144718735 +0000
***************
*** 13,30 ****
  if test -r ~/.profile; then
        . ~/.profile
  fi
- # Work around KDE Plasma / XRDP missing display environment
- if [ -n "${DISPLAY:-}" ] && command -v systemctl >/dev/null 2>&1; then
-     systemctl --user set-environment \
-         DISPLAY="$DISPLAY" \
-         XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \
-         2>/dev/null || true
  
-     systemctl --user reset-failed plasma-kglobalaccel.service \
-         2>/dev/null || true
- 
-     systemctl --user start plasma-kglobalaccel.service \
-         2>/dev/null || true
- fi
  test -x /etc/X11/Xsession && exec /etc/X11/Xsession
  exec /bin/sh /etc/X11/Xsession
--- 13,18 ----

systemctl enable --now xrdp
sudo systemctl restart xrdp xrdp-sesman

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &&
sudo flatpak install flathub com.obsproject.Studio -y &&
sudo flatpak install flathub com.obsproject.Studio.Plugin.SourceRecord -y &&
sudo flatpak install flathub com.obsproject.Studio.Plugin.PipeWireAudioCapture -y &&
# note that a password has to be set since they'll need to use it in GUI prompts
sudo adduser streamer --gecos ''
usermod -aG sudo streamer
# used to monitor CPU/Mem/Load state via glances
curl -LsSf https://astral.sh/uv/install.sh | sudo env UV_NO_MODIFY_PATH=1 UV_INSTALL_DIR=/usr/local/bin sh -
uvx glances

# FYI, don't use org.remmina.Remmina version 1.4.36, for whatever reason I pretty much only got a view-only window with it...
# switching to xfreerdp worked though 🤷
# xfreerdp /v:45.76.23.131 /clipboard /u:"streamer" /p:"$(zenity --password)" /dynamic-resolution /cert-ignore 

#############################################
# other misc commands:
# used to start sinks for audio
pactl load-module module-null-sink   sink_name=cc_jitsi_send   rate=48000 channels=2   sink_properties=device.description=CC_Jitsi_Send
pactl load-module module-null-sink   sink_name=cc_return   rate=48000 channels=2   sink_properties=device.description=CC_Return


# monitor when it comes online
watch -n 1 "nmap -Pn -n -sT -p 22,3389 --open 45.76.23.131"
# use to push info to desktop
╭─user@hostname ~/Desktop/cc  
╰─➤  rsync -ravz --exclude 'tmp/*' . root@45.76.23.131:/home/streamer/Desktop/cc/
# used to pull info off desktop
rsync -ravz root@45.76.23.131:/home/streamer/Desktop/cc/ .


#############################################
# also used ppa + snap during troubleshooting
sudo snap install obs-studio
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install obs-studio
```