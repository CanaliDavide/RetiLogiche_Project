# RetiLogiche_Project

The specification of the Final Proof (Logical Networks Project) 2020 is inspired by the histogram equalization method of an image.
The method of equalizing the histogram of an image is a method designed to recalibrate the contrast of an image when 
the range of intensity values are very close together by making a distribution over the entire intensity range in order to increase the contrast.

La specifica della Prova finale (Progetto di Reti Logiche) 2020 è ispirata al metodo di equalizzazione dell’istogramma di una immagine.
Il metodo di equalizzazione dell’istogramma di una immagine è un metodo pensato per ricalibrare il contrasto di una immagine quando 
l’intervallo dei valori di intensità sono molto vicini effettuandone una distribuzione su tutto l’intervallo di intensità, al fine di incrementare il contrasto.

Nella versione da sviluppare non è richiesta l’implementazione dell’algoritmo standard ma di una sua versione semplificata. L’algoritmo di equalizzazione sarà applicato solo ad immagini
in scala di grigi a 256 livelli e deve trasformare ogni suo pixel nel modo seguente:

DELTA_VALUE = MAX_PIXEL_VALUE – MIN_PIXEL_VALUE

SHIFT_LEVEL = (8 – FLOOR(LOG2(DELTA_VALUE +1)))

TEMP_PIXEL = (CURRENT_PIXEL_VALUE - MIN_PIXEL_VALUE) << SHIFT_LEVEL

NEW_PIXEL_VALUE = MIN( 255 , TEMP_PIXEL)

Dove MAX_PIXEL_VALUE e MIN_PIXEL_VALUE , sono il massimo e minimo valore dei pixel dell’immagine, CURRENT_PIXEL_VALUE è il valore del pixel da trasformare, e
NEW_PIXEL_VALUE è il valore del nuovo pixel.
