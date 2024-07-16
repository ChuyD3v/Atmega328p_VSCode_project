#define F_CPU 16000000UL

#include <avr/io.h>
#include <util/delay.h>

int main(void) {
    // Configurar el pin 13 como salida
    DDRB |= (1 << DDB5);

    while (1) {
        // Encender el LED
        PORTB |= (1 << PORTB5);
        _delay_ms(1000);

        // Apagar el LED
        PORTB &= ~(1 << PORTB5);
        _delay_ms(1000);
    }

    return 0;
}
