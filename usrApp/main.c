#include "ucos/includes.h"

#include "rpi_timer.h"
#include "rpi_gpio.h"
#include "rpi_aux.h"

OS_STK  userAppTaskStk1[1000];
OS_STK  userAppTaskStk2[1000];

extern void userApp1(void *);
extern void userApp2(void *);

void main()
{
	rpi_cpu_irq_disable();
	rpi_aux_mu_init();

	rpi_aux_mu_string("HELLO WORLD");

	/*uart_init();

	InitInterruptController();

	DisableInterrupts();

	timer_init(); */

	OSInit();

	OSTaskCreate(userApp1, (void *) 0, &userAppTaskStk1[1000-1],5);

	OSTaskCreate(userApp2, (void *) 0, &userAppTaskStk2[1000-1],6);

	OSStart();

	while(1);
}
