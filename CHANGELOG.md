# *Current version: 1.3.0*

Record all changes made into this CHANGELOG.

### 1.3.0 (17-03-2024)

---

* Updating cards algorithm changed to retain pre-existing card information for unchanged cards
* Updating does not block app - blocks deck instead till finished
* Spaced repetition algorithm implemented as a variation of SM2 algorithm - to be finetuned and tested further
* Difficulty selector created to reflect confidence level

### 1.2.5 (10-03-2024)

---

* Bugfix: Changing card now does not have delay to swap back to question
* Can have over 100 cards in a deck
* Custom loading screen template created - not in use as waiting frame images

### 1.2.4 (09-03-2024)

---

* Bugfix: Empty rows on database not failing *Add deck* functionality

### 1.2.3 (04-03-2024)

---

* Added speaking feature accomodating to Japanese and English
* Improved readability on cards

### 1.2.2 (03-03-2024)

---

* Katakana/Hiragana to Romaji converting toggle
* Top spacing in card view page and improved UI

### 1.2.1 (03-03-2024)

---

* Cards are scrollable  - Removed next/previous buttons
* Card colours configurable by user

### **1.2.0 (28-02-2024)**

---

Added *testEnv* field for images to dev support

* * Set to false before deployment for images to be shown correctly
* Improved responsiveness on phone and smaller screens
* Scrollable *Info* dialog
* Scrollable and more detailed *Add deck* dialog
* Added "is database title matching header title"

  * Allows using column headers which are not title
  * Can now have any combination of columns as name and answers
* Added *Add Reversed Deck*

  * Creates a new deck with the reversed question and answer reversed
  * You **cannot ** update/reverse a reversed deck. You must either recreate it or update the original and reverse it again.
  * Helpful when learning languages and we want a two-way learning decks
* Removed WIP from README

### **1.1.2 (28-02-2024)**

---

Added *testEnv* field for images to dev support

* * Set to false before deployment for images to be shown correctly
* Improved responsiveness on phone and smaller screens
