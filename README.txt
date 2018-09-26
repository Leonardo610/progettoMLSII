------ATTENZIONE-------
Per eseguire il codice sono necessari gli embeddings di almeno uno tra questi:
Senna, scaricabili da qui:
	http://ronan.collobert.com/senna/
Amazon, scaricabili da qui:
	https://snap.stanford.edu/data/web-Amazon.html
word2vec e Google news embeddings:
	https://code.google.com/p/word2vec/

Devono essere inseriti nella cartella embeddings/ del progetto
Altri dataset devono essere inseriti nella cartella evaluation/

Codice originale:
https://github.com/pdsujnow/opinion-target

-----------------------------------------------------------------------------------

Creare l'immagine del contenitore con:
docker build -t <repository:imageTag> .

Creare il contenitore e loggare con:
docker run -it <repository:imageTag> bash

Entrare nella cartella del progetto:
cd progettoml/opinion-target-master

Eseguire i comandi (esempi):
bash rnn-batch.sh Senna
bash cv-batch.sh laptop Senna 50 50

