
static const uint32_t GD32F30x_HD_prog_blob[] = 
{
    0XE00ABE00,0X062D780D,0X24084068,0XD3000040,0X1E644058,0X1C49D1FA,0X2A001E52,0X4770D1F2,
    0XF36F4939,0X44490012,0X48386008,0X60012100,0X60414937,0X60414937,0X074069C0,0X4836D408,
    0X5155F245,0X21066001,0XF6406041,0X608171FF,0X47702000,0X6901482D,0X0180F041,0X20006101,
    0X482A4770,0XF0416901,0X61010104,0XF0416901,0X61010140,0X21AAF64A,0XE0004A27,0X68C36011,
    0XD1FB07DB,0XF0216901,0X61010104,0X47702000,0X690A491E,0X0202F042,0X6148610A,0XF0406908,
    0X61080040,0X20AAF64A,0XE0004A1B,0X68CB6010,0XD1FB07DB,0XF0206908,0X61080002,0X47702000,
    0X1CC9B510,0X0103F021,0XE0194B10,0XF044691C,0X611C0401,0X60046814,0X07E468DC,0X691CD1FC,
    0X0401F024,0X68DC611C,0X0F14F014,0X68D8D005,0X0014F040,0X200160D8,0X1D00BD10,0X1F091D12,
    0XD1E32900,0XBD102000,0X00000004,0X40022000,0X45670123,0XCDEF89AB,0X40003000,0X00000000,
    0X00000000,
};

static const uint32_t GD32F30x_HD_flash_dev[] = 
{
    0X44470101,0X33463233,0X48207830,0X2D686769,0X736E6564,0X20797469,0X20434D46,0X00000000,
    0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,
    0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,
    0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,0X00000000,
    0X00010000,0X08000000,0X00080000,0X00000400,0X00000000,0X000000FF,0X00000064,0X00000BB8,
    0X00000800,0X00000000,0XFFFFFFFF,0XFFFFFFFF,
};

static const program_target_t GD32F30x_HD_flash =
{
    (RAM_BASE + 0X0021),  // Init
    (RAM_BASE + 0X0055),  // UnInit
    (RAM_BASE + 0X0063),  // EraseChip
    (RAM_BASE + 0X0091),  // EraseSector
    (RAM_BASE + 0X00C1),  // ProgramPage
    0x0,                    // Verify,
    // BKPT : start of blob + 1
    // RSB  : address to access global/static data
    // RSP  : stack pointer
    {
        (RAM_BASE + 1),
        (RAM_BASE + 0x120),
        (RAM_BASE + 0X800),
    },
    (RAM_BASE + 0XA00),                      // mem buffer location
    RAM_BASE,                      // location to write prog_blob in target RAM
    sizeof(GD32F30x_HD_prog_blob),    // prog_blob size
    GD32F30x_HD_prog_blob,     // address of prog_blob
    0x00000400,                      // ram_to_flash_bytes_to_be_written
    0x0                    
};
