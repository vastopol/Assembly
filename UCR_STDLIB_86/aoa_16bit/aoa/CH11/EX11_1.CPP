
extern "C" void GotoXY(unsigned y, unsigned x);
extern "C" void GetXY(unsigned &x, unsigned &y);
extern "C" void ClrScrn();
extern "C" int tstKbd();
extern "C" void Capture(unsigned ScrCopy[25][80]);
extern "C" void PutScr(unsigned ScrCopy[25][80]);
extern "C" void PutChar(char ch);
extern "C" void PutStr(char *ch);

int main()
{
    unsigned 	SaveScr[25][80];

    int         dx,
                x,
                dy,
                y;

    long        i;

    unsigned    savex,
                savey;



    GetXY(savex, savey);
    Capture(SaveScr);
    ClrScrn();

    GotoXY(24,0);
    PutStr("Press any key to quit");

    dx = 1;
    dy = 1;
    x = 1;
    y = 1;
    while (!tstKbd())
    {

	GotoXY(y, x);
        PutChar('#');

        for (i=0; i<500000; ++i);

        GotoXY(y, x);
        PutChar(' ');



	x += dx;
        y += dy;
        if (x >= 79)
	{
            x = 78;
            dx = -1;
	}
        else if (x <= 0)
	{
            x = 1;
            dx = 1;
	}

        if (y >= 24)
	{
            y = 23;
            dy = -1;
	}
        else if (y <= 0)
	{
            y = 1;
            dy = 1;
	}


    }

    PutScr(SaveScr);
    GotoXY(savey, savex);
    return 0;
}
