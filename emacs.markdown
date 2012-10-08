% Codage habile avec Emacs
% Pierre-Olivier "Némunaire" Mercier; Clément "Void" Pellegrini
% Jeudi 8 octobre 2012

# L'histoire d'Emacs

## Au commencement

* Richard Stallman écrit un mode pour l'éditeur TECO
* Il lui ajoute ensuite des macros nommées MACS
* Guy Steele unifie les commandes claviers
* Ainsi naît EMACS : Editing MACroS

![Richard Stallman](stallman.jpg)

## GNU Emacs

* En 1981, Gosling Emacs est une implémentation pour UNIX écrit en C
  avec un langage d'extension proche du Lisp ; mais est propriétaire
* En 1984, Stallman lance le projet GNU Emacs, fourni avec Emacs Lisp
* La première version répandue est la 15.34 en 1985

# Les principales fonctionnalités

## Modes d'édition

* Écrit en Emacs-Lisp
* Changement de variables lisp
* Seulement un mode majeur à la fois
* Plusieurs modes mineurs

### Mode majeur

* Change généralement en fonction de l'extension du fichier
* Défini la coloration syntaxique, l'indentation, ...
* Par exemple : c-mode, html-mode, latex-mode, tuareg-mode, ...

### Mode mineur

* Personalise le comportement de l'éditeur
* Par exemple : linum-mode, column-number-mode, ...

## Terminologie

### Buffer

Chaque fichier ouvert (affiché ou non) est dans un *buffer*.

### Window

Lorsqu'un buffer est affiché, il l'est dans une *window*.

### Frame

La fenêtre ou le terminal contenant les *window*.

### Mode line

Dernière ligne de chaque *window* affichant diverses informations.

### Mini-buffer

Dernière ligne de chaque *frame* pour taper des commandes.

## Terminologie

### Mark

Position dans un buffer défini par l'utilisateur.

### Region

Équivalent du texte sélectionné : texte entre la *mark* et le curseur.

### Yank

L'équivalent de la copie.

### Kill ring

Le presse-papier circulaire.

# Les raccourcis utiles

## SOS

* `[C-x C-c]` : quitter Emacs ;
* `[C-x C-f]` : ouvrir un fichier ;
* `[C-x C-s]` : sauvegarder le *buffer* courant ;
* `[C-g]` : arrête toute commande lancée ou début de chaîne de touches ;
* `[M-x cmd]` : exécute la macro `cmd` ;

## Gérer les *windows*

* `[C-x 2]` : split vertical ;
* `[C-x 3]` : split horizontal ;
* `[C-x 0]` : ferme la fenêtre courante.

* `[C-x o]` : passe d'une fenêtre à l'autre.

* `[C-x ^]` : augmente la hauteur de la fenêtre ;
* `[C-x }]` : augmente la largeur de la fenêtre ;
* `[C-x {]` : diminue la hauteur de la fenêtre ;
* `[C-x +]` : répartie l'espace entre toutes les fenêtre.

## Les *buffers*

### Déplacement dans le *buffeer*

* `[C-x []` : va au début du *buffer* ;
* `[C-x ]]` : va à la fin du *buffer* ;
* `[C-a]` : va au début de la ligne ;
* `[C-e]` : va à la fin de la ligne ;
* `[C-l]` : recentre l'affichage.

### Changer de *buffer*

* `[C-x <-]` : change le *buffer* courant pour le *buffer* suivant ;
* `[C-x ->]` : change le *buffer* courant pour le *buffer* précédent
* `[C-x b buffername]` : changer de *buffer* en tapant son nom
* `[C-x k]` : ferme le buffer courant.

## Le texte

### Rechercher du texte

* `[C-s word]` : recherche `word` dans la suite du buffer ;
* `[C-r word]` : recherche `word` dans l'autre sens ;
* `[C-M-s regexp]` et `[C-M-r regexp]` : recherche en suivant une expression rationnelle  ;

### Remplacement

* `replace-string` et `replace-regexp`

### Toujours utile ...

* `[C-/]` : annule la dernière action ;
* `[C-k]` : supprime le texte entre la position courante et la fin de la ligne ;
* `[C-o]` : insère un saut de ligne à la position courante ;
* `[M-BACKSPACE]` : supprime le mot derrière le curseur.


## Utiliser les regions

### Placer une région

Une région est le texte situé entre la *mark* et le curseur.

On place la *mark* avec `[C-ESPACE]`.

### Actions courantes

* `[C-w]` : coupe la région ;
* `[M-w]` : copie la région ;
* `[C-x TAB]` : réindente la région ;

## Utiliser le *kill ring*/coller du texte

C'est une liste circulaire contenant toute suppression d'une taille
supérieure à 1 caractère.

* `[C-y]` : colle l'élément courant du *kill ring* ;
* `[M-y]` : passe à l'élément suivant.

## Les macros

Les macros sont des séquences de commandes, stockées dans le *macro ring*.

### Cycle de vie

* `[C-x (]` : démarre l'enregistrement d'une macro ;
* On effectue les actions que l'on souhaite répéter ;
* `[C-x )]` : arrête l'enregistrement de la macro ;
* `[C-x e]` : lance la dernière macro ;
* `[C-x C-k b]` : associe une combinaison de touche à la dernière macro définie ;
* `[C-x C-k n]` : nomme la dernière macro définie ;

## Interragir avec l'extérieur

### Lancer une commande

* `[M-!]` : lance une commande et affiche ses sorties dans un nouveau buffer ;
* `[M-|]` : lance une commande sur une région.

### Compiler

* `[M-x compile]` : demande quelle commande utiliser pour compiler ;
* `[M-x recompile]` : compile en utilisant les paramètres précédents.

# Configurer Emacs

## Architecture de la configuration

* `/usr/share/emacs/2X.0/` : commandes de bases nécessaire au fonctionnement ;
* `/usr/share/emacs/site-lisp/` : modes installés via les paquets de la distribution ;
* `/home/toto/.emacs.d/init.el` ou `/home/toto/.emacs` : lancé à l'ouverture de l'éditeur ;

Emacs va chercher dans tous les dossiers contenu dans la liste `load-path`.

## Emacs-lisp (1/2)

Langage construit autour de listes : (elt1 elt2 ...)

### Appel de fonction
`(f [arg1 [arg2 ...]])` par exemple : `(fact 42)`

### Définir une variable
`(setq SYM VAL)` : place la valeur `VAL` dans la variable `SYM`.
`(setq-default VAR VALUE)` : pour les variables localisée à un buffer,
définie leur valeur par défaut.

### Définir une fonction
`(defun NAME ARGLIST [DOCSTRING] BODY...)`

### Ajouter un élément à une liste
`(add-to-list LIST-VAR ELEMENT)`

## Emacs-lisp (2/2)

### Charger une fonctionnalité
`(require FEATURE)` : va parcourir tous les dossiers de `load-path` à
la recherche d'un fichier portant le nom.

### Réagir à des événements
`(add-hook HOOK FUNCTION)` : appelle la fonction `FUNCTION` lorsque `HOOK` sera validé.
