#include <espi/nl_espi_io.h>
#include "nl_espi_core.h"
#include "sys/delays.h"

static uint8_t    rxb[ESPI_SHIFT_MAX_BYTES];
static uint8_t    txb[ESPI_SHIFT_MAX_BYTES];
static ESPI_IO_T* polled_io = NULL;

static uint8_t  ioValBuffer[8];  // make sure this is big enough for all IOs in the system, currently 3
static uint16_t ioValBufferNextFree = 0;

static uint8_t* allocIOvalBuffer(uint16_t const numberOfWords)
{
  uint16_t current = ioValBufferNextFree;
  ioValBufferNextFree += numberOfWords;
  return &ioValBuffer[current];
}

void ESPI_IO_Init(ESPI_IO_T* io,
                  uint8_t    dir,
                  uint8_t    nreg,
                  uint8_t    port,
                  uint8_t    dev)
{
  io->num_of_regs = nreg;
  io->espi_port   = port;
  io->espi_dev    = dev;
  io->io          = dir;
  io->val         = allocIOvalBuffer(nreg);

  int i;
  for (i = 0; i < nreg; i++)
    io->val[i] = 0;
}

static void ESPI_IO_Out_Callback(uint32_t status)
{
  if (status != SUCCESS)
  {
    ESPI_SCS_Select(ESPI_PORT_OFF, polled_io->espi_dev);
    return;
  }

  ESPI_SAP_Clr();
  DELAY_ONE_CLK_CYCLE;  // give some time ...
  DELAY_ONE_CLK_CYCLE;  // ...
  DELAY_ONE_CLK_CYCLE;  // ..., 15ns min
  ESPI_SAP_Set();
  ESPI_SCS_Select(ESPI_PORT_OFF, polled_io->espi_dev);
}

uint32_t ESPI_IO_Out_Process(ESPI_IO_T* io)
{
  int i;
  if (io->io == ESPI_SHIFT_IN)
    return 0;
  for (i = 0; i < io->num_of_regs; i++)
    txb[i] = io->val[i];
  ESPI_SCS_Select(io->espi_port, io->espi_dev);
  polled_io = io;
  return ESPI_Transfer(txb, rxb, io->num_of_regs, ESPI_IO_Out_Callback);
}

static void ESPI_IO_In_Callback(uint32_t status)
{
  int i;
  ESPI_SCS_Select(ESPI_PORT_OFF, polled_io->espi_dev);
  if (status != SUCCESS)
    return;

  for (i = 0; i < polled_io->num_of_regs; i++)
    polled_io->val[i] = rxb[i];
}

uint32_t ESPI_IO_In_Process(ESPI_IO_T* io)
{
  if (io->io == ESPI_SHIFT_OUT)
    return 0;
  ESPI_SCS_Select(io->espi_port, io->espi_dev);
  ESPI_SAP_Clr();
  DELAY_ONE_CLK_CYCLE;  // give some time ...
  DELAY_ONE_CLK_CYCLE;  // ...
  DELAY_ONE_CLK_CYCLE;  // ..., 15ns min
  ESPI_SAP_Set();
  polled_io = io;
  ///SPI_DMA_SwitchMode(LPC_SSP0, SSP_CPHA_SECOND | SSP_CPOL_LO);
  return ESPI_Transfer(txb, rxb, io->num_of_regs, ESPI_IO_In_Callback);
}
