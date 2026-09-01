# ÉTAPES : donner à opencode l'accès GitHub (via SSH)

But : permettre à **opencode (agent Weutn sur le GPD MicroPC)** de pousser
le dépôt `omarchy-config` (dossier `GPD-microPC/`) vers GitHub **sans demander de mot de passe
à chaque fois** (stratégie SSH, pas HTTPS/token). Coût à faire : **une seule fois**, côté
GitHub (web).

---

## Étape 1 — Ajouter la clé publique à ton compte GitHub (à FAIRE par toi, web)

1. Ouvre GitHub et connecte-toi : https://github.com/login
2. Va dans **Settings → SSH and GPG keys** :
   https://github.com/settings/keys
3. Clique **"New SSH key"**.
4. **Title** : `gpd-micropc-opencode` (un nom qui t'aide à la reconnaître).
5. **Key type** : `Authentication Key`.
6. Dans **Key**, colle **exactement** la ligne suivante (générée par la machine GPD) :

   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHruXjf0Mj++TVzP79XMsUZOjNZBvW7uDCtSzEmwJ2XL weutn@gpd-micropc
   ```

7. Clique **"Add SSH key"** et valide avec ton mot de passe GitHub.

> Vérif (dans un terminal du GPD) :
> `ssh -T git@github.com` → doit répondre
> "Hi <tonuser>! You've successfully authenticated...".

---

## Étape 2 — Vérifier que la clé privée n'a pas de passphrase (sinon opencode demanderait un mot de passe)

Sur le GPD :
```bash
ssh-add -l
```
- Si tu vois la clé listée → OK.
- Si "Could not open a connection to your authentication agent" → relancer l'agent :
  ```bash
  eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
  ```

---

## Étape 3 — Pousser le dépôt vers GitHub (fait par opencode après l'étape 1)

Depuis `~/Documents/gpd-omarchy-config` :
```bash
git remote add origin git@github.com:Weutn/omarchy-config.git
git branch -M main
git push -u origin main
```

---

## NOTES

- On utilise **SSH** et non HTTPS car opencode agira de façon autonome et reproductible.
- `gh auth login` n'est **pas nécessaire** : le push passe par git/SSH directement.
- Aucun secret/private key n'est jamais commité dans le dépôt (public).