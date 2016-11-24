#include <stdio.h>
#include <stdlib.h>

int main()
{
	FILE *f;
	FILE *g;

	int version;
	int build;

	f = fopen( "version.dat", "r" );
	fscanf(f, "%d %d", &version, &build );
	fclose( f );
	build += 1;
	version += 1;

	f = fopen( "version.dat", "w" );
	fprintf( f, "%d\n%d\n", version, build );
	fclose( f );

	g = fopen( "version.h", "w" );
	fprintf
	( 
		g, 
		"#define VersionInformation "
		"\"Version 2.%d build %d (prototype)\"\n\n",
		version,
		build
	);
	fclose( g );

	g = fopen( "version.inno", "w" );
	fprintf
	( 
		g, 
		"AppVerName=hla v2.%d\n",
		version
	);
	fclose( g );
	return 0;

}
