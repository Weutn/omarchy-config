# Procédure de sauvegarde — GPD-microPC (omarchy-config)

Ce document est la **référence** pour opencode (et pour toi) chaque fois qu'une
modification de configuration est faite sur le GPD : elle doit être *commitée* et
*poussée* ici, puis reflétée sur la copie de la Forge.

## À sauvegarder

Tout fichier édité dans :

- `~/.config/hypr/`
- `~/.config/omarchy/` (config + scripts + hooks + extensions + thème)
- `~/.config/systemd/user/`
- `~/.local/bin/` (wrappers)

C'est ce que ce dépôt mire (sous `home/`).

## Procédure (à chaque modification utile)

```bash
cd ~/Documents/gpd-omarchy-config/GPD-microPC

# 1. Re-synchroniser les fichiers réels vers le dépôt-miroir (rsync, exclusions .sample/.bak/fichiers-runtime)
rsync -a --exclude='*.sample' --exclude='*.bak*' --exclude='mirror-intent' \
      ~/.config/hypr/   home/.config/hypr/
rsync -a --exclude='*.sample' --exclude='*.bak*' --exclude='mirror-intent' \
      ~/.config/omarchy/ home/.config/omarchy/
cp -a ~/.config/systemd/user/*.service home/.config/systemd/user/
cp ~/.local/bin/omarchy-hyprland-monitor-scaling home/.local/bin/

# 2. Vérifier les changements
git status
git diff

# 3. Vérifier qu'aucun secret ne part (token/clé/email privé ne doit apparaître)
git diff | grep -iE "token|secret|password|api[_-]?key|BEGIN (RSA|OPENSSH|PRIVATE)" || echo "OK aucun secret détecté"

# 4. Committer + pousser
git add -A
git commit -m "config: <description courte de la modification>"
git push origin main

# 5. Refléter vers la Forge
git push forge main
```

## Règles importantes

- **Jamais de secret** dans ce dépôt public. Si une info sensible est nécessaire,
  elle va dans un **dossier privé séparé** (non poussé sur ce repo public), voir
  ci-dessous.
- Ne committez JAMAIS `.bak` ni fichiers runtime (`mirror-intent`, `lid-closed`).
- Après un changement de SSH / machine, garder la clé `~/.ssh/id_ed25519` hors du repo.

## Dossier privé (infos sensibles)

Pour l'instant **rien de sensible** n'est nécessaire. Si un jour un secret devient utile
(token, clé, identifiants), créer un dépôt SÉPARÉ + PRIVÉ (ex. `gpd-private`) et ne jamais
l'inclure ici. Documenter ici seulement un *pointeur* vers son existence, jamais sa valeur.