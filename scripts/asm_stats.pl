#!/usr/bin/env perl

use File::Spec;
use strict;
use warnings;

my %stats;
my $model = 'basidiomycota_odb10';
my $modelpep = 'basidiomycota_odb10';
my $BUSCO_dir = 'BUSCO';
my $BUSCO_pep = 'BUSCO_pep';
my $telomere_report = 'telomere_reports';
my $read_map_stat = 'mapping_report';
my $dir = shift || 'genomes';
my @header;
my %header_seen;

opendir(DIR,$dir) || die $!;
my $first = 1;
foreach my $file ( readdir(DIR) ) {
# special for Tania's work since she has mixed final sorted files and other subsets in same folder
    next unless ( $file =~ /(\S+)(\.fasta)?\.stats.txt$/);
    #next unless ( $file =~ /(\S+)(\.fasta)?\.stats.txt$/);
    my $stem = $1;
    #$stem =~ s/\.sorted//;
    #warn("$file ($dir)\n");
    open(my $fh => "$dir/$file") || die "cannot open $dir/$file: $!";
    while(<$fh>) {
	next if /^\s+$/;
	s/^\s+//;
	chomp;
	if ( /\s*(.+)\s+=\s+(\d+(\.\d+)?)/ ) {
	    my ($name,$val) = ($1,$2);	    
	    $name =~ s/\s*$//;
	    $name =~ s/\s+/_/g;
	    $stats{$stem}->{$name} = $val;

	    if( ! $header_seen{$name} ) {
		push @header, $name;
		$header_seen{$name} = 1;
	    }
	}
    }

    if ( -d $telomere_report ) {
	if ( $first ) {
	    push @header, qw(Telomeres_Found);
	    #TELOMERE_FWD TELOMERE_REV T2T_SCAFFOLDS);
	}
	my $telomerefile = File::Spec->catfile($telomere_report,sprintf("%s.telomere_report.txt",$stem));
  	if ( ! -f $telomerefile ) {
		$telomerefile = File::Spec->catfile($telomere_report,sprintf("%s.sorted.telomere_report.txt",$stem));
	}
	if ( -f $telomerefile ) {
	    open(my $fh => $telomerefile) || die $!;
	    my %contigs_with_tel;
	    while(<$fh>) {
		if( /^(\S+)\s+(.*\s+)?(forward|reverse)\s+(\S+)/i ){
		    $contigs_with_tel{$1}->{$3} = $4;
		} elsif (/^Telomeres found:\s+(\d+)\s+\((\S+)\s+forward,\s+(\S+)\s+reverse\)/ ) {
		    $stats{$stem}->{'Telomeres_Found'} = $1;
		    $stats{$stem}->{'TELOMERE_FWD'} = $2;
		    $stats{$stem}->{'TELOMERE_REV'} = $3;
		}
	    }
	    # override if we have run the report instead of AAFTF parse
	    $stats{$stem}->{'T2T_SCAFFOLDS'} = 0;
	    for my $ctg ( keys %contigs_with_tel ) {
		if (exists $contigs_with_tel{$ctg}->{'forward'} &&
		    exists $contigs_with_tel{$ctg}->{'reverse'} ) {
		    $stats{$stem}->{'T2T_SCAFFOLDS'} +=1; # or ++ but count up the number of times we have a ctg w fwd&rev
		}
	    }
	}

    }
    if ( -d $BUSCO_dir ) {
	if ( $first ) { 
	    push @header, qw(BUSCO_Complete BUSCO_Single BUSCO_Duplicate
			     BUSCO_Fragmented BUSCO_Missing BUSCO_NumGenes
		);
	}
	
	my $busco_file = File::Spec->catfile($BUSCO_dir,$stem, 
					     sprintf("short_summary.specific.%s.%s.txt",$model,$stem));
	
				     #warn("busco file is $busco_file\n");
	if ( -f $busco_file ) {	    
	    open(my $fh => $busco_file) || die $!;
	    while(<$fh>) {	 
		if (/^\s+C:(\d+\.\d+)\%\[S:(\d+\.\d+)%,D:(\d+\.\d+)%\],F:(\d+\.\d+)%,M:(\d+\.\d+)%,n:(\d+)/ ) {
		    $stats{$stem}->{"BUSCO_Complete"} = $1;
		    $stats{$stem}->{"BUSCO_Single"} = $2;
		    $stats{$stem}->{"BUSCO_Duplicate"} = $3;
		    $stats{$stem}->{"BUSCO_Fragmented"} = $4;
		    $stats{$stem}->{"BUSCO_Missing"} = $5;
		    $stats{$stem}->{"BUSCO_NumGenes"} = $6;
		} 
	    }
	    
	} else {
	    warn("Cannot find $busco_file");
	}
    }

        if ( -d $BUSCO_pep ) {
	if ( $first ) { 
	    push @header, qw(BUSCOP_Complete BUSCOP_Single BUSCOP_Duplicate
			     BUSCOP_Fragmented BUSCOP_Missing BUSCOP_NumGenes
		);
	}
	my $stem_no_MT = $stem;
	$stem_no_MT =~ s/_fullMito//;
	my $busco_file = File::Spec->catfile($BUSCO_pep,sprintf("%s_predict_proteins",$stem_no_MT), 
					     sprintf("short_summary.specific.%s.%s_predict_proteins.txt",$modelpep,
						     $stem_no_MT));
	
	if ( -f $busco_file ) {
	    open(my $fh => $busco_file) || die $!;
	    while(<$fh>) {	 
		if (/^\s+C:(\d+\.\d+)\%\[S:(\d+\.\d+)%,D:(\d+\.\d+)%\],F:(\d+\.\d+)%,M:(\d+\.\d+)%,n:(\d+)/ ) {
		    $stats{$stem}->{"BUSCOP_Complete"} = $1;
		    $stats{$stem}->{"BUSCOP_Single"} = $2;
		    $stats{$stem}->{"BUSCOP_Duplicate"} = $3;
		    $stats{$stem}->{"BUSCOP_Fragmented"} = $4;
		    $stats{$stem}->{"BUSCOP_Missing"} = $5;
		    $stats{$stem}->{"BUSCOP_NumGenes"} = $6;
		} 
	    }
	    
	} else {
	    warn("Cannot find $busco_file");
	}
    }

    if ( -d $read_map_stat ) {
    
	my $sumstatfile = File::Spec->catfile($read_map_stat,
					      sprintf("%s.bbmap_summary.txt",$stem));
	warn("sumstat is $sumstatfile\n");
	if ( -f $sumstatfile ) {
	    open(my $fh => $sumstatfile) || die "Cannot open $sumstatfile: $!";
	    my $read_dir = 0;
	    my $base_count = 0;
	    $stats{$stem}->{'Mapped reads'} = 0;
	    while(<$fh>) {
		if( /Read (\d+) data:/) {
		    $read_dir = $1;
		} elsif( $read_dir && /^mapped:\s+(\S+)\s+(\d+)\s+(\S+)\s+(\d+)/) {
		    $base_count += $4;
		    $stats{$stem}->{'Mapped_reads'} += $2;
		}  elsif( /^Reads:\s+(\S+)/) {
		    $stats{$stem}->{'Reads'} = $1;
		}
		
	    }
	    $stats{$stem}->{'Average_Coverage'} =
		sprintf("%.1f",$base_count / $stats{$stem}->{'TOTAL LENGTH'});
	    if( $first )  {
		push @header, ('Reads',
			       'Mapped_reads',			   
			       'Average_Coverage');
	    }
	}
    }
    
    $first = 0;
}
print join("\t", qw(SampleID), @header), "\n";
foreach my $sp ( sort keys %stats ) {
    my $oname = $sp;
    $oname =~ s/\.sorted//;
    print join("\t", $oname, map { $stats{$sp}->{$_} || 'NA' } @header), "\n";
}
