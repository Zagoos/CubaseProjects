#!/usr/bin/perl
#use strict;
#use warnings;
use List::Util 'shuffle';
use List::Util qw[min max];
use Data::Dumper;

my $scartoPerc = 10;
my $scartoEstr = 5;
#my $dir        = "D:\\Foto\\2Print";
#my $ext        = "jpg";
my $dir      = "D:\\CubaseProjects";
my $ext      = "cpr";
my $debug    = "off";
my $badDir   = "brutti";
my $learnDir = "impara";
my $exit     = 0;

system("cls");

print "\n";
print
" +------------------------------------------------------------------------------+\n";
print
" |                        ._.          __                          _            |\n";
print
" |   /\\/\\   __ _ _ __   __| | __ _    / /  __ _    /\\/\\  _   _ ___(_) ___ __ _  |\n";
print
" |  /    \\ / _` | '_ \\ / _` |/ _` |  / /  / _` |  /    \\| | | / __| |/ __/ _` | |\n";
print
" | / /\\/\\ \\ (_| | | | | (_| | (_| | / /__| (_| | / /\\/\\ \\ |_| \\__ \\ | (_| (_| | |\n";
print
" | \\/    \\/\\__,_|_| |_|\\__,_|\\__,_| \\____/\\__,_| \\/    \\/\\__,_|___/_|\\___\\__,_| |\n";
print
" |                                                                              |\n";
print
" +------------------------------------  v1.1  ----------------------------------+\n";
print "\n";

if ( $ARGV[0] eq "" )
{
	$toLearn = quante();
	chomp($toLearn);
}
else
{
	chomp( $ARGV[0] );
	$toLearn = $ARGV[0];
}

@files = `dir /B/S $dir | grep -i .$ext | grep -v old | grep -v $badDir | grep -v $learnDir`;

if ( scalar @files == 0 )
{
	print
	  "\n Non prendiamo per il culo,\n non ci sono musiche da mandare !!!\n";
	$exit = 1;
}

$statsFile = "stats.txt";

if ( $exit == 0 )
{

 # saving old logs #############################################################
	system("move /Y $statsFile.3 $statsFile.4 >nul");
	system("move /Y $statsFile.2 $statsFile.3 >nul");
	system("move /Y $statsFile.1 $statsFile.2 >nul");
	system("copy /Y $statsFile $statsFile.1 >nul");
	###############################################################################

	if ( !-e $statsFile )    # se il file stats.txt non esiste ###############
	{
		open FILE, "> $statsFile" or die "Can't open $statsFile $!";
		my $i = 0;
		foreach (@files)
		{
			chomp();
			push @stats, {
				filename    => $_,
				estrazioni  => 0,
				sessioni    => 0,
				percentuale => 0,
				presente    => 1     # TRUE
			};
			$i++;
		}
		my $str = Data::Dumper->Dump( [ \@stats ], ['$stats'] );
		print FILE $str;
		close FILE;
	}
	else    # se il file stats.txt esiste ####################################
	{
		open FILE, "< $statsFile" or die "Can't open $statsFile $!";
		local ($/) = undef;
		my $str = <FILE>;
		close FILE;

		eval $str;
		@stats = @$stats;

		###################################################################
		# aggiungi nuovi files a @stats ###################################
		###################################################################
		foreach (@files)
		{
			my $new = 1;    # TRUE
			$file = $_;
			chop($file);    # rimuove END OF LINE

			foreach (@stats)
			{
				if ( $file eq $$_{'filename'} )
				{
					$new = 0;    # FALSE
					last;
				}
			}

			if ( $new == 1 )
			{
				push @stats, {
					filename    => $file,
					estrazioni  => 0,
					sessioni    => 0,
					percentuale => 0,
					presente    => 1        # TRUE
				};
			}
		}
		###################################################################

		###################################################################
		# elimina gli elementi di @stats non piu' presenti ################
		###################################################################
		my @toBeDeleted;
		my $i = 0;

		foreach (@stats)
		{
			%data = %{$_};

			foreach (@files)
			{
				$file = $_;
				chop($file);

				if ( $file eq $data{'filename'} )
				{
					$data{'presente'} = 1;
					last;
				}
				else
				{
					$data{'presente'} = 0;
				}
			}

			if ( $data{'presente'} == 0 )
			{
				print " ---> Il file "
				  . $data{'filename'}
				  . " non e' piu' presente e verra' rimosso dall'elenco!\n\n";
				push @toBeDeleted, $i;
			}

			%{$_} = %data;
			$i++;
		}

		@toBeDeleted = reverse @toBeDeleted;    # per eliminare gli elementi
		                                        # dal fondo dell'array
		foreach (@toBeDeleted)
		{
			splice @stats, $_, 1;
		}
		###################################################################
	}

	my $MAX_PERC = 0.0;
	my $MIN_PERC = 100.0;
	my $MAX_ESTR = 0.0;
	my $MIN_ESTR = 100.0;

	foreach my $stat (@stats)
	{
		$$stat{'sessioni'} += 1;
		$$stat{'percentuale'} =
		  sprintf( "%.2f", 100 * $$stat{'estrazioni'} / $$stat{'sessioni'} );

		if ( $$stat{'percentuale'} > $MAX_PERC )
		{
			$MAX_PERC = $$stat{'percentuale'};
		}

		if ( $$stat{'percentuale'} < $MIN_PERC )
		{
			$MIN_PERC = $$stat{'percentuale'};
		}

		if ( $$stat{'estrazioni'} > $MAX_ESTR )
		{
			$MAX_ESTR = $$stat{'estrazioni'};
		}

		if ( $$stat{'estrazioni'} < $MIN_ESTR )
		{
			$MIN_ESTR = $$stat{'estrazioni'};
		}
	}

	print "\n MAX_PERC : " . $MAX_PERC;
	print "\n MIN_PERC : " . $MIN_PERC . "\n";

	print "\n MAX_ESTR : " . $MAX_ESTR;
	print "\n MIN_ESTR : " . $MIN_ESTR . "\n\n";

	# Manda la musica !!!##################################################
	@imparaExists = `dir /B/S $dir | grep -i $learnDir`;
	if ( scalar @imparaExists == 0 )
	{
		if ( $toLearn > 0 )
		{
			print
" Se volete imparare dei nuovi brani\n dovreste metterli nella cartella $learnDir/ ...\n\n";
			exit();
		}
	}
	else
	{
		@impara = `dir /B/S $dir | grep -i .$ext | grep -i $learnDir`;

		if ( scalar @impara == 0
			|| $toLearn ==
			0 )    # cartella impara senza progetti o nulla da imparare
		{
			print
" \n Niente da imparare ???\n Andiamo bene !!!\n Sentiamo come ve la cavate con queste ...\n\n";
		}
		else
		{
			my $impara = min( $toLearn, scalar @impara );

			@impara = shuffle(@impara);
			while ( $impara > 0 )
			{
				chomp( @impara[ 2 - $impara ] );
				print " " . @impara[ 2 - $impara ] . "\t";

				$_ = @impara[ 2 - $impara ];
				s/&/^&/g;    #escape & with ^&
				if ( $debug eq "off" )
				{
					# start "title" "command"
					system( "start", "", "$_" );
				}

				if ( continua() )
				{
					$impara -= 1;
					next;
				}
				else
				{
					$exit = 1;
					last;
				}
			}
		}
	}

	if ( $exit == 0 )
	{
		@stats = shuffle(@stats);
		foreach my $stat (@stats)
		{
			if ( $$stat{'percentuale'} > ( $MIN_PERC + $scartoPerc ) )
			{
				print " !!! --> "
				  . $$stat{'filename'}
				  . " e' stato saltato (percentuale).\n";
				next;
			}
			else
			{
				if ( $$stat{'estrazioni'} > ( $MIN_ESTR + $scartoEstr ) )
				{
					print " !!! --> "
					  . $$stat{'filename'}
					  . " e' stato saltato (n estrazioni).\n";
					next;
				}

				$$stat{'estrazioni'} += 1;

				if ( $$stat{'sessioni'} > 0 )
				{
					$$stat{'percentuale'} =
					  100 * $$stat{'estrazioni'} / $$stat{'sessioni'};
					$$stat{'percentuale'} =
					  sprintf( "%.2f", $$stat{'percentuale'} );

					if ( $$stat{'percentuale'} > $MAX_PERC )
					{
						$MAX_PERC = $$stat{'percentuale'};
					}

					if ( $$stat{'percentuale'} < $MIN_PERC )
					{
						$MIN_PERC = $$stat{'percentuale'};
					}

					if ( $$stat{'estrazioni'} > $MAX_ESTR )
					{
						$MAX_ESTR = $$stat{'estrazioni'};
					}

					if ( $$stat{'estrazioni'} < $MIN_ESTR )
					{
						$MIN_ESTR = $$stat{'estrazioni'};
					}
				}

				print " " . $$stat{'filename'} . "\t";

				$_ = $$stat{'filename'};
				s/&/^&/g;    #escape & with ^&
				
				if ( $debug eq "off" )
                {
                    # start "title" "command"
                    system( "start", "", "$_" );
                }

				if ( continua() )
				{
					next;
				}
				else
				{
					last;
				}
			}
		}
	}
###################################################################

	# Mostra le statistiche aggiornate ################################
	@stats = sort {
		     $$b{percentuale} <=> $$a{percentuale}
		  || $$b{estrazioni} <=> $$a{estrazioni}
		  || $$a{filename} cmp $$b{filename}
	} @stats;

	print "\n DATI RIASSUNTIVI\n\n";
	print " freq.\t%\tnome\n\n";
	foreach my $stat (@stats)
	{
		print " "
		  . $$stat{'estrazioni'} . "/"
		  . $$stat{'sessioni'} . "\t"
		  . $$stat{'percentuale'} . "\t"
		  . $$stat{'filename'} . "\n";
	}
###################################################################

	open FILE, "> $statsFile" or die "Can't open $statsFile $!";
	my $dump = Data::Dumper->Dump( [ \@stats ], ['$stats'] );
	print FILE $dump;
	close FILE;

	chiudi();
}

sub continua
{
	print "Continuare (s/n)? ";
	$_ = <STDIN>;
	return ( $_ !~ /^n/i );
}

sub chiudi
{
	print "\n Enter per chiudere.\n";
	$_ = <STDIN>;
	return (1);
}

sub quante
{
	print "\n Quante ne impariamo? ";
	$_ = <STDIN>;

	if ( $_ =~ /[0-9]+/ )
	{
		return $_;
	}
	else
	{
		print " ... un numero sarebbe gradito ...\n";
		return quante();
	}
}

