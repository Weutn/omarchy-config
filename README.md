# omarchy-config

Configuration personnalisée d'**Omarchy / Hyprland** pour plusieurs machines.

Chaque machine (ou appareil) a son propre sous-dossier contenant la structure de configuration
qui **mire son arborescence réelle** (`~/.config`, `~/.local/bin`, etc.) afin de pouvoir
reconstruire une install à l'identique.

## Machines

| Machine | Dossier | Contenu |
|---------|---------|---------|
| GPD MicroPC | `GPD-microPC/` | Hyprland (monitors rotés, looknfeel) + shell Omarchy + scripts de bord + wrapper monitor-scaling |

## Conventions

- **Structure miroir** : sous chaque dossier machine, `home/` reproduit le home réel.
- **Config public** : aucun secret (jeton, clé, mot de passe) n'est committé dans ce dépôt.
- **Sauvegarde** : toute modification faite sur une machine doit être reflétée ici puis poussée.
  Voir `GPD-microPC/docs/BACKUP.md` pour le procédé par machine.

## Copies / référentiels

- GitHub : `https://github.com/Weutn/omarchy-config`
- Forge (PC de bureau laforge) : `/Vault/Backup/omarchy-config`