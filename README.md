<div align="center">

# `assembly_linux_itoa`

### Convertir un entier en chaîne décimale avec GNU Assembler

<p>
  <img src="https://img.shields.io/badge/Architecture-x86__64-6f42c1?style=for-the-badge" alt="Architecture x86-64">
  <img src="https://img.shields.io/badge/Assembler-GNU%20AS-00599C?style=for-the-badge" alt="GNU Assembler">
  <img src="https://img.shields.io/badge/OS-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
</p>

**Un exercice d'assembleur pour comprendre les registres, la pile, la division entière, l'ASCII et les appels système Linux.**

</div>

---

## Sommaire

- [Présentation](#-présentation)
- [Résultat](#-résultat)
- [Algorithme](#-algorithme)
- [Installation](#-installation)
- [Compilation et exécution](#-compilation-et-exécution)
- [Anatomie du programme](#-anatomie-du-programme)
- [Limites actuelles](#-limites-actuelles)

## 🔎 Présentation

`assembly_linux_itoa` est un petit programme écrit en **assembleur x86-64 avec GNU Assembler (GAS)** et la syntaxe Intel.

Le programme contient une routine `print_int` qui convertit un entier non signé en caractères décimaux, puis affiche le résultat dans le terminal en appelant directement le noyau Linux.

La valeur passée à la routine est actuellement définie dans `_start` :

```asm
mov rcx, 424143
call print_int
```

La sortie attendue est :

```text
424143
```

> **Cible : Linux x86-64 (ELF).** Ce programme n'est pas un exécutable Windows et utilise la convention d'appel des syscalls Linux x86-64.

## 🖥️ Résultat

Le programme utilise `write` pour envoyer les caractères à la sortie standard (`stdout`). Il ajoute également un caractère de saut de ligne (`LF`, valeur ASCII `10`) dans son tampon.

## 🧩 Algorithme

La routine extrait les chiffres de droite à gauche en divisant la valeur par `10`. À chaque tour :

1. `RAX` reçoit la valeur courante.
2. `div` divise `RDX:RAX` par `10`.
3. Le quotient reste dans `RAX` et le reste dans `RDX`.
4. `48` est ajouté au reste pour obtenir le caractère ASCII correspondant (`'0'` à `'9'`).
5. Le caractère est placé sur la pile ; les chiffres sont ainsi rangés dans l'ordre utile à l'affichage.

```text
        Valeur : 424143
                 │
                 ▼
          Division par 10
                 │
          ┌──────┴──────┐
          ▼             ▼
       Quotient       Reste
        42414            3  ──► '3'
         4241            4  ──► '4'
          424            1  ──► '1'
           42            4  ──► '4'
            4            2  ──► '2'
            0            4  ──► '4'
                 │
                 ▼
        Caractères sur la pile
                 │
                 ▼
          syscall write
                 │
                 ▼
              424143
```

## 🧰 Installation

### Linux x86-64

Sur un système Linux x86-64, installe GNU Assembler et l'éditeur de liens :

```bash
sudo apt update
sudo apt install binutils
```

### Debian ARM64 sur un Mac Apple Silicon

Si Debian tourne en ARM64, le code x86-64 ne peut pas être assemblé par l'assembleur natif. Installe l'assembleur croisé et QEMU user-mode :

```bash
sudo apt update
sudo apt install binutils-x86-64-linux-gnu qemu-user
```

- `binutils-x86-64-linux-gnu` fournit l'assembleur et l'éditeur de liens ciblant Linux x86-64.
- `qemu-user` permet d'exécuter certains programmes Linux compilés pour une autre architecture, dont x86-64 sur ARM64.

## 🚀 Compilation et exécution

Lance ces commandes depuis le répertoire qui contient `itoa.s`.

### Sur Linux x86-64

```bash
as itoa.s -o itoa.o
ld itoa.o -o itoa
./itoa
```

### Sur Debian ARM64 avec QEMU

```bash
x86_64-linux-gnu-as itoa.s -o itoa.o
x86_64-linux-gnu-ld itoa.o -o itoa
qemu-x86_64 ./itoa
```

Pour vérifier l'architecture du binaire généré :

```bash
file ./itoa
```

Le résultat doit indiquer un exécutable **ELF 64-bit x86-64**.

## 🔬 Anatomie du programme

| Élément | Fonction |
|---|---|
| `.intel_syntax noprefix` | Active la syntaxe Intel dans GNU Assembler. |
| `_start` | Point d'entrée du programme. |
| `mov rcx, 424143` | Place l'entier à convertir dans `RCX`, utilisé ici comme registre d'argument de `print_int`. |
| `call print_int` | Appelle la routine de conversion et d'affichage. |
| `R8` | Contient la valeur restante à convertir. |
| `RAX` | Contient la valeur soumise à la division, puis le quotient. |
| `RDX` | Contient le reste de la division ; il est ensuite converti en caractère ASCII. |
| `RBX` | Contient le diviseur `10`. |
| `RSP` | Pointeur de pile ; la routine y place les caractères. |
| `RAX = 1` | Numéro du syscall Linux x86-64 `write`. |
| `RDI = 1` | Descripteur de fichier `stdout`. |
| `RSI` | Adresse du tampon à afficher. |
| `RDX` | Nombre d'octets à écrire lors de l'appel `write`. |
| `RAX = 60` | Numéro du syscall Linux x86-64 `exit`. |

### Conversion en ASCII

Les chiffres `'0'` à `'9'` sont consécutifs dans la table ASCII, de `48` à `57`. L'instruction suivante transforme un reste numérique en son caractère :

```asm
add rdx, 48
```

Par exemple, le reste numérique `3` devient le caractère ASCII `'3'`.

### Affichage par syscall

La routine termine en préparant les registres pour `write` :

```asm
mov rax, 1      # syscall write
mov rdi, 1      # stdout
mov rsi, rsp    # adresse du tampon
mov rdx, r9     # longueur du tampon
syscall
```

Un **syscall** est une demande adressée au noyau. Ici, `write` demande au noyau Linux d'écrire les octets du tampon sur la sortie standard, généralement le terminal.

## ⚠️ Limites actuelles

- **Valeur codée en dur :** le programme affiche actuellement `424143`.
- **Zéro non géré :** si `print_int` reçoit `0`, la boucle quitte avant d'ajouter le caractère `'0'` ; aucun chiffre n'est affiché pour cette entrée.
- **Entiers négatifs non pris en charge :** la routine traite la valeur comme un entier non signé.
- **Convention d'appel spécifique :** `RCX` est utilisé pour transmettre l'argument à `print_int`. Ce choix est propre à cette routine et ne correspond pas à la convention standard des fonctions C sous Linux x86-64, où le premier argument entier est normalement transmis dans `RDI`.
- **Objectif pédagogique :** ce code sert à explorer les mécanismes bas niveau ; il n'est pas encore une fonction générique de conversion prête à être réutilisée dans une bibliothèque.

---

<div align="center">

**Registres · Pile · ASCII · Syscalls**

</div>
