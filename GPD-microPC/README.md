# GPD-microPC — config Omarchy

Configuration personnelle et personnalisations Omarchy / Hyprland pour le **GPD MicroPC**.
Sous-dossier de `omarchy-config` (dépôt GitHub regroupant plusieurs machines).

Ce dépôt sert de **sauvegarde portable** : si le GPD est effacé ou remplacé, ce contenu permet
de reconstruire la configuration à l'identique. Il est aussi le **référentiel** des scripts de
bord et des modifications faites par opencode.

> **Public en lecture seule.** Aucun secret (jetons, mots de passe, clés) ne doit être committé ici.
> Voir `.github-private/` / le dossier privé associé pour toute donnée sensible (rien pour l'instant).

## Contenu

La structure **mire l'arborescence réelle** du home, donc chaque fichier a un chemin de cible évident :

```
home/
├── .config/
│   ├── hypr/        → ~/.config/hypr           (Hyprland : monitors, looknfeel, input, bindings…)
│   ├── omarchy/     → ~/.config/omarchy        (shell, scripts .sh, hooks, extensions, thème, branding…)
│   └── systemd/user → ~/.config/systemd/user    (services user, ex. lid-external-inhibit)
└── .local/bin/      → ~/.local/bin              (wrapper omarchy-hyprland-monitor-scaling)
```

## Ce qui est personnalisé / à vérifier sur une nouvelle machine

- **Hyprland**
  - `home/.config/hypr/monitors.lua` — DSI-1 en portrait roté (`transform = 3`), scale persistant.
  - `home/.config/hypr/looknfeel.lua` — gaps/bordures réduits (GPU Intel UHD 600 faible).
  - `home/.config/hypr/autostart.lua` — désactive `omarchy-hyprland-monitor-watch` + PATH `~/.local/bin` en tête.
  - `home/.config/hypr/bindings.lua` — raccourcis GPD (deux touches).
  - `home/.config/hypr/input.lua` — clavier externe QWERTY canadien (`ca`).
- **Shell Omarchy** — `shell.json` (barre en haut, widgets).
- **Scripts de bord** — `lid-external-inhibit.sh` (+ service systemd), `lid-close-safe.sh`, `set-idle-by-external.sh`.
- **Wrapper** `home/.local/bin/omarchy-hyprland-monitor-scaling` :
  préserve la rotation (`transform = 3`) et applique le scale exact lors d'un changement depuis le panneau Display.
  **Sa présence dans `~/.local/bin` est indispensable** et doit être en tête du PATH (fait via `autostart.lua`).

## RESTAURATION (sur un nouveau GPD)

> Pas de script d'installation pour l'instant — un `install.sh` sera ajouté en temps voulu.

Sur une Omarchy fraîche, recopier chaque fichier de `home/` vers la même position dans `~`,
puis appliquer :

```bash
# (exemple — sera remplacé par un vrai script)
cp -r home/.config/hypr        ~/.config/hypr
cp -r home/.config/omarchy     ~/.config/omarchy
cp -r home/.config/systemd/user ~/.config/systemd/user
cp home/.local/bin/*           ~/.local/bin
```

Ensuite :
```bash
hyprctl reload
omarchy restart shell
systemctl --user enable --now lid-external-inhibit.service
```

## Workflow de sauvegarde (opencode + ce dépôt)

Toutes les modifications de configuration faites sur le GPD doivent être **commitées et poussées** ici
(et reflétées sur la copie de la Forge). Voir `docs/BACKUP.md` pour le procédé exact à suivre.

## Référentiels / copies

- GitHub : `https://github.com/Weutn/omarchy-config` → dossier `GPD-microPC/`
- Forge (PC de bureau laforge) : `/Vault/Backup/omarchy-config`